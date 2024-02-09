//
//  ArtistViewController.swift
//  UnheardSpotifySearch
//
//  Created by Joshua Browne on 07/02/2024.
//

import Foundation

import UIKit

class ArtistDetailViewController: UIViewController, UICollectionViewDelegate {
    // MARK: - Properties
    var viewModel: ArtistDetailViewModel!
    
    private var collectionView: UICollectionView!
    
    // UI Elements
    private let artistImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let genreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let topTracksTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.text = "Top 5 Tracks"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        bindViewModel()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(artistImageView)
        NSLayoutConstraint.activate([
            artistImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            artistImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            artistImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
     
            artistImageView.widthAnchor.constraint(equalToConstant: 150),
            artistImageView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        view.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: artistImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        view.addSubview(genreLabel)
        NSLayoutConstraint.activate([
            genreLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            genreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            genreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            genreLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        view.addSubview(topTracksTitleLabel)
        NSLayoutConstraint.activate([
            topTracksTitleLabel.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: 20),
            topTracksTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            topTracksTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width - 40, height: 450) // Adjust size as needed
        layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .black
        collectionView.register(TrackCollectionViewCell.self, forCellWithReuseIdentifier: TrackCollectionViewCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topTracksTitleLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    
    
    // MARK: - View Model Binding
    private func bindViewModel() {
        
        viewModel.artist.bind { [weak self] artist in
            if let artist = artist {
                self?.updateUI(with: artist)
                
            }
        }
        
        viewModel.topTracks.bind { [weak self] tracks in
            
            DispatchQueue.main.async {
                self?.collectionView.reloadData()

                guard let unwrappedTracks = tracks else {
                    print("No tracks found")
                    return
                }

                // Reset the topTracks array for each binding call to avoid accumulation across multiple bind calls
                var topTracks = [String]()

                // Append each track's name to the topTracks array
                unwrappedTracks!.forEach { track in
                    print("Track ID: \(track.id), Track Name: \(track.name)")
                    print("Track image \(String(describing: track.album.images)), Track duration: \(track.duration_ms)")
                    topTracks.append(track.name)
                }
                
                // Join the track names in the topTracks array with newlines and update the text view
                _ = topTracks.joined(separator: "\n")
                self?.topTracksTitleLabel.text = "Top 5 Tracks"
            }
        }

        viewModel.errorMessage.bind { errorMessage in
            if let errorMessage = errorMessage {
                // Display error message to user if needed
                print("This is your error message -> \(String(describing: errorMessage))")
            }
        }
    }
    
    // MARK: - Update UI
    private func updateUI(with artist: Artist?) {
        guard let artist = artist else {
            // Handle case where artist is nil (optional chaining)
            return
        }
        
        // Update image view
        if let imageUrl = artist.images.first?.url {
            artistImageView.loadImage(fromURL: imageUrl)
        }
        
        // Update labels
        nameLabel.text = artist.name
        genreLabel.text = artist.genres.joined(separator: ", ")
    }
    
}

extension ArtistDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.topTracks.value??.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackCollectionViewCell.identifier, for: indexPath) as? TrackCollectionViewCell,
              let track = viewModel.topTracks.value??[indexPath.row] else {
            fatalError("Could not dequeue TrackCollectionViewCell")
        }
        cell.configure(with: track, at: indexPath.item) // Pass the index of the track
        return cell
    }
    
    // Implement other UICollectionViewDataSource methods as needed...
}
