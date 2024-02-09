//
//  SpotifyAppModels.swift
//  UnheardSpotifySearch
//
//  Created by Joshua Browne on 03/02/2024.
//

import Foundation

struct SpotifySearchResponse: Codable {
    let artists: ArtistsResponse
}

// MARK: - TopTracksResponse
struct TopTracksResponse: Codable {
    let tracks: [Track]
}

struct ArtistsResponse: Codable {
    let items: [Artist]
}

// MARK: - Artist Model
struct Artist: Codable {
    let externalUrls: ExternalUrls
    let followers: Followers
    let genres: [String]
    let href: String
    let id: String
    let images: [ImageObject]
    let name: String
    let popularity: Int
    let type: String
    let uri: String
    
    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case followers
        case genres
        case href
        case id
        case images
        case name
        case popularity
        case type
        case uri
    }
}

// MARK: - ExternalUrls
struct ExternalUrls: Codable {
    let spotify: String
}

// MARK: - Followers
struct Followers: Codable {
    let total: Int
}

// MARK: - ImageObject
struct ImageObject: Codable {
    let height: Int?
    let width: Int?
    let url: String
}

struct Track: Codable {
    let id: String
    let name: String
    let duration_ms: Double
    let album: SimplifiedAlbum
    let artists: [SimplifiedArtist]
}

struct SimplifiedAlbum: Codable {
    let id: String
    let name: String
    let images: [ImageObject]? // Add this line if tracks have their own images

}

struct SimplifiedArtist: Codable {
    let id: String
    let name: String
//    let images: [ImageObject]
}
