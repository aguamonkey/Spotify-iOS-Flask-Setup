//
//  TrackTableViewCell.swift
//  UnheardSpotifySearch
//
//  Created by Joshua Browne on 09/02/2024.
//

import Foundation
import UIKit

class TopTrackTableViewCell: UITableViewCell {
    static let identifier = "TopTrackTableViewCell"

    private let trackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Initialization and layout code
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Add subviews and call setupConstraints()
        contentView.addSubview(trackImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(durationLabel)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // Initialization and layout code

    private func setupConstraints() {
        // Constraints for trackImageView
        NSLayoutConstraint.activate([
            trackImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            trackImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            trackImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            trackImageView.widthAnchor.constraint(equalToConstant: 60)
        ])

        // Constraints for trackNameLabel
        NSLayoutConstraint.activate([
            trackNameLabel.leadingAnchor.constraint(equalTo: trackImageView.trailingAnchor, constant: 10),
            trackNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            trackNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: durationLabel.leadingAnchor, constant: -10)
        ])

        // Constraints for durationLabel
        NSLayoutConstraint.activate([
            durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            durationLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        // Optional: Constraints for the durationLabel to have a fixed width if needed
        durationLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        durationLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    
    func configure(with track: Track) {
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
