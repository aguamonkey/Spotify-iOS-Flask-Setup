//
//  ArtistDetailViewModelTests.swift
//  UnheardSpotifySearch
//
//  Created by Joshua Browne on 08/02/2024.
//

import XCTest
@testable import UnheardSpotifySearch

class ArtistDetailViewModelTests: XCTestCase {
    
    var viewModel: ArtistDetailViewModel!
    var mockAPIClient: MockSpotifyAPIClient!
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockSpotifyAPIClient()
        viewModel = ArtistDetailViewModel(apiClient: mockAPIClient)
        
        // Assign mock data to the mockAPIClient
        mockAPIClient.mockArtistDetails = Artist(
            externalUrls: ExternalUrls(spotify: "https://spotify.com/exampleArtist"),
            followers: Followers(total: 1234),
            genres: ["Genre1", "Genre2"],
            href: "https://api.spotify.com/v1/artists/exampleArtist",
            id: "1",
            images: [ImageObject(height: 640, width: 640, url: "https://i.scdn.co/image/exampleImage")],
            name: "Test Artist",
            popularity: 80,
            type: "artist",
            uri: "spotify:artist:1")
        
        mockAPIClient.mockTopTracks = [
            Track(id: "track1", name: "Track 1", duration_ms: 3.087987, album: SimplifiedAlbum(id: "album1", name: "Album 1"), artists: [SimplifiedArtist(id: "artist1", name: "Artist 1")]),
            Track(id: "track2", name: "Track 2", duration_ms: 57476476, album: SimplifiedAlbum(id: "album2", name: "Album 2"), artists: [SimplifiedArtist(id: "artist2", name: "Artist 2")])
        ]
    }
    
    override func tearDown() {
        viewModel = nil
        mockAPIClient = nil
        super.tearDown()
    }
    
    func testFetchArtistDetailsSuccess() {
        // The spotlight's on, let's see if our artist takes the stage as expected.
        let expectation = self.expectation(description: "Fetch artist details succeeds")
        
        // Cue the music.
        viewModel.fetchArtistDetails(artistId: "1")
        
        // Watching the stage for our artist's appearance.
        viewModel.artist.bind { artist in
            if let artist = artist {
                // And there they are, in all their glory!
                XCTAssertEqual(artist?.name, "Test Artist")
                expectation.fulfill()
            }
        }
        
        // The crowd waits in anticipation.
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchTopTracksSuccess() {
        // Preparing the expectation
        let expectation = self.expectation(description: "Fetch top tracks succeeds")

        // Triggering the fetch operation
        viewModel.fetchTopTracks(artistId: "1")

        // Binding to observe changes
        viewModel.topTracks.bind { tracks in
            // Check if tracks are not nil to fulfill the expectation
            if tracks != nil {
                expectation.fulfill()
            }
        }

        // Waiting for the expectation to be fulfilled
        waitForExpectations(timeout: 5, handler: nil)

        // Assertions should be outside the bind closure and after waiting for expectations
        // Directly unwrapping the optional array to perform assertions
        if let tracks = viewModel.topTracks.value {
            XCTAssertEqual(tracks?.first?.name, "Track 1", "The first track's name should match the mock data.")
            XCTAssertEqual(tracks?.count, 2, "There should be two tracks in the mock data.")
        } else {
            XCTFail("Expected topTracks to be non-nil after successful fetch.")
        }
    }

    func testFetchArtistDetailsFailure() {
        mockAPIClient.shouldFetchArtistDetailsFail = true
        let expectation = self.expectation(description: "Fetch artist details fails")
        
        viewModel.errorMessage.bind { errorMessage in
            if let message = errorMessage, !message!.isEmpty {
                // Correct unwrapping of errorMessage and checking it's not empty
                expectation.fulfill()
            }
        }
        
        viewModel.fetchArtistDetails(artistId: "1")
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNotNil(viewModel.errorMessage.value)
    }

    func testFetchTopTracksFailure() {
        mockAPIClient.shouldFetchTopTracksFail = true
        let expectation = self.expectation(description: "Fetch top tracks fails")
        
        viewModel.errorMessage.bind { errorMessage in
            if let message = errorMessage, !message!.isEmpty {
                // Correct unwrapping of errorMessage and checking it's not empty
                expectation.fulfill()
            }
        }
        
        viewModel.fetchTopTracks(artistId: "1")
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNotNil(viewModel.errorMessage.value)
    }

}

class MockSpotifyAPIClient: SpotifyAPIClientProtocol {
    var mockArtistDetails: Artist?
    var mockTopTracks: [Track]?
    
    // New properties to control behavior
    var shouldFetchArtistDetailsFail: Bool = false
    var shouldFetchTopTracksFail: Bool = false
    var networkDelay: TimeInterval = 0
    
    func fetchArtistDetails(artistId: String, completion: @escaping (Result<Artist, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + networkDelay) {
            if self.shouldFetchArtistDetailsFail {
                completion(.failure(NSError(domain: "com.UnheardSpotifySearchTests", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock artist details fetch failed."])))
            } else if let mockArtistDetails = self.mockArtistDetails {
                completion(.success(mockArtistDetails))
            }
        }
    }
    
    func fetchTopTracks(forArtistId artistId: String, market: String, completion: @escaping (Result<[Track], Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + networkDelay) {
            if self.shouldFetchTopTracksFail {
                completion(.failure(NSError(domain: "com.UnheardSpotifySearchTests", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mock top tracks fetch failed."])))
            } else if let mockTopTracks = self.mockTopTracks {
                completion(.success(mockTopTracks))
            }
        }
    }
}


