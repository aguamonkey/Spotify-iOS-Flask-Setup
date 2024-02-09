//
//  ViewController.swift
//  UnheardSpotifySearch
//
//  Created by Joshua Browne on 02/02/2024.
//

import UIKit

class SearchViewController: UIViewController {
    
    private var searchViewModel = SpotifySearchViewModel()
    let searchBar = UISearchBar()
    let tableView = UITableView()
    
    // Add a timer property to debounce search requests
    private var searchDebounceTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        observeViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupSearchBar()
        setupTableView()
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search for an artist"
        navigationItem.titleView = searchBar
    }
    
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ArtistTableViewCell.self, forCellReuseIdentifier: ArtistTableViewCell.identifier)

        // Remove the old UITableViewCell registration as it's no longer needed
        // tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200 // Provide a reasonable estimate for your cell's height

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false // Use Auto Layout
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        ])
        tableView.backgroundColor = .black
    }

    
    private func observeViewModel() {
        searchViewModel.artists.bind { [weak self] _ in
            self?.tableView.reloadData()
        }
        searchViewModel.errorMessage.bind { [weak self] message in
            guard let message = message else { return }
            self?.showError(message: message ?? "You're fucked")
        }
    }

    private func showError(message: String) {
        // Check if the message is a technical one and replace it with a generic message
        let genericErrorMessage = "There was an issue retrieving the data. Please try again."
        let displayMessage = (message == "The data couldn’t be read because it is missing." ? genericErrorMessage : message)
        
        let alert = UIAlertController(title: "Error", message: displayMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Invalidate the previous timer when the text changes
        searchDebounceTimer?.invalidate()
        
        // Set up a new timer with a 0.5 second delay
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
            self?.searchViewModel.searchArtists(query: searchText)
        })
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Perform the search and dismiss the keyboard when the user taps the search button
        searchBar.resignFirstResponder()
        if let query = searchBar.text, !query.isEmpty {
            searchViewModel.searchArtists(query: query)
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchViewModel.artists.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArtistTableViewCell.identifier, for: indexPath) as? ArtistTableViewCell, let artist = searchViewModel.artists.value?[indexPath.row] else {
            fatalError("Could not dequeue ArtistTableViewCell")
        }
        cell.configure(with: artist)
        return cell
    }

}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let artist = searchViewModel.artists.value?[indexPath.row] else {
            return
        }
        
        // Use SpotifyAPIClient.shared as the apiClient parameter
        let artistDetailViewModel = ArtistDetailViewModel(apiClient: SpotifyAPIClient.shared)
        let artistDetailViewController = ArtistDetailViewController()
        
        // Assign the newly created viewModel with the apiClient to the artistDetailViewController
        artistDetailViewController.viewModel = artistDetailViewModel
        
        // Set artist ID for detail view model
        artistDetailViewModel.fetchArtistDetails(artistId: artist.id)
        
        // Present artist detail view controller
        navigationController?.pushViewController(artistDetailViewController, animated: true)
    }
}

