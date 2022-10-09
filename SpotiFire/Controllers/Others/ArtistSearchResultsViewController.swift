//
//  ArtistSearchResultsViewController.swift
//  SpotiFire
//
//  Created by Clement Detry on 12/09/2022.
//

import UIKit

class ArtistSearchResultsViewController: UIViewController {
    
    private var results: SearchResultsResponse?
    private var artistsSection = [ArtistCellViewModel]()
    
    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
        return ArtistSearchResultsViewController.createSectionLayout(section: sectionIndex)
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
        self.artistsSection = [ArtistCellViewModel]()
        self.results = results
        self.configureModel(artists: results.artists ?? SearchArtistsResponse(items: [Artist(id: "", name: "", type: "", external_urls: [:], images: [])]))
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.register(
            UserArtistsCollectionViewCell.self,
            forCellWithReuseIdentifier: UserArtistsCollectionViewCell.identifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemGray6
        collectionView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.interactive
    }
    
    private func configureModel(
        artists: SearchArtistsResponse
    ) {
        artistsSection.append(contentsOf: artists.items.compactMap({
            return ArtistCellViewModel(
                image: URL(string: $0.images.first?.url ?? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSzEfl1wJh3z4Q15MbA5NEojwepCj3WvvrMYZdWQQt-1GZXH_RhIk3oDmgjvDz_0uKRVks&usqp=CAU"),
                name: $0.name,
                id: $0.id
            )
        }))
        if artistsSection.count < 1 {
            HapticsManager.shared.vibrate(for: .warning)
            let alert = UIAlertController(
                title: "Alert",
                message: "No artists found",
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
                heightDimension: .absolute((UIScreen.main.bounds.width/2)+17)
            ),
            subitem: item,
            count: 2
        )

        // Section
        let section = NSCollectionLayoutSection(group: horizontalGroup)
        return section
    }
}

extension ArtistSearchResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artistsSection.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UserArtistsCollectionViewCell.identifier,
            for: indexPath
        ) as? UserArtistsCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: artistsSection[indexPath.row])
        collectionView.allowsMultipleSelection = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        if ArtistsViewController.selectedItems.count > 4 {
            HapticsManager.shared.vibrate(for: .warning)
            let alert = UIAlertController(title: "Alert", message: "You cannot select more than 5 artists!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
            present(alert, animated: true)
            self.collectionView.reloadItems(at: [indexPath])
        }
        else {
            ArtistsViewController.selectedItems[artistsSection[indexPath.row].id] = (artistsSection[indexPath.row].name, indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        if ArtistsViewController.selectedItems.keys.contains(artistsSection[indexPath.row].id) {
            ArtistsViewController.selectedItems.removeValue(forKey: artistsSection[indexPath.row].id)
        }
    }
}
