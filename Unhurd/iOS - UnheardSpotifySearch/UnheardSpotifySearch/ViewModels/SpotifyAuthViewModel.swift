//
//  SpotifyAuthViewModel.swift
//  UnheardSpotifySearch
//
//  Created by Joshua Browne on 04/02/2024.
//

import Foundation

class SpotifyAuthViewModel {

    private var authService: SpotifyAuthService = SpotifyAuthService()

    // This method remains unchanged, it's responsible for opening the Spotify login page
    func openLoginPage() {
        authService.openSpotifyLoginPage()
    }

    // Update to handle the authorization callback URL
    func handleAuthCallback(with url: URL, completion: @escaping (Bool, Error?) -> Void) {
        print("handleAuthCallback called with URL: \(url)")
        authService.handleAuthCallback(with: url) { success, error in
            if success {
                print("Authorization callback handled successfully.")
                self.validateAccessToken(completion: completion)
            } else {
                print("Error handling authorization callback: \(String(describing: error))")
                completion(false, error)
            }
        }
    }

    // Validates the presence of a valid access token
    private func validateAccessToken(completion: @escaping (Bool, Error?) -> Void) {
        authService.getCurrentAccessToken { accessToken in
            print("This is the access token in the validate accesss token function -> \(String(describing: accessToken))")
            if let accessToken = accessToken, !accessToken.isEmpty {
                completion(true, nil)
            } else {
                // You can specify a more descriptive error as needed
                let error = NSError(domain: "SpotifyAuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Access token is unavailable or invalid."])
                completion(false, error)
            }
        }
    }
}

