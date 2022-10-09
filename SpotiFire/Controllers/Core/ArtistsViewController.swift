//
//  ArtistsViewController.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 25/08/2022.
//

import UIKit

class ArtistsViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    let searchController: UISearchController = {
        let vc = UISearchController(searchResultsController: ArtistSearchResultsViewController())
        vc.searchBar.placeholder = "Search for artists..."
        vc.searchBar.searchBarStyle = .minimal
        vc.definesPresentationContext = true
        return vc
    }()
    
    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
        return ArtistsViewController.createSectionLayout(section: sectionIndex)
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
    
    private var artistsSection = [ArtistCellViewModel]()
    private var newUserArtists: [Artist] = []
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
        ArtistsViewController.selectedItems = [:]
        fetchArtists()
    }
    
    private func fetchArtists() {
        let group = DispatchGroup()
        group.enter()
        var userArtists: UserArtistsResponse?
        APICaller.shared.getUserArtists(limit: 50) { result in
            defer {
                group.leave()
            }
            switch result {
            case.success(let model):
                userArtists = model
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
            self.newUserArtists = userArtists?.items ?? []
            self.configureModel(artists: self.newUserArtists)
            if self.newUserArtists.count < 1 {
                HapticsManager.shared.vibrate(for: .warning)
                let alert = UIAlertController(
                    title: "Alert",
                    message: "No artists found",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
            self.spinner.stopAnimating()
        }
    }
    
    private func configureModel(
        artists: [Artist]
    ) {
        artistsSection.append(contentsOf: artists.compactMap({
            return ArtistCellViewModel(
                image: URL(string: $0.images.first?.url ?? ""),
                name: $0.name,
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
        guard let resultsController = searchController.searchResultsController as? ArtistSearchResultsViewController,
              let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        APICaller.shared.search(query: query, search_type: "artist") { result in
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
            UserArtistsCollectionViewCell.self,
            forCellWithReuseIdentifier: UserArtistsCollectionViewCell.identifier
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
                heightDimension: .absolute((UIScreen.main.bounds.width/2)+17)
            ),
            subitem: item,
            count: 2
        )

        // Section
        let section = NSCollectionLayoutSection(group: horizontalGroup)
        return section
    }
    
    @objc func didTapInfo() {
        let alert = UIAlertController(
            title: "Info",
            message: "\nSelect up to 5 artists you want to have recommendations on.\n\nThen tune in the suggestion settings as you wish and enjoy your recommended songs!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
                                                            
    @objc func didTapEmpty() {
        if ArtistsViewController.selectedItems.count < 1 {
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
                ArtistsViewController.selectedItems = [:]
                self.navigationItem.rightBarButtonItems = [self.infoIcon]
            }))
            present(alert, animated: true)
        }
    }
    
    @objc func didTapSearch() {
        let vc = SearchViewController()
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.title = "Search"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func showSummary() {
        if ArtistsViewController.selectedItems.count < 1 {
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
            let repeatStr = String(repeating: str, count: ArtistsViewController.selectedItems.count)
            let alert = UIAlertController(
                title: "Summary of Selections",
                message: "Tap on a name to remove it\(repeatStr)",
                preferredStyle: .alert
            )
            var i = 0
            for (key, value) in ArtistsViewController.selectedItems {
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
                            ArtistsViewController.selectedItems.removeValue(forKey: key)
                            if self.artistsSection.first(where: { $0.id == key }) != nil {
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
        if ArtistsViewController.selectedItems.count < 1 {
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
                        selectedArtistsID: ArtistsViewController.selectedItems.map{String($0.key)},
                        selectedTracksID: [],
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

extension ArtistsViewController: UICollectionViewDelegate, UICollectionViewDataSource {

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
        navigationItem.rightBarButtonItems = [resetIcon, infoIcon]
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
        if ArtistsViewController.selectedItems.isEmpty {
            navigationItem.rightBarButtonItems = [infoIcon]
        }
    }
}

open class labelButton: UILabel {
    var onClick: () -> Void = {}
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        onClick()
    }
}
