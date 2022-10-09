//
//  SuccessViewController.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 04/09/2022.
//

import UIKit

class SuccessViewController: UIViewController {

    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 28, weight: .semibold)
        label.text = "Task accomplished with success!"
        return label
    }()
    
    private let backHomeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue.withAlphaComponent(0.9)
        button.setTitle("Back Home", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        return button
    }()
    
    private let openSpotifyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue.withAlphaComponent(0.9)
        button.setTitle("Open Spotify", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        title = "Success"
        view.backgroundColor = .systemGray6
        view.addSubview(label)
        view.addSubview(backHomeButton)
        view.addSubview(openSpotifyButton)
        backHomeButton.addTarget(self, action: #selector(backHomeAction), for: .touchUpInside)
        openSpotifyButton.addTarget(self, action: #selector(openSpotifyAction), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backHomeButton.frame = CGRect(
            x: 30,
            y: view.height-40-view.safeAreaInsets.bottom,
            width: (view.width-50)/2.5,
            height: 40
        )
        openSpotifyButton.frame = CGRect(
            x: view.width-30-backHomeButton.width,
            y: view.height-40-view.safeAreaInsets.bottom,
            width: (view.width-50)/2.5,
            height: 40
        )
        label.frame = CGRect(x: 30, y: view.height/3, width: view.width-60, height: 300)
    }

    @objc func backHomeAction() {
        DispatchQueue.main.async {
            let navVC = UINavigationController(rootViewController: HomeViewController())
            navVC.navigationBar.prefersLargeTitles = true
            navVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
            navVC.modalPresentationStyle = .fullScreen
            self.present(navVC, animated: true, completion: {
                self.navigationController?.popToRootViewController(animated: false)
            })
        }
    }
    
    @objc func openSpotifyAction() {
        let spotifyHooks = "spotify://"
        let spotifyUrl = URL(string: spotifyHooks)!
        if UIApplication.shared.canOpenURL(spotifyUrl) {
            UIApplication.shared.open(spotifyUrl)
        }
        else {
            UIApplication.shared.open(URL(string: "https://spotify.com/")!)
        }
    }
}
