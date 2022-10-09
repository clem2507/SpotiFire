//
//  RecommendationsViewController.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 25/08/2022.
//

import UIKit

class RecommendationsViewController: UIViewController {
    
    let selectedArtistsID: [String]?
    let selectedTracksID: [String]?
    let selectedGenresID: [String]?
    let limit: Int?
    let minPopularity: Int?
    init(selectedArtistsID: [String], selectedTracksID: [String], selectedGenresID: [String], limit: Int, minPopularity: Int) {
        self.selectedArtistsID = selectedArtistsID
        self.selectedTracksID = selectedTracksID
        self.selectedGenresID = selectedGenresID
        self.limit = limit
        self.minPopularity = minPopularity
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    private var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
        return RecommendationsViewController.createSectionLayout(section: sectionIndex)
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
    
    private let addToQueueButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue.withAlphaComponent(0.9)
        button.setTitle("Add To Queue", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.titleLabel?.lineBreakMode = .byWordWrapping
        return button
    }()
    
    private let addToPlaylistButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue.withAlphaComponent(0.9)
        button.setTitle("Add To Playlist", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.titleLabel?.lineBreakMode = .byWordWrapping
        return button
    }()
    
    private let createPlaylistButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue.withAlphaComponent(0.9)
        button.setTitle("Create Playlist", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.titleLabel?.lineBreakMode = .byWordWrapping
        return button
    }()
    
    private var selectAllButton = UIBarButtonItem()
    private var isSelectedAll = false
    
    private var recommendedTracksSection = [TrackCellViewModel]()
    private var selectedItemsIndexPath = [IndexPath]()
    private var selectedItemsID = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGray6
        configureCollectionView()
        self.selectAllButton = UIBarButtonItem(image: UIImage(systemName: "checkmark.square"),
                                               style: .done,
                                               target: self,
                                               action: #selector(selectAllAction)
        )
        navigationItem.rightBarButtonItems = [selectAllButton]
        view.addSubview(spinner)
        view.addSubview(addToQueueButton)
        view.addSubview(addToPlaylistButton)
        view.addSubview(createPlaylistButton)
        addToQueueButton.addTarget(self, action: #selector(addToQueueAction), for: .touchUpInside)
        addToPlaylistButton.addTarget(self, action: #selector(addToPlaylistAction), for: .touchUpInside)
        createPlaylistButton.addTarget(self, action: #selector(createPlaylistAction), for: .touchUpInside)
        fetchTracks()
    }
    
    private func fetchTracks() {
        let group = DispatchGroup()
        group.enter()
        var recommendedTracks: RecommendedTracksResponse?
        if selectedArtistsID?.count ?? 0 > 0 {
            APICaller.shared.getRecommendationsArtists(
                selectedArtistsID: selectedArtistsID ?? [],
                limit: limit ?? 20,
                minPopularity: minPopularity ?? 50
            ) { result in
                defer {
                    group.leave()
                }
                switch result {
                case.success(let model):
                    recommendedTracks = model
                case.failure(let error):
                    print(error.localizedDescription)
                }
            }
            group.notify(queue: .main) {
                guard var newRecommendedTracks = recommendedTracks?.tracks else {
                    return
                }
                newRecommendedTracks.removeAll(where: {$0.id == ""})
                self.configureModel(recommendedTracks: newRecommendedTracks)
                self.spinner.stopAnimating()
            }
        }
        else if selectedTracksID?.count ?? 0 > 0 {
            APICaller.shared.getRecommendationsTracks(
                selectedTracksID: selectedTracksID ?? [],
                limit: limit ?? 20,
                minPopularity: minPopularity ?? 50
            ) { result in
                defer {
                    group.leave()
                }
                switch result {
                case.success(let model):
                    recommendedTracks = model
                case.failure(let error):
                    print(error.localizedDescription)
                }
            }
            group.notify(queue: .main) {
                guard var newRecommendedTracks = recommendedTracks?.tracks else {
                    return
                }
                newRecommendedTracks.removeAll(where: {$0.id == ""})
                self.configureModel(recommendedTracks: newRecommendedTracks)
                self.spinner.stopAnimating()
            }
        }
        else if selectedGenresID?.count ?? 0 > 0 {
            APICaller.shared.getRecommendationsGenres(
                selectedGenresID: selectedGenresID ?? [],
                limit: limit ?? 20,
                minPopularity: minPopularity ?? 50
            ) { result in
                defer {
                    group.leave()
                }
                switch result {
                case.success(let model):
                    recommendedTracks = model
                case.failure(let error):
                    print(error.localizedDescription)
                }
            }
            group.notify(queue: .main) {
                guard var newRecommendedTracks = recommendedTracks?.tracks else {
                    return
                }
                newRecommendedTracks.removeAll(where: {$0.id == ""})
                self.configureModel(recommendedTracks: newRecommendedTracks)
                self.spinner.stopAnimating()
            }
        }
    }
    
    private func configureModel(
        recommendedTracks: [RecommendedTrack]
    ) {
        if recommendedTracks.count > 0 {
            recommendedTracksSection.append(contentsOf: recommendedTracks.compactMap({
                return TrackCellViewModel(
                    image: URL(string: $0.album?.images?.first?.url ?? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPkmVTIf2hLA9GiWjgOfWTgTO7_KJaQcUv0mmvbzUA3pmOvuIlRpuZ-uY9th-2hFQ2yCY&usqp=CAU"),
                    track_name: $0.name ?? "Unknown",
                    artist_name: $0.artists?.first?.name ?? "Unknown",
                    album_name: $0.album?.name ?? "Unknown",
                    id: $0.id ?? ""
                )
            }))
            collectionView.reloadData()
        }
        else {
            let alert = UIAlertController(title: "Alert", message: "No recommended tracks found!\nTry with other settings", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Back", style: .destructive, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: view.height-100-(view.safeAreaInsets.bottom/2))
        let buttonWidth = view.width/4
        let gapSize = buttonWidth/4
        let xStartPosition = gapSize
        addToQueueButton.frame = CGRect(
            x: xStartPosition,
            y: view.height-90-(view.safeAreaInsets.bottom/2),
            width: buttonWidth,
            height: 80
        )
        addToPlaylistButton.frame = CGRect(
            x: addToQueueButton.frame.origin.x + buttonWidth + gapSize,
            y: view.height-90-(view.safeAreaInsets.bottom/2),
            width: buttonWidth,
            height: 80
        )
        createPlaylistButton.frame = CGRect(
            x: addToPlaylistButton.frame.origin.x + buttonWidth + gapSize,
            y: view.height-90-(view.safeAreaInsets.bottom/2),
            width: buttonWidth,
            height: 80
        )
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
    
    @objc private func addToQueueAction() {
        if self.selectedItemsID.count > 0 {
            let group = DispatchGroup()
            var userDevices: UserDeviceResponse?
            group.enter()
            APICaller.shared.getUserDevices { result in
                switch result {
                case.success(let model):
                    userDevices = model
                    group.leave()
                case.failure(let error):
                    print(error.localizedDescription)
                }
            }
            group.notify(queue: .main) {
                let isDeviceActive = userDevices?.devices.first?.is_active ?? false
                if !isDeviceActive {
                    HapticsManager.shared.vibrate(for: .warning)
                    let alert = UIAlertController(
                        title: "Alert",
                        message: "Cannot connect to your session.\nMake sure you have tracks playing on your Spotify device!",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { _ in
                        let spotifyHooks = "spotify://"
                        let spotifyUrl = URL(string: spotifyHooks)!
                        if UIApplication.shared.canOpenURL(spotifyUrl) {
                            UIApplication.shared.open(spotifyUrl)
                        }
                        else {
                            UIApplication.shared.open(URL(string: "https://spotify.com/")!)
                        }
                    }))
                    self.present(alert, animated: true)
                }
                else {
                    var hasFailed = false
                    let addToQueueGroup = DispatchGroup()
                    addToQueueGroup.enter()
                    for i in 0...self.selectedItemsID.count-1 {
                        APICaller.shared.addTracksToQueue(selectedTrackID: self.selectedItemsID[i], userDeviceID: userDevices?.devices.first?.id ?? "") { success in
                            if success {
                                print("Success")
                            }
                            else {
                                hasFailed = true
                            }
                        }
                    }
                    addToQueueGroup.leave()
                    addToQueueGroup.notify(queue: .main) {
                        if !hasFailed {
                            HapticsManager.shared.vibrate(for: .success)
                            self.spinner.stopAnimating()
                            let vc = SuccessViewController()
                            vc.navigationItem.largeTitleDisplayMode = .never
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        else {
                            HapticsManager.shared.vibrate(for: .error)
                            let alert = UIAlertController(
                                title: "Error",
                                message: "Failed to add tracks to queue!",
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
        }
        else {
            HapticsManager.shared.vibrate(for: .warning)
            let alert = UIAlertController(title: "Alert", message: "You must select at least one track!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
    }
    
    @objc private func addToPlaylistAction() {
        if self.selectedItemsID.count > 0 {
            DispatchQueue.main.async {
                let vc = PlaylistSelectionViewController(selectedTracksID: self.selectedItemsID)
                vc.navigationItem.largeTitleDisplayMode = .never
                vc.title = "Playlist Selection"
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else {
            HapticsManager.shared.vibrate(for: .warning)
            let alert = UIAlertController(title: "Alert", message: "You must select at least one track!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
    }
    
    @objc private func createPlaylistAction() {
        if self.selectedItemsID.count > 0 {
            let alert = UIAlertController(
                title: "New Playlist",
                message: "Enter playlist name",
                preferredStyle: .alert
            )
            alert.addTextField { textField in
                textField.placeholder = "Playlist..."
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
                alert.dismiss(animated: true)
                self.spinner.startAnimating()
                guard let field = alert.textFields?.first,
                      let text = field.text,
                      !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                    return
                }
                let group = DispatchGroup()
                group.enter()
                APICaller.shared.createPlaylist(name: text, tracksID: self.selectedItemsID) { success in
                    defer {
                        group.leave()
                    }
                    if success {
                        print("Success")
                    }
                    else {
                        HapticsManager.shared.vibrate(for: .error)
                        DispatchQueue.main.async {
                            let alert = UIAlertController(
                                title: "Alert",
                                message: "Something went wrong when creating the playlist!",
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
                            self.present(alert, animated: true)
                        }
                        
                    }
                }
                group.notify(queue: .main) {
                    DispatchQueue.main.async {
                        HapticsManager.shared.vibrate(for: .success)
                        self.spinner.stopAnimating()
                        let vc = SuccessViewController()
                        vc.navigationItem.largeTitleDisplayMode = .never
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }))
            present(alert, animated: true)
        }
        else {
            HapticsManager.shared.vibrate(for: .warning)
            let alert = UIAlertController(title: "Alert", message: "You must select at least one track!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
    }
    
    @objc private func selectAllAction() {
        HapticsManager.shared.vibrateForSelection()
        selectedItemsID.removeAll()
        selectedItemsIndexPath.removeAll()
        if self.isSelectedAll {
            for row in 0..<self.collectionView.numberOfItems(inSection: 0) {
                self.collectionView.deselectItem(at: IndexPath(row: row, section: 0), animated: false)
            }
            self.selectAllButton.image = UIImage(systemName: "checkmark.square")
            self.isSelectedAll = false
        }
        else {
            for row in 0..<self.collectionView.numberOfItems(inSection: 0) {
                self.collectionView.selectItem(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .right)
                selectedItemsID.append("spotify:track:" + recommendedTracksSection[row].id)
                selectedItemsIndexPath.append(IndexPath(row: row, section: 0))
            }
            self.selectAllButton.image = UIImage(systemName: "checkmark.square.fill")
            self.isSelectedAll = true
        }
    }
}

extension RecommendationsViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendedTracksSection.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UserTracksCollectionViewCell.identifier,
            for: indexPath
        ) as? UserTracksCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: recommendedTracksSection[indexPath.row])
        collectionView.allowsMultipleSelection = true
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        selectedItemsIndexPath.append(indexPath)
        selectedItemsID.append("spotify:track:" + recommendedTracksSection[indexPath.row].id)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if selectedItemsIndexPath.contains(indexPath) {
            HapticsManager.shared.vibrateForSelection()
            let indexToRemove = selectedItemsIndexPath.firstIndex(of: indexPath)
            selectedItemsIndexPath.remove(at: indexToRemove ?? 0)
            selectedItemsID.remove(at: indexToRemove ?? 0)
        }
    }
}

