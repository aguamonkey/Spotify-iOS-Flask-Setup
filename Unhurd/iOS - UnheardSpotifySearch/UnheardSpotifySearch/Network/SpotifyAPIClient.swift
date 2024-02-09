//
//  SpotifyAPIClient.swift
//  UnheardSpotifySearch
//
//  Created by Joshua Browne on 04/02/2024.
//

import Foundation
import UIKit

import Foundation

protocol SpotifyAPIClientProtocol {
    func fetchArtistDetails(artistId: String, completion: @escaping (Result<Artist, Error>) -> Void)
    func fetchTopTracks(forArtistId artistId: String, market: String, completion: @escaping (Result<[Track], Error>) -> Void)
}


class SpotifyAPIClient: SpotifyAPIClientProtocol {
    static let shared = SpotifyAPIClient()
    
    func searchForArtist(with query: String, completion: @escaping (Result<[Artist], Error>) -> Void) {
        SpotifyAuthService.shared.getCurrentAccessToken { accessToken in
            guard let accessToken = accessToken else {
                completion(.failure(SpotifyAPIError.accessTokenUnavailable))
                return
            }
            
            var components = URLComponents(string: "https://api.spotify.com/v1/search")
            components?.queryItems = [
                URLQueryItem(name: "type", value: "artist"),
                URLQueryItem(name: "q", value: query)
            ]
            
            guard let url = components?.url else {
                completion(.failure(SpotifyAPIError.invalidURL))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(SpotifyAPIError.noData))
                    return
                }
                
                do {
                    let searchResponse = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
                    completion(.success(searchResponse.artists.items))
                } catch {
                    // Log the error for debugging purposes
                    print("JSON Decoding Error: \(error)")
                    
                    // Handle the error by completing with a custom error or a generic message
                    completion(.failure(SpotifyAPIError.custom("An error occurred while processing the search results.")))

                }
            }.resume()
        }
    }
    
    func fetchArtistDetails(artistId: String, completion: @escaping (Result<Artist, Error>) -> Void) {
        SpotifyAuthService.shared.getCurrentAccessToken { accessToken in
            guard let accessToken = accessToken else {
                completion(.failure(SpotifyAPIError.accessTokenUnavailable))
                return
            }
            
            let urlString = "https://api.spotify.com/v1/artists/\(artistId)"
            guard let url = URL(string: urlString) else {
                completion(.failure(SpotifyAPIError.invalidURL))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(SpotifyAPIError.noData))
                    return
                }
                
                do {
                    let artist = try JSONDecoder().decode(Artist.self, from: data)
                    completion(.success(artist))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    }
}

extension SpotifyAPIClient {
    func fetchTopTracks(forArtistId artistId: String, market: String, completion: @escaping (Result<[Track], Error>) -> Void) {
        SpotifyAuthService.shared.getCurrentAccessToken { accessToken in
            guard let accessToken = accessToken else {
                completion(.failure(SpotifyAPIError.accessTokenUnavailable))
                return
            }
            
            let urlString = "https://api.spotify.com/v1/artists/\(artistId)/top-tracks?market=\(market)"
            guard let url = URL(string: urlString) else {
                completion(.failure(SpotifyAPIError.invalidURL))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(SpotifyAPIError.noData))
                    return
                }
                
                do {
                    // Decode directly into TopTracksResponse
                    let topTracksResponse = try JSONDecoder().decode(TopTracksResponse.self, from: data)
                    completion(.success(topTracksResponse.tracks))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    }
}

enum SpotifyAPIError: Error, LocalizedError {
    case accessTokenUnavailable
    case invalidURL
    case noData
    case custom(String) // New case for custom error messages
    
    // Provide a user-friendly error description for each case
    var errorDescription: String? {
        switch self {
        case .accessTokenUnavailable:
            return "Authentication failed. Please log in again."
        case .invalidURL:
            return "There was a problem with the request. Please try again later."
        case .noData:
            return "No data was received. Please check your network connection."
        case .custom(let message):
            return message // Return the custom message
        }
    }
}
