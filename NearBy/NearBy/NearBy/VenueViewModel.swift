//
//  VenueViewModel.swift
//  NearBy
//
//  Created by Shrey Garg on 16/03/24.
//

import Foundation

class VenueViewModel {
    var venues: [Venue] = [] {
        didSet { didUpdateVenues?(self.venues) }
    }
    var didUpdateVenues: (([Venue]) -> Void)?
    var didEncounterError: ((Error) -> Void)?
    
    private let venueService: VenueFetching
    private var currentPage = 1
    private var isLoading = false
    private var canLoadMore = true
    var isLoadingChanged: ((Bool) -> Void)?
    
    var getIsLoading: Bool {
        return isLoading
    }
    var showLoader  = true
    var getcanLoadMore: Bool {
        return canLoadMore
    }
    init(venueService: VenueFetching = VenueService()) {
        self.venueService = venueService
    }
}

extension VenueViewModel {
    func searchVenues(latitude: Double, longitude: Double, query: String) {
        reset()
        loadVenues(latitude: latitude, longitude: longitude, query: query)
    }
    
    func loadVenues(latitude: Double, longitude: Double, query: String? = nil) {
        guard !isLoading && canLoadMore else { return }
        isLoading = true
        if showLoader{
            isLoadingChanged?(true)
        }else{
            showLoader = true
        }
        venueService.fetchVenues(latitude: latitude, longitude: longitude, page: currentPage, query: query) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            self.isLoadingChanged?(false)
            
            switch result {
            case .success(let venues):
                self.venues.append(contentsOf: venues)
                self.currentPage += 1
                self.canLoadMore = !venues.isEmpty
                self.saveVenuesToCache()
            case .failure(let error):
                self.didEncounterError?(error)
            }
        }
    }
    
    func reset() {
        venues = []
        currentPage = 1
        isLoading = false
        canLoadMore = true
    }
    func saveVenuesToCache() {
        let encoder = JSONEncoder()
        if let encodedVenues = try? encoder.encode(venues) {
            UserDefaults.standard.set(encodedVenues, forKey: "cachedVenues")
        }
    }
    
    func loadVenuesFromCache() -> Bool {
        let decoder = JSONDecoder()
        if let savedVenues = UserDefaults.standard.object(forKey: "cachedVenues") as? Data,
           let decodedVenues = try? decoder.decode([Venue].self, from: savedVenues) {
            self.venues = decodedVenues
            return true
        }
        return false
    }
}
