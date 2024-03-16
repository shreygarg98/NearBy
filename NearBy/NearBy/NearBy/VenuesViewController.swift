//
//  VenuesViewController.swift
//  NearBy
//
//  Created by Shrey Garg on 16/03/24.
//

import UIKit
import CoreLocation

class VenuesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var distanceSlider: UISlider!
    var activityIndicator: UIActivityIndicatorView!
    
    var locationManager = CLLocationManager()
    var userLocation: CLLocation?
    
    var viewModel = VenueViewModel()
    var allVenues: [Venue] = [] {
        didSet {
            // When allVenues updates, reset the filter to show all venues.
            filteredVenues = allVenues
        }
    }
    var filteredVenues: [Venue] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSearchBar()
        setupDistanceSlider()
        bindViewModel()
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        let hasCachedData = viewModel.loadVenuesFromCache()
        if hasCachedData {
            viewModel.showLoader = false
        }
        configureLocationServices()
        viewModel.loadVenues(latitude: 12.971599, longitude: 77.594566)
        
    }
    
    private func setupDistanceSlider() {
        distanceSlider.minimumValue = 0 // Set to your minimum distance
        distanceSlider.maximumValue = 100 // Set to your maximum distance
        distanceSlider.value = 0 // Set to default/start value
        distanceSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        
    }
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search Venues"
        // Additional search bar setup if needed
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Hide the keyboard
        if let searchText = searchBar.text, !searchText.isEmpty {
            viewModel.searchVenues(latitude: 12.971599, longitude: 77.594566, query: searchText)
        }
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.registerTableCells(VenueTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame = view.bounds
    }
    
    private func bindViewModel() {
        viewModel.didUpdateVenues = { [weak self] venues in
            self?.allVenues = venues
            self?.tableView.reloadData()
        }
        
        viewModel.isLoadingChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        let filterDistance = sender.value
        print("Slider value: \(filterDistance)")
        
        filteredVenues = allVenues.filter { venue in
            let distanceToVenue = calculateDistanceToVenue(venue)
            print("Distance to venue: \(distanceToVenue) km")
            return distanceToVenue <= Double(filterDistance)
        }
        filteredVenues = allVenues
    }
    func calculateDistanceToVenue(_ venue: Venue) -> Double {
        guard let userLocation = userLocation else { return Double.greatestFiniteMagnitude }
        let venueLocation = CLLocation(latitude: venue.location.lat, longitude: venue.location.lon)
        return userLocation.distance(from: venueLocation)
    }
    func calculateDistance(_ fromLocation: CLLocation, _ toLocation: CLLocation) -> CLLocationDistance {
        return fromLocation.distance(from: toLocation)
    }
}

extension VenuesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredVenues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VenueTableViewCell", for: indexPath) as? VenueTableViewCell else {
            return UITableViewCell()
        }
        let venue = filteredVenues[indexPath.row]
        cell.configure(with: venue)
        
        
        let nearBottom = indexPath.row >= filteredVenues.count - 4
        if nearBottom && !viewModel.getIsLoading && viewModel.getcanLoadMore {
            viewModel.loadVenues(latitude: 12.971599, longitude: 77.594566)
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let venue = viewModel.venues[indexPath.row]
        guard let url = URL(string: venue.url) else {
            print("Invalid URL")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension VenuesViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Optional: Implement a debounce/throttle mechanism to limit requests while typing
        viewModel.searchVenues(latitude: 12.971599, longitude: 77.594566, query: searchText)
    }
    
}

extension VenuesViewController: CLLocationManagerDelegate {
    
    private func configureLocationServices() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // or requestAlwaysAuthorization(), depending on your needs
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            userLocation = location
        }
    }
    
}
