//
//  SpotifyAuthService.swift
//  UnheardSpotifySearch
//
//  Created by Joshua Browne on 04/02/2024.
//

import Foundation
import UIKit

// TokenData struct to decode the token JSON
struct TokenData: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let refreshToken: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
    }
}

class SpotifyAuthService {
    // Define your Spotify credentials and callback
    private let clientId = "5a2ec24f0ca04699abe72ebee7b85b46"
    private let redirectUri = "unhurdspotifysearch://callback"
  //  private let redirectUri = "http://127.0.0.1:5000/callback"
    // Must match the one set in Spotify Dashboard and Info.plist
    private let scopes = "user-read-private" // Add other scopes if needed
    
    static let shared = SpotifyAuthService()

    
    private let accessTokenKey = "SpotifyAccessToken"
    private let refreshTokenKey = "SpotifyRefreshToken"
    private let tokenExpiryKey = "SpotifyTokenExpiry"
    private let keychainService = "SpotifyService"

    // Construct the authorization URL
    private var authUrl: URL {
        var components = URLComponents(string: "https://accounts.spotify.com/authorize")!
        let queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "scope", value: scopes)
        ]
        components.queryItems = queryItems
        return components.url!
    }

    // Open the Spotify login page
    func openSpotifyLoginPage() {
        if let url = URL(string: authUrl.absoluteString) {
            print("This is the url for the spotify login page -> \(url)")
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    // Inside SpotifyAuthService
    func handleAuthCallback(with url: URL, completion: @escaping (Bool, Error?) -> Void) {
        print("AuthService: Handling auth callback with URL: \(url)")
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        if let code = components?.queryItems?.first(where: { $0.name == "code" })?.value {
            print("AuthService: Found authorization code in URL.")
            exchangeCodeForToken(code) { success, error in
                completion(success, error)
            }
        } else if let error = components?.queryItems?.first(where: { $0.name == "error" })?.value {
            print("AuthService: Found error in callback URL: \(error)")
            let authError = NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Authorization failed with error: \(error)"])
            completion(false, authError)
        } else {
            print("AuthService: No code and no error in callback URL.")
            let noCodeError = NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No authorization code or error returned"])
            completion(false, noCodeError)
        }
    }
    
    private func exchangeCodeForToken(_ code: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let tokenExchangeUrl = URL(string: "http://192.168.*.*:5000/api/token") else {
            print("AuthService: Invalid token exchange URL.")
            completion(false, nil)
            return
        }
        
        var request = URLRequest(url: tokenExchangeUrl)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyParameters = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectUri,
            "client_id": clientId
        ]
        request.httpBody = bodyParameters.percentEscaped().data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("AuthService: Network error during token exchange: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("AuthService: Received HTTP response with status code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("AuthService: No data received in token exchange response.")
                completion(false, nil)
                return
            }
            
            print("AuthService: Received raw response data string: \(String(describing: String(data: data, encoding: .utf8)))")
            
            do {
                let tokenData = try JSONDecoder().decode(TokenData.self, from: data)
                print("AuthService: Successfully decoded token data. Access Token: \(tokenData.accessToken)")
                print("Expires in -> \(tokenData.expiresIn)")
                print("Type -> \(tokenData.tokenType)")
                print("Refresh token -> \(tokenData.refreshToken)")

                self.storeAccessToken(tokenData.accessToken)
                
                // Store the refresh token if present
                if let refreshToken = tokenData.refreshToken {
                    let refreshTokenSaveStatus = KeychainManager.shared.save(service: self.keychainService, account: self.refreshTokenKey, data: refreshToken)
                    print("Refresh token save status: \(refreshTokenSaveStatus)")
                }

                // Calculate and store the expiry timestamp
                let expiryTimestamp = Date().timeIntervalSince1970 + Double(tokenData.expiresIn)
                let expiryTimestampSaveStatus = KeychainManager.shared.save(service: self.keychainService, account: self.tokenExpiryKey, data: String(expiryTimestamp))
                print("Token expiry timestamp save status: \(expiryTimestampSaveStatus)")
                
                completion(true, nil)
            } catch {
                print("AuthService: Failed to decode token data with error: \(error)")
                completion(false, error)
            }
        }
        task.resume()
    }
    
    // Refresh the access token if it's expired using the refresh token
    func refreshTokenIfNeeded(completion: @escaping (Bool) -> Void) {
        print("refreshTokenIfNeeded called")
        
        // Check if we already have a valid access token
        if let expiryString = KeychainManager.shared.load(service: keychainService, account: tokenExpiryKey),
           let expiryTimestamp = Double(expiryString),
           Date().timeIntervalSince1970 < expiryTimestamp {
            print("Access token is still valid.")
            completion(true)
            return
        }

        // Proceed with refresh token logic if access token is expired or not present
        guard let refreshToken = KeychainManager.shared.load(service: keychainService, account: refreshTokenKey) else {
            print("No refresh token available. User needs to login again.")
            completion(false)
            return
        }

        // Replace this URL with your actual endpoint if different.
        // This example uses the local IP for the refresh token exchange endpoint.
        guard let url = URL(string: "http://192.168.*.*:5000/api/spotify/refresh_token") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["refresh_token": refreshToken]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Network error or no data received: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
                return
            }

            do {
                let tokenData = try JSONDecoder().decode(TokenData.self, from: data)
                DispatchQueue.main.async {
                    // Save the new access token and refresh token (if provided)
                    // Assuming the `save` method of `KeychainManager` expects Data as its parameter for the data to be saved
                    // Corrected save calls inside refreshTokenIfNeeded
                    // Assuming TokenData is correctly decoding JSON as per your structure
                    let accessTokenSaveStatus = KeychainManager.shared.save(service: self.keychainService, account: self.accessTokenKey, data: tokenData.accessToken)
                    print("AccessToken save status: \(accessTokenSaveStatus)")
                    

                    if let refreshToken = tokenData.refreshToken {
                        let refreshTokenSaveStatus = KeychainManager.shared.save(service: self.keychainService, account: self.refreshTokenKey, data: refreshToken)
                        print("Refresh token save status: \(refreshTokenSaveStatus)")
                    } else {
                        print("No refresh token available to save.")
                    }


                    // Update the expiry timestamp in the keychain
                    let expiryTimestamp = Date().timeIntervalSince1970 + Double(tokenData.expiresIn)
                    let expiryTimestampSaveStatus = KeychainManager.shared.save(service: self.keychainService, account: self.tokenExpiryKey, data: String(expiryTimestamp))
                    print("Token expiry timestamp save status: \(expiryTimestampSaveStatus)")


                    completion(true)
                }
            } catch {
                print("Failed to decode token data: \(error.localizedDescription)")
                completion(false)
            }
        }.resume()
    }

    // Get the current access token, refreshing it if necessary
    func getCurrentAccessToken(completion: @escaping (String?) -> Void) {
        refreshTokenIfNeeded { [weak self] success in
            guard success else {
                print("Failed to refresh the access token.")
                completion(nil)
                return
            }
            // This will now correctly return the access token whether it was just refreshed or was already valid
            completion(self?.retrieveAccessToken())
        }
    }

    
    func storeAccessToken(_ token: String) {
        let wasSuccessful = KeychainManager.shared.save(service: keychainService, account: accessTokenKey, data: token)
        if wasSuccessful {
            print("AccessToken stored successfully")
        } else {
            print("Failed to store access token")
        }
    }
    
    func retrieveAccessToken() -> String? {
        let accessToken = KeychainManager.shared.load(service: keychainService, account: accessTokenKey)
        print("Attempt to retrieve access token -> \(String(describing: accessToken))")
        return accessToken
    }

    // Helper to percent-escape HTTP body parameters
    private func percentEscapeString(_ string: String) -> String {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "-._* ")
        
        return string
            .addingPercentEncoding(withAllowedCharacters: characterSet)!
            .replacingOccurrences(of: " ", with: "+", options: [], range: nil)
    }
    
    // Example of sending the authorization code to your backend
    func sendAuthorizationCodeToBackend(code: String) {
        guard let tokenExchangeUrl = URL(string: "http://192.168.*.*:5000/api/token") else { return }
        
        var request = URLRequest(url: tokenExchangeUrl)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyParameters = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": "unhurdspotifysearch://callback"  // This must match the URI used to obtain the code
        ]
        
        let bodyString = bodyParameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error during token exchange: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            print("Token exchange response: \(String(data: data, encoding: .utf8) ?? "Invalid response")")
            
            // Handle the response from your backend here
        }.resume()
    }
}

extension String {
    // Helper function to percent-escape string for URL encoding
    func percentEscaped() -> String {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "-._* ")
        
        return self
            .addingPercentEncoding(withAllowedCharacters: characterSet)!
            .replacingOccurrences(of: " ", with: "+", options: [], range: nil)
    }
}

extension Dictionary {
    // Helper function to create percent-escaped, URL encoded query string
    func percentEscaped() -> String {
        return self.map { (key, value) in
            let escapedKey = "\(key)".percentEscaped()
            let escapedValue = "\(value)".percentEscaped()
            return escapedKey + "=" + escapedValue
        }.joined(separator: "&")
    }
}

extension Double {
    // Initialize a Double from Data
    init?(data: Data) {
        guard data.count == MemoryLayout<Double>.size else { return nil }
        self = data.withUnsafeBytes { $0.load(as: Double.self) }
    }
    
    // Convert a Double into Data
    var data: Data {
        var value = self
        return Data(bytes: &value, count: MemoryLayout<Double>.size)
    }
}
