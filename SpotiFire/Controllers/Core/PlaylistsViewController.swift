//
//  PlaylistsViewController.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 25/08/2022.
//

import UIKit

class PlaylistsViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    let searchController: UISearchController = {
        let vc = UISearchController(searchResultsController: PlaylistSearchResultsViewController())
        vc.searchBar.placeholder = "Search for playlists..."
        vc.searchBar.searchBarStyle = .minimal
        vc.definesPresentationContext = true
        return vc
    }()

    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
        return PlaylistsViewController.createSectionLayout(section: sectionIndex)
        }
    )

    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        spinner.frame = CGRect(x: (UIScreen.main.bounds.width/2)-75, y: (UIScreen.main.bounds.height/2)-75, width: 150, height: 150)
        spinner.startAnimating()
        return spinner
    }()
    
    private var playlistsSection = [PlaylistCellViewModel]()
    private var newUserPlaylists: [Playlist] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGray6
        configureCollectionView()
        view.addSubview(spinner)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        fetchPlaylists()
    }
    
    private func fetchPlaylists() {
        let group = DispatchGroup()
        group.enter()
        var userPlaylists: UserPlaylistsResponse?
        APICaller.shared.getUserPlaylists(limit: 50) { result in
            defer {
                group.leave()
            }
            switch result {
            case.success(let model):
                userPlaylists = model
            case.failure(let error):
                HapticsManager.shared.vibrate(for: .warning)
                let alert = UIAlertController(
                    title: "Alert",
                    message: "Failed to load data",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
                self.present(alert, animated: true)
                print(error.localizedDescription)
            }
        }
        group.notify(queue: .main) {
            self.newUserPlaylists = userPlaylists?.items ?? []
            self.configureModel(playlists: self.newUserPlaylists)
            if self.newUserPlaylists.count < 1 {
                HapticsManager.shared.vibrate(for: .warning)
                let alert = UIAlertController(
                    title: "Alert",
                    message: "No playlists found",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
            self.spinner.stopAnimating()
        }
    }
    
    private func configureModel(
        playlists: [Playlist]
    ) {
        playlistsSection.append(contentsOf: playlists.compactMap({
            return PlaylistCellViewModel(
                image: URL(string: $0.images.first?.url ?? ""),
                name: $0.name,
                owner: $0.owner.display_name,
                description: $0.description,
                id: $0.id
            )
        }))
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let resultsController = searchController.searchResultsController as? PlaylistSearchResultsViewController,
              let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        APICaller.shared.search(query: query, search_type: "playlist") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    resultsController.update(with: model)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.register(
            UserPlaylistsCollectionViewCell.self,
            forCellWithReuseIdentifier: UserPlaylistsCollectionViewCell.identifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemGray6
    }

    private static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
        // Item
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )

        item.contentInsets = NSDirectionalEdgeInsets(
            top: 15,
            leading: 22,
            bottom: 15,
            trailing: 22
        )

        // Group
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
//                heightDimension: .absolute(235)
                heightDimension: .absolute((UIScreen.main.bounds.width/2)+37)
            ),
            subitem: item,
            count: 2
        )

        // Section
        let section = NSCollectionLayoutSection(group: horizontalGroup)
        return section
    }

}

extension PlaylistsViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlistsSection.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UserPlaylistsCollectionViewCell.identifier,
            for: indexPath
        ) as? UserPlaylistsCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: playlistsSection[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let playlist = newUserPlaylists[indexPath.row]
        let vc = PlaylistDetailsViewController(playlist: playlist)
        vc.title = playlist.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

