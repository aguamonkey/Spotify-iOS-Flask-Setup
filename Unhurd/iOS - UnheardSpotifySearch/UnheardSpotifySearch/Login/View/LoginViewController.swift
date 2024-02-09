//
//  LoginViewController.swift
//  UnheardSpotifySearch
//
//  Created by Joshua Browne on 04/02/2024.
//

import UIKit

class LoginViewController: UIViewController {

    private var authViewModel = SpotifyAuthViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black // Change background color to black
        setupSpotifyLogo()
        setupLoginButton()
    }

    private func setupSpotifyLogo() {
        let logoImageView = UIImageView(image: UIImage(named: "SpotifyLogo"))
        logoImageView.contentMode = .scaleAspectFit // Adjust the logo's aspect ratio
        view.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -30), // Adjust positioning as needed
            logoImageView.widthAnchor.constraint(equalToConstant: 150), // Specify a width
            logoImageView.heightAnchor.constraint(equalToConstant: 150) // Specify a height
        ])
    }

    private func setupLoginButton() {
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Log In with Spotify", for: .normal)
        loginButton.setTitleColor(.white, for: .normal) // Set button text color to white
        loginButton.backgroundColor = .clear // Set background color to clear or any color
        loginButton.layer.borderColor = UIColor.white.cgColor // Set border color to white
        loginButton.layer.borderWidth = 1 // Set border width
        loginButton.layer.cornerRadius = 10 // Optional: add corner radius
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)

        view.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 20), // Position below the center
            loginButton.widthAnchor.constraint(equalToConstant: 200), // Specify a width
            loginButton.heightAnchor.constraint(equalToConstant: 50) // Specify a height
        ])
    }

    @objc private func didTapLoginButton() {
        authViewModel.openLoginPage()
    }
}

// This might be called from your SceneDelegate or AppDelegate depending on your URL handling logic
extension LoginViewController {
    func handleAuthCallback(url: URL) {
        print("This is your url in the handleAuthCallback function: \(url)")
        authViewModel.handleAuthCallback(with: url) { [weak self] (success, error) in
            DispatchQueue.main.async {
                if success {
                    self?.navigateToMainAppFlow()
                } else {
                    // Log the error or present an alert to the user
                    print("Login error: \(error?.localizedDescription ?? "Unknown error")")
                    self?.showLoginError()
                }
            }
        }
    }

    private func navigateToMainAppFlow() {
            // Assuming you want to replace the current root view controller with SearchViewController
            if let window = self.view.window {
                let searchViewController = SearchViewController()
                let navigationController = UINavigationController(rootViewController: searchViewController)
                window.rootViewController = navigationController
                window.makeKeyAndVisible()
            }
        }



    private func showLoginError() {
        let alert = UIAlertController(title: "Login Error", message: "Could not authenticate with Spotify.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

