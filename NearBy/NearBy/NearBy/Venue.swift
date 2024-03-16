//
//  Venue.swift
//  NearBy
//
//  Created by Shrey Garg on 16/03/24.
//

import Foundation
import Foundation

struct Venue: Codable, Identifiable {
    let id: Int
    let name: String
    let nameV2: String?
    let city: String?
    let address: String?
    let url: String
    let location: Location
    let state: String?
    let postalCode: String?
    let timezone: String?
    let score: Double
    let country: String
    let hasUpcomingEvents: Bool
    let numUpcomingEvents: Int
    let citySlug: String?
    let extendedAddress: String?
    let popularity: Int
    let capacity: Int?
    let displayLocation: String?

    enum CodingKeys: String, CodingKey {
        case id, name, city, address, url, location, state, country, score, popularity, capacity
        case nameV2 = "name_v2"
        case postalCode = "postal_code"
        case hasUpcomingEvents = "has_upcoming_events"
        case numUpcomingEvents = "num_upcoming_events"
        case citySlug = "slug"
        case extendedAddress = "extended_address"
        case displayLocation = "display_location"
        case timezone
    }
}

struct Location: Codable {
    let lat: Double
    let lon: Double
}

struct VenueResponse: Codable {
    let venues: [Venue]
    let meta: Meta
}

struct Meta: Codable {
    let total: Int
    let took: Int
    let page: Int
    let perPage: Int
    let geolocation: Geolocation

    enum CodingKeys: String, CodingKey {
        case total, took, page
        case perPage = "per_page"
        case geolocation
    }
}

struct Geolocation: Codable {
    let lat: Double
    let lon: Double
    let city: String
    let state: String
    let country: String
    let postalCode: String
    let displayName: String
    let metroCode: String?
    let range: String

    enum CodingKeys: String, CodingKey {
        case lat, lon, city, state, country, range
        case postalCode = "postal_code"
        case displayName = "display_name"
        case metroCode = "metro_code"
    }
}
