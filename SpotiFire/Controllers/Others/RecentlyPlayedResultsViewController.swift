//
//  RecentlyPlayedResultsViewController.swift
//  SpotiFire
//
//  Created by Clement Detry on 12/09/2022.
//

import UIKit

class RecentlyPlayedResultsViewController: UIViewController {
    
    private var results: SearchResultsResponse?
    private var recentlyPlayedSection = [TrackCellViewModel]()
    
    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
        return RecentlyPlayedResultsViewController.createSectionLayout(section: sectionIndex)
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
        self.recentlyPlayedSection = [TrackCellViewModel]()
        self.results = results
        self.configureModel(tracks: results.tracks ?? SearchTracksResponse(items: [Track(external_urls: [:], id: "", name: "", artists: [TrackArtist(id: "", name: "", type: "", external_urls: [:])], album: TrackAlbum(album_type: "", id: "", images: [APIImage(url: "")], name: ""))]))
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.register(
            UserTracksCollectionViewCell.self,
            forCellWithReuseIdentifier: UserTracksCollectionViewCell.identifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemGray6
        collectionView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.interactive
    }
    
    private func configureModel(
        tracks: SearchTracksResponse
    ) {
        recentlyPlayedSection.append(contentsOf: tracks.items.compactMap({
            return TrackCellViewModel(
                image: URL(string: $0.album.images.first?.url ?? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSzEfl1wJh3z4Q15MbA5NEojwepCj3WvvrMYZdWQQt-1GZXH_RhIk3oDmgjvDz_0uKRVks&usqp=CAU"),
                track_name: $0.name,
                artist_name: $0.artists.first?.name ?? "",
                album_name: $0.album.name,
                id: $0.id
            )
        }))
        if recentlyPlayedSection.count < 1 {
            HapticsManager.shared.vibrate(for: .warning)
            let alert = UIAlertController(
                title: "Alert",
                message: "No tracks found",
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
            top: 8,
            leading: 22,
            bottom: 8,
            trailing: 22
        )

        // Group
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(80)
            ),
            subitem: item,
            count: 1
        )

        // Section
        let section = NSCollectionLayoutSection(group: horizontalGroup)
        return section
    }
}

extension RecentlyPlayedResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recentlyPlayedSection.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UserTracksCollectionViewCell.identifier,
            for: indexPath
        ) as? UserTracksCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: recentlyPlayedSection[indexPath.row])
        collectionView.allowsMultipleSelection = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        if RecentlyPlayedViewController.selectedItems.count > 4 {
            HapticsManager.shared.vibrate(for: .warning)
            let alert = UIAlertController(title: "Alert", message: "You cannot select more than 5 tracks!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
            present(alert, animated: true)
            self.collectionView.reloadItems(at: [indexPath])
        }
        else {
            RecentlyPlayedViewController.selectedItems[recentlyPlayedSection[indexPath.row].id] = (recentlyPlayedSection[indexPath.row].track_name, indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        if RecentlyPlayedViewController.selectedItems.keys.contains(recentlyPlayedSection[indexPath.row].id) {
            RecentlyPlayedViewController.selectedItems.removeValue(forKey: recentlyPlayedSection[indexPath.row].id)
        }
    }
}
