//
//  VenueRepository.swift
//  NearBy
//
//  Created by Shrey Garg on 16/03/24.
//

import Foundation

protocol VenueFetching {
    func fetchVenues(latitude: Double, longitude: Double, page: Int, query: String?, completion: @escaping (Result<[Venue], Error>) -> Void)
}


class VenueService : VenueFetching {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }
    
    
    func fetchVenues(latitude: Double, longitude: Double, page: Int, query: String? = nil, completion: @escaping (Result<[Venue], Error>) -> Void) {
       
        var components = URLComponents(string: "https://api.seatgeek.com/2/venues")!
        
        var queryItems = [
            URLQueryItem(name: "client_id", value: "Mzg0OTc0Njl8MTcwMDgxMTg5NC44MDk2NjY5"),
            URLQueryItem(name: "lat", value: "\(latitude)"),
            URLQueryItem(name: "lon", value: "\(longitude)"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        if let query = query, !query.isEmpty {
            queryItems.append(URLQueryItem(name: "q", value: query))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        networkService.request(url) { (result: Result<VenueResponse, Error>) in
            switch result {
            case .success(let venueResponse):
                completion(.success(venueResponse.venues))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
