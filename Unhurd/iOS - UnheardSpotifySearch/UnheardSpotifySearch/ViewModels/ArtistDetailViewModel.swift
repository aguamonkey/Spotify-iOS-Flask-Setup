//
//  ArtistDetailViewModel.swift
//  UnheardSpotifySearch
//
//  Created by Joshua Browne on 07/02/2024.
//

import Foundation

class ArtistDetailViewModel {
    private var apiClient: SpotifyAPIClientProtocol
    
    // Other properties remain unchanged
    
    init(apiClient: SpotifyAPIClientProtocol) {
        self.apiClient = apiClient
    }
    
    var topTracks: Observable<[Track]?> = Observable() // Step 1: Add property for top tracks
    
    var artist: Observable<Artist?> = Observable()
    var errorMessage: Observable<String?> = Observable()
    
    func fetchArtistDetails(artistId: String) {
        print("Fetching artist details for ID: \(artistId)")
        apiClient.fetchArtistDetails(artistId: artistId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let artist):
                    print("Successfully fetched artist details for ID: \(artistId)")
                    self?.artist.value = artist
                    self?.fetchTopTracks(artistId: artistId)
                case .failure(let error):
                    print("Failed to fetch artist details for ID: \(artistId), Error: \(error.localizedDescription)")
                    self?.errorMessage.value = error.localizedDescription
                    self?.artist.value = nil
                }
            }
        }
    }
    
    func fetchTopTracks(artistId: String) {
        print("Fetching top tracks for artist ID: \(artistId)")
        apiClient.fetchTopTracks(forArtistId: artistId, market: "US") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tracks):
                    print("Successfully fetched top tracks for artist ID: \(artistId)")
                    self?.topTracks.value = tracks
                case .failure(let error):
                    print("Failed to fetch top tracks for artist ID: \(artistId), Error: \(error.localizedDescription)")
                    self?.errorMessage.value = error.localizedDescription
                }
            }
        }
    }
}

