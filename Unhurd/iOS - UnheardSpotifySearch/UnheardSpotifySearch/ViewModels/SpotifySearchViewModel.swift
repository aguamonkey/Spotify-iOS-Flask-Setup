//
//  SpotifySearchViewModel.swift
//  UnheardSpotifySearch
//
//  Created by Joshua Browne on 04/02/2024.
//

import Foundation

class SpotifySearchViewModel {
    private let apiClient = SpotifyAPIClient.shared
    var artists: Observable<[Artist]> = Observable()
    var errorMessage: Observable<String?> = Observable()
    
    func searchArtists(query: String) {
        apiClient.searchForArtist(with: query) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let artists):
                    self?.artists.value = artists
                case .failure(let error):
                    self?.errorMessage.value = error.localizedDescription
                    self?.artists.value = []
                }
            }
        }
    }
}
