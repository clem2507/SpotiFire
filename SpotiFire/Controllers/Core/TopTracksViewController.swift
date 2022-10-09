//
//  TopTracksViewController.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 01/09/2022.
//

import UIKit

class TopTracksViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    let searchController: UISearchController = {
        let vc = UISearchController(searchResultsController: TopTracksResultsViewController())
        vc.searchBar.placeholder = "Search for tracks..."
        vc.searchBar.searchBarStyle = .minimal
        vc.definesPresentationContext = true
        return vc
    }()

    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
        return TopTracksViewController.createSectionLayout(section: sectionIndex)
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
    
    private let summarySelectionsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue.withAlphaComponent(0.9)
        button.setTitle("Summary", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        return button
    }()
    
    private let getRecommendationsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue.withAlphaComponent(0.9)
        button.setTitle("Ready", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        return button
    }()
    
    private let limitSlider = ToolsManager.shared.slider(
        frame: CGRect(x: 10, y: 45, width: 250, height: 80),
        text: "Recommendation Limit: 20",
        minimumValue: 1,
        maximumValue: 100,
        defaultValue: 20
    )
    private let minPopularitySlider = ToolsManager.shared.slider(
        frame: CGRect(x: 10, y: 115, width: 250, height: 80),
        text: "Minimum Popularity: 50",
        minimumValue: 1,
        maximumValue: 100,
        defaultValue: 50
    )
    
    private let resetIcon = UIBarButtonItem()
    private let infoIcon = UIBarButtonItem()
    
    private var topTracksSection = [TrackCellViewModel]()
    private var newUserTopTracks: [Track] = []
    static var selectedItems:[String:(String, IndexPath)] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGray6
        configureCollectionView()
        self.resetIcon.image = UIImage(systemName: "arrow.counterclockwise")
        self.resetIcon.style = .done
        self.resetIcon.target = self
        self.resetIcon.action = #selector(didTapEmpty)
        self.infoIcon.image = UIImage(systemName: "info.circle")
        self.infoIcon.style = .done
        self.infoIcon.target = self
        self.infoIcon.action = #selector(didTapInfo)
        navigationItem.rightBarButtonItems = [infoIcon]
        view.addSubview(spinner)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        view.addSubview(summarySelectionsButton)
        view.addSubview(getRecommendationsButton)
        summarySelectionsButton.addTarget(self, action: #selector(showSummary), for: .touchUpInside)
        getRecommendationsButton.addTarget(self, action: #selector(getRecommendations), for: .touchUpInside)
        TopTracksViewController.selectedItems = [:]
        fetchTracks()
    }
    
    private func fetchTracks() {
        let group = DispatchGroup()
        group.enter()
        var userTopTracks: UserTracksResponse?
        APICaller.shared.getUserTopTracks(limit: 50) { result in
            defer {
                group.leave()
            }
            switch result {
            case.success(let model):
                userTopTracks = model
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
            self.newUserTopTracks = userTopTracks?.items ?? []
            self.configureModel(topTracks: self.newUserTopTracks)
            if self.newUserTopTracks.count < 1 {
                HapticsManager.shared.vibrate(for: .warning)
                let alert = UIAlertController(
                    title: "Alert",
                    message: "No top tracks found",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
            self.spinner.stopAnimating()
        }
    }
    
    private func configureModel(
        topTracks: [Track]
    ) {
        topTracksSection.append(contentsOf: topTracks.compactMap({
            return TrackCellViewModel(
                image: URL(string: $0.album.images.first?.url ?? ""),
                track_name: $0.name,
                artist_name: $0.artists.first?.name ?? "-",
                album_name: $0.album.name,
                id: $0.id
            )
        }))
        collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: view.height-60-(view.safeAreaInsets.bottom/2))
        summarySelectionsButton.frame = CGRect(
            x: 30,
            y: view.height-50-(view.safeAreaInsets.bottom/2),
            width: (view.width-50)/2.5,
            height: 40
        )
        getRecommendationsButton.frame = CGRect(
            x: view.width-30-summarySelectionsButton.width,
            y: view.height-50-(view.safeAreaInsets.bottom/2),
            width: (view.width-50)/2.5,
            height: 40
        )
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        guard let resultsController = searchController.searchResultsController as? ArtistSearchResultsViewController,
//              let query = searchBar.text,
//              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
//            return
//        }
//
//        APICaller.shared.search(query: query, search_type: "artist") { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let model):
//                    resultsController.update(with: model)
//                case .failure(let error):
//                    print(error.localizedDescription)
//                }
//            }
//        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let resultsController = searchController.searchResultsController as? TopTracksResultsViewController,
              let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        APICaller.shared.search(query: query, search_type: "track") { result in
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
            UserTracksCollectionViewCell.self,
            forCellWithReuseIdentifier: UserTracksCollectionViewCell.identifier
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
    
    @objc func didTapInfo() {
        let alert = UIAlertController(
            title: "Info",
            message: "\nSelect up to 5 tracks you want to have recommendations on.\n\nThen tune in the suggestion settings as you wish and enjoy your recommended songs!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @objc func didTapEmpty() {
        if TopTracksViewController.selectedItems.count < 1 {
            HapticsManager.shared.vibrate(for: .warning)
            let alert = UIAlertController(
                title: "Alert",
                message: "Select at least one item",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
        else {
            let alert = UIAlertController(title: "Alert", message: "Are you sure you want to reset the selection?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                self.collectionView.reloadData()
                TopTracksViewController.selectedItems = [:]
                self.navigationItem.rightBarButtonItems = [self.infoIcon]
            }))
            present(alert, animated: true)
        }
    }
    
    @objc private func showSummary() {
        if TopTracksViewController.selectedItems.count < 1 {
            HapticsManager.shared.vibrate(for: .warning)
            let alert = UIAlertController(
                title: "Alert",
                message: "Select at least one item",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
        else {
            let str = "\n\n\n"
            let repeatStr = String(repeating: str, count: TopTracksViewController.selectedItems.count)
            let alert = UIAlertController(
                title: "Summary of Selections",
                message: "Tap on a track to remove it\(repeatStr)",
                preferredStyle: .alert
            )
            var i = 0
            for (key, value) in TopTracksViewController.selectedItems {
                let label = labelButton()
                let text = value.0
                label.text = text
                label.textColor = .secondaryLabel
                label.frame = CGRect(x: 15, y: 30+(49*(i+1)), width: 250, height: 25)
                label.onClick = {
                    HapticsManager.shared.vibrateForSelection()
                    let removeAlert = UIAlertController(
                        title: "Alert",
                        message: "Are you sure you want to remove \(text) from the selection?",
                        preferredStyle: .alert
                    )
                    removeAlert.addAction(UIAlertAction(
                        title: "Yes",
                        style: .default,
                        handler: {_ in
                            TopTracksViewController.selectedItems.removeValue(forKey: key)
                            if self.topTracksSection.first(where: { $0.id == key }) != nil {
                                self.collectionView.deselectItem(at: value.1, animated: false)
                                self.collectionView.reloadItems(at: [value.1])
                            }
                            alert.dismiss(animated: true)
                        }
                    ))
                    removeAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                    alert.present(removeAlert, animated: true)
                }
                alert.view.addSubview(label)
                i += 1
            }
            alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
    }
    
    @objc private func getRecommendations() {
        if TopTracksViewController.selectedItems.count < 1 {
            HapticsManager.shared.vibrate(for: .warning)
            let alert = UIAlertController(
                title: "Alert",
                message: "Select at least one item",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
        else {
            let alert = UIAlertController(
                title: "Recommendation Settings",
                message: "Tune to your liking\n\n\n\n\n\n\n\n\n\n",
                preferredStyle: .alert
            )
            self.limitSlider.1.addTarget(self, action: #selector(sliderValueChangedLimit(sender:)), for: UIControl.Event.valueChanged)
            self.limitSlider.0.text = "Recommendation Limit: " + String(Int(limitSlider.1.value))
            self.minPopularitySlider.1.addTarget(self, action: #selector(sliderValueChangedMinPopularity(sender:)), for: UIControl.Event.valueChanged)
            self.minPopularitySlider.0.text = "Minimum Popularity: " + String(Int(minPopularitySlider.1.value))
            
            alert.view.addSubview(self.limitSlider.0)
            alert.view.addSubview(self.limitSlider.1)
            alert.view.addSubview(self.minPopularitySlider.0)
            alert.view.addSubview(self.minPopularitySlider.1)
            alert.addAction(UIAlertAction(
                title: "OK",
                style: .default,
                handler: { (result : UIAlertAction) -> Void in
                    let vc = RecommendationsViewController(
                        selectedArtistsID: [],
                        selectedTracksID: TopTracksViewController.selectedItems.map{String($0.key)},
                        selectedGenresID: [],
                        limit: Int(self.limitSlider.1.value),
                        minPopularity: Int(self.minPopularitySlider.1.value*0.7)
                    )
                    vc.title = "Recommended Tracks"
                    vc.navigationItem.largeTitleDisplayMode = .never
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            ))
            alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
    }
    
    @objc private func sliderValueChangedLimit(sender:UISlider!) {
        self.limitSlider.0.text = "Recommendation Limit: " + String(Int(sender.value))
    }
    
    @objc private func sliderValueChangedMinPopularity(sender:UISlider!) {
        self.minPopularitySlider.0.text = "Minimum Popularity: " + String(Int(sender.value))
    }
}

extension TopTracksViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topTracksSection.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UserTracksCollectionViewCell.identifier,
            for: indexPath
        ) as? UserTracksCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: topTracksSection[indexPath.row])
        collectionView.allowsMultipleSelection = true
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        navigationItem.rightBarButtonItems = [resetIcon, infoIcon]
        if TopTracksViewController.selectedItems.count > 4 {
            HapticsManager.shared.vibrate(for: .warning)
            let alert = UIAlertController(title: "Alert", message: "You cannot select more than 5 tracks!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
            present(alert, animated: true)
            self.collectionView.reloadItems(at: [indexPath])
        }
        else {
            TopTracksViewController.selectedItems[topTracksSection[indexPath.row].id] = (topTracksSection[indexPath.row].track_name, indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        if TopTracksViewController.selectedItems.keys.contains(topTracksSection[indexPath.row].id) {
            TopTracksViewController.selectedItems.removeValue(forKey: topTracksSection[indexPath.row].id)
        }
        if TopTracksViewController.selectedItems.isEmpty {
            navigationItem.rightBarButtonItems = [infoIcon]
        }
    }
}

