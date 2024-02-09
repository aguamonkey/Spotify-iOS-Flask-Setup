//
//  ArtistTableViewCell.swift
//  UnheardSpotifySearch
//
//  Created by Joshua Browne on 07/02/2024.
//

import Foundation
import UIKit

class ArtistTableViewCell: UITableViewCell {
    static let identifier = "ArtistTableViewCell"

    // Add UI components such as an UIImageView for the artist's image and UILabels for the name and genres.
    private let artistImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10 // Optional: for rounded corners
        // Set up imageView constraints or positioning
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        // Customize label (font, color, etc.)
        label.textColor = .white
        return label
    }()

    private let genreLabel: UILabel = {
        let label = UILabel()
        // Customize label (font, color, etc.)
        label.textColor = .white
        return label
    }()

    // Initialization and layout code
     override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)
         // Add artistImageView, nameLabel, and genreLabel to the cell's view hierarchy
         contentView.backgroundColor = .black
         contentView.addSubview(artistImageView)
         contentView.addSubview(nameLabel)
         contentView.addSubview(genreLabel)

         // Call a method to set up constraints
         setupConstraints()
     }

     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }

     private func setupConstraints() {
         // Set up imageView constraints
         artistImageView.translatesAutoresizingMaskIntoConstraints = false
         NSLayoutConstraint.activate([
             artistImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
             artistImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
             artistImageView.widthAnchor.constraint(equalToConstant: 60),
             artistImageView.heightAnchor.constraint(equalTo: artistImageView.widthAnchor),
             artistImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)

         ])
         
         // Set up nameLabel constraints
         nameLabel.translatesAutoresizingMaskIntoConstraints = false
         NSLayoutConstraint.activate([
             nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
             nameLabel.leadingAnchor.constraint(equalTo: artistImageView.trailingAnchor, constant: 10),
             nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
         ])
         
         // Set up genreLabel constraints
         genreLabel.translatesAutoresizingMaskIntoConstraints = false
         NSLayoutConstraint.activate([
             genreLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
             genreLabel.leadingAnchor.constraint(equalTo: artistImageView.trailingAnchor, constant: 10),
             genreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
             genreLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
         ])
         
         nameLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
         genreLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)

         nameLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
         genreLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)

     }

    // Function to configure cell with artist data
    func configure(with artist: Artist) {
        nameLabel.text = artist.name
        genreLabel.text = artist.genres.joined(separator: ", ")
        
        // Use a placeholder image immediately while the real image loads
        artistImageView.image = UIImage(named: "placeholder") // Use your placeholder image
        
        if let imageUrl = artist.images.first?.url {
            artistImageView.loadImage(fromURL: imageUrl)
        } else {
            print("No image URL provided.")
        }
    }
 }

extension UIImageView {
    private static let imageCache = NSCache<NSString, UIImage>()
    // Define a static constant key as a property
    private static var currentImageLoadTaskKey: UInt8 = 0
    
    func loadImage(fromURL urlString: String, placeholderImageName: String = "placeholder") {
         self.image = UIImage(named: placeholderImageName)
         guard let url = URL(string: urlString) else {
             print("Invalid URL: \(urlString)")
             return
         }

         // Use your existing image loading logic here
         let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
             guard let data = data, error == nil, let image = UIImage(data: data) else {
                 print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                 return
             }
             DispatchQueue.main.async {
                 self?.image = image
             }
         }
         task.resume()
     }
    
    // Use the address of the static key as an UnsafeRawPointer
    private var currentImageLoadTask: URLSessionDataTask? {
        get {
            return objc_getAssociatedObject(self, &UIImageView.currentImageLoadTaskKey) as? URLSessionDataTask
        }
        set(task) {
            objc_setAssociatedObject(self, &UIImageView.currentImageLoadTaskKey, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    // Cancel the current image loading task if it's not finished
    func cancelImageLoad() {
        self.currentImageLoadTask?.cancel()
        self.currentImageLoadTask = nil
    }
}

private struct AssociatedKeys {
    static var currentImageLoadTask = "currentImageLoadTask"
}
