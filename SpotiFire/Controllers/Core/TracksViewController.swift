//
//  TracksViewController.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 25/08/2022.
//

import UIKit

class TracksViewController: UIViewController {
    
    private let likedTracksButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue.withAlphaComponent(0.9)
        button.setTitle("Liked Tracks", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        return button
    }()
    
    private let topTracksButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue.withAlphaComponent(0.9)
        button.setTitle("Top Tracks", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        return button
    }()
    
    private let recentlyPlayedButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue.withAlphaComponent(0.9)
        button.setTitle("Recently Played", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGray6
        likedTracksButton.addTarget(self, action: #selector(likedTracksAction), for: .touchUpInside)
        topTracksButton.addTarget(self, action: #selector(topTracksAction), for: .touchUpInside)
        recentlyPlayedButton.addTarget(self, action: #selector(recentlyPlayedAction), for: .touchUpInside)
        view.addSubview(likedTracksButton)
        view.addSubview(topTracksButton)
        view.addSubview(recentlyPlayedButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let squareSize = view.width/3
        let gapSize = squareSize/3
        let yStartPosition = view.height/4
        likedTracksButton.frame = CGRect(
            x: gapSize,
            y: yStartPosition,
            width: 2*squareSize+gapSize,
            height: squareSize
        )
        topTracksButton.frame = CGRect(
            x: gapSize,
            y: likedTracksButton.frame.origin.y+squareSize+gapSize,
            width: 2*squareSize+gapSize,
            height: squareSize
        )
        recentlyPlayedButton.frame = CGRect(
            x: gapSize,
            y: topTracksButton.frame.origin.y+squareSize+gapSize,
            width: 2*squareSize+gapSize,
            height: squareSize
        )
    }
    
    @objc private func likedTracksAction() {
        let vc = LikedTracksViewController()
        vc.title = "Liked Tracks"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func topTracksAction() {
        let vc = TopTracksViewController()
        vc.title = "Top Tracks"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func recentlyPlayedAction() {
        let vc = RecentlyPlayedViewController()
        vc.title = "Recently Played"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
