//
//  PlaylistSearchResultsViewController.swift
//  SpotiFire
//
//  Created by Clement Detry on 12/09/2022.
//

import UIKit

class PlaylistSearchResultsViewController: UIViewController {
    
    private var results: SearchResultsResponse?
    private var playlistsSection = [PlaylistCellViewModel]()
    private var selectedItemsIndexPath = [IndexPath]()
    private var selectedItemsID = [String]()
    
    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
        return PlaylistSearchResultsViewController.createSectionLayout(section: sectionIndex)
        }
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray6
        configureCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    func update(with results: SearchResultsResponse) {
        self.playlistsSection = [PlaylistCellViewModel]()
        self.results = results
        self.configureModel(playlists: results.playlists ?? SearchPlaylistsResponse(items: [Playlist(description: "", external_urls: [:], id: "", images: [], name: "", owner: User(display_name: "", external_urls: [:], id: ""))]))
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
        collectionView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.interactive
    }
    
    private func configureModel(
        playlists: SearchPlaylistsResponse
    ) {
        playlistsSection.append(contentsOf: playlists.items.compactMap({
            return PlaylistCellViewModel(
                image: URL(string: $0.images.first?.url ?? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPkmVTIf2hLA9GiWjgOfWTgTO7_KJaQcUv0mmvbzUA3pmOvuIlRpuZ-uY9th-2hFQ2yCY&usqp=CAU"),
                name: $0.name,
                owner: $0.owner.display_name,
                description: $0.description,
                id: $0.id
            )
        }))
        if playlistsSection.count < 1 {
            HapticsManager.shared.vibrate(for: .warning)
            let alert = UIAlertController(
                title: "Alert",
                message: "No playlists found",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
        collectionView.reloadData()
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

extension PlaylistSearchResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource {

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
        let playlist = results?.playlists?.items[indexPath.row]
        let vc = PlaylistDetailsViewController(playlist: playlist ?? Playlist(description: "", external_urls: [:], id: "", images: [], name: "", owner: User(display_name: "", external_urls: [:], id: "")))
        vc.title = playlist?.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

