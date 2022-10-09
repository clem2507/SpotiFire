//
//  AlbumSearchResultsViewController.swift
//  SpotiFire
//
//  Created by Clement Detry on 12/09/2022.
//

import UIKit

class AlbumSearchResultsViewController: UIViewController {
    
    private var results: SearchResultsResponse?
    private var albumsSection = [AlbumCellViewModel]()
    private var selectedItemsIndexPath = [IndexPath]()
    private var selectedItemsID = [String]()
    
    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
        return AlbumSearchResultsViewController.createSectionLayout(section: sectionIndex)
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
        self.albumsSection = [AlbumCellViewModel]()
        self.results = results
        self.configureModel(albums: results.albums ?? SearchAlbumsResponse(items: [Album(album_type: "", id: "", images: [APIImage(url: "")], name: "", artists: [AlbumArtist(id: "", name: "", type: "", external_urls: [:])])]))
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.register(
            UserAlbumsCollectionViewCell.self,
            forCellWithReuseIdentifier: UserAlbumsCollectionViewCell.identifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemGray6
        collectionView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.interactive
    }
    
    private func configureModel(
        albums: SearchAlbumsResponse
    ) {
        albumsSection.append(contentsOf: albums.items.compactMap({
            return AlbumCellViewModel(
                image: URL(string: $0.images.first?.url ?? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPkmVTIf2hLA9GiWjgOfWTgTO7_KJaQcUv0mmvbzUA3pmOvuIlRpuZ-uY9th-2hFQ2yCY&usqp=CAU"),
                name: $0.name,
                artistName: $0.artists.first?.name ?? ""
            )
        }))
        if albumsSection.count < 1 {
            HapticsManager.shared.vibrate(for: .warning)
            let alert = UIAlertController(
                title: "Alert",
                message: "No albums found",
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

extension AlbumSearchResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumsSection.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UserAlbumsCollectionViewCell.identifier,
            for: indexPath
        ) as? UserAlbumsCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: albumsSection[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let album = results?.albums?.items[indexPath.row]
        let vc = AlbumDetailsViewController(album: AlbumsResponse(album: album ?? Album(album_type: "", id: "", images: [APIImage(url: "")], name: "", artists: [AlbumArtist(id: "", name: "", type: "", external_urls: [:])])))
        vc.title = album?.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

