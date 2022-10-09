//
//  GenreSearchResultsViewController.swift
//  SpotiFire
//
//  Created by Clement Detry on 12/09/2022.
//

import UIKit

class GenreSearchResultsViewController: UIViewController {
    
    private var results: String = ""
    private var filtered: [String]?
    private var genresSection = [GenreCellViewModel]()
    private var selectedItemsIndexPath = [IndexPath]()
    private var selectedItemsID = [String]()
    
    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
        return GenreSearchResultsViewController.createSectionLayout(section: sectionIndex)
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
    
    func update(with results: String) {
        self.genresSection = [GenreCellViewModel]()
        self.results = results
        self.filtered = GenresViewController.newGenres.filter{ $0.contains(self.results.lowercased()) }
        self.configureModel(genres: self.filtered ?? [])
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.register(
            GenresCollectionViewCell.self,
            forCellWithReuseIdentifier: GenresCollectionViewCell.identifier
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemGray6
        collectionView.keyboardDismissMode = UIScrollView.KeyboardDismissMode.interactive
    }
    
    private func configureModel(
        genres: [String]
    ) {
        genresSection.append(contentsOf: genres.compactMap({
            return GenreCellViewModel(
                genre: $0
            )
        }))
        if genresSection.count < 1 {
            HapticsManager.shared.vibrate(for: .warning)
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
            leading: 10,
            bottom: 8,
            trailing: 10
        )

        // Group
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(70)
            ),
            subitem: item,
            count: 1
        )

        // Section
        let section = NSCollectionLayoutSection(group: horizontalGroup)
        return section
    }
}

extension GenreSearchResultsViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genresSection.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GenresCollectionViewCell.identifier,
            for: indexPath
        ) as? GenresCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: genresSection[indexPath.row])
        collectionView.allowsMultipleSelection = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        if GenresViewController.selectedItems.count > 4 {
            HapticsManager.shared.vibrate(for: .warning)
            let alert = UIAlertController(title: "Alert", message: "You cannot select more than 5 artists!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
            present(alert, animated: true)
            self.collectionView.reloadItems(at: [indexPath])
        }
        else {
            GenresViewController.selectedItems[genresSection[indexPath.row].genre] = (genresSection[indexPath.row].genre, indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        if GenresViewController.selectedItems.keys.contains(genresSection[indexPath.row].genre) {
            GenresViewController.selectedItems.removeValue(forKey: genresSection[indexPath.row].genre)
        }
    }
}

