//
//  TrackCollectionViewCell.swift
//  UnheardSpotifySearch
//
//  Created by Joshua Browne on 09/02/2024.
//

import Foundation
import UIKit

class TrackCollectionViewCell: UICollectionViewCell {
    static let identifier = "TrackCollectionViewCell"
    
    private let trackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(trackImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(durationLabel)
        
        let constraints = [
            trackImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackImageView.heightAnchor.constraint(equalTo: trackImageView.widthAnchor),
            
            trackNameLabel.topAnchor.constraint(equalTo: trackImageView.bottomAnchor, constant: 8),
            trackNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            durationLabel.topAnchor.constraint(equalTo: trackNameLabel.bottomAnchor, constant: 4),
            durationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            durationLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
            
            
        ]
        
        NSLayoutConstraint.activate(constraints)
    }

    func configure(with track: Track, at index: Int) {
        guard index < 5 else {
            // Hide or reset the UI elements if the index is greater than or equal to 5
            trackNameLabel.text = nil
            durationLabel.text = nil
            trackImageView.image = nil
            return
        }
        
        trackNameLabel.text = track.name

        // Use truncatingRemainder for floating point numbers
        let minutes = Int(track.duration_ms / 60000)
        let seconds = Int((track.duration_ms.truncatingRemainder(dividingBy: 60000)) / 1000)
        durationLabel.text = String(format: "%d:%02d", minutes, seconds)
        
        trackImageView.image = UIImage(named: "placeholder") // Use your placeholder image
        
        if let imageUrlString = track.album.images?.first?.url {
            trackImageView.loadImage(fromURL: imageUrlString)
        } else {
            print("No track image URL provided.")
        }
    }

}
