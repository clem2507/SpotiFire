//
//  NewReleasesViewController.swift
//  SpotiFire
//
//  Created by Clement Detry on 14/09/2022.
//

import UIKit

class NewReleasesViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    let searchController: UISearchController = {
        let vc = UISearchController(searchResultsController: AlbumSearchResultsViewController())
        vc.searchBar.placeholder = "Search for albums..."
        vc.searchBar.searchBarStyle = .minimal
        vc.definesPresentationContext = true
        return vc
    }()

    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
        return NewReleasesViewController.createSectionLayout(section: sectionIndex)
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
    
    private var albumsSection = [AlbumCellViewModel]()
    private var newUserReleases: [Album] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGray6
        configureCollectionView()
        view.addSubview(spinner)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        fetchAlbums()
    }
    
    private func fetchAlbums() {
        let group = DispatchGroup()
        group.enter()
        var newReleases: NewReleasesResponse?
        APICaller.shared.getNewReleases(limit: 50) { result in
            defer {
                group.leave()
            }
            switch result {
            case.success(let model):
                newReleases = model
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
            self.newUserReleases = newReleases?.albums.items ?? []
            self.configureModel(albums: self.newUserReleases)
            if self.newUserReleases.count < 1 {HapticsManager.shared.vibrate(for: .warning)
                let alert = UIAlertController(
                    title: "Alert",
                    message: "No albums found",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
            self.spinner.stopAnimating()
        }
    }
    
    private func configureModel(
        albums: [Album]
    ) {
        albumsSection.append(contentsOf: albums.compactMap({
            return AlbumCellViewModel(
                image: URL(string: $0.images.first?.url ?? ""),
                name: $0.name,
                artistName: $0.artists.first?.name ?? "-"
            )
        }))
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let resultsController = searchController.searchResultsController as? AlbumSearchResultsViewController,
              let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        APICaller.shared.search(query: query, search_type: "album") { result in
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
            UserAlbumsCollectionViewCell.self,
            forCellWithReuseIdentifier: UserAlbumsCollectionViewCell.identifier
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

extension NewReleasesViewController: UICollectionViewDelegate, UICollectionViewDataSource {

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
        let album = AlbumsResponse(album: newUserReleases[indexPath.row])
        let vc = AlbumDetailsViewController(album: album)
        vc.title = album.album.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
