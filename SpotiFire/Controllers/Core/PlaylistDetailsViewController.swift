//
//  PlaylistDetailViewController.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 04/09/2022.
//

import UIKit

class PlaylistDetailsViewController: UIViewController {
    
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: {_, _ -> NSCollectionLayoutSection in
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
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(80)
                ),
                subitem: item,
                count: 1
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.75)),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
            ]
            return section
        })
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
    
    private let playlist: Playlist
    init(playlist: Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
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
    
    private var nextUrl = ""
    private var flag = true
    private var viewModels = [TrackCellViewModel]()
    private var newPlaylistTracks: [PlaylistItem] = []
    static var selectedItems:[String:(String, IndexPath)] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = playlist.name
        view.backgroundColor = .systemGray6
        self.resetIcon.image = UIImage(systemName: "arrow.counterclockwise")
        self.resetIcon.style = .done
        self.resetIcon.target = self
        self.resetIcon.action = #selector(didTapEmpty)
        self.infoIcon.image = UIImage(systemName: "info.circle")
        self.infoIcon.style = .done
        self.infoIcon.target = self
        self.infoIcon.action = #selector(didTapInfo)
        navigationItem.rightBarButtonItems = [infoIcon]
        summarySelectionsButton.addTarget(self, action: #selector(showSummary), for: .touchUpInside)
        getRecommendationsButton.addTarget(self, action: #selector(getRecommendations), for: .touchUpInside)
        PlaylistDetailsViewController.selectedItems = [:]
        
        view.addSubview(collectionView)
        collectionView.register(UserTracksCollectionViewCell.self, forCellWithReuseIdentifier: UserTracksCollectionViewCell.identifier)
        collectionView.backgroundColor = .systemGray6
        collectionView.register(PlaylistHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(summarySelectionsButton)
        view.addSubview(getRecommendationsButton)
        view.addSubview(spinner)
        
        fetchPlaylistDetails()
    }
    
    private func fetchPlaylistDetails() {
        APICaller.shared.getPlaylistTracks(playlist: playlist, offset: self.newPlaylistTracks.count) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.viewModels.append(contentsOf: model.items.compactMap({
                        return TrackCellViewModel(
                            image: URL(string: $0.track?.album?.images?.first?.url ?? ""),
                            track_name: $0.track?.name ?? "unknown track",
                            artist_name: $0.track?.artists?.first?.name ?? "unknown artist",
                            album_name: $0.track?.album?.name ?? "unknown album",
                            id: $0.track?.id ?? ""
                        )
                    }))
                    self?.viewModels.removeAll(where: {$0.id == ""})
                    self?.newPlaylistTracks.append(contentsOf: model.items)
                    if self?.newPlaylistTracks.count ?? 0 < 1 {
                        HapticsManager.shared.vibrate(for: .warning)
                        let alert = UIAlertController(
                            title: "Alert",
                            message: "No playlist track found",
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
                        self?.present(alert, animated: true)
                    }
                    self?.collectionView.reloadData()
                    for (_, value) in PlaylistDetailsViewController.selectedItems {
                        self?.collectionView.selectItem(at: value.1, animated: false, scrollPosition: .left)
                    }
                    self?.nextUrl = model.next ?? "None"
                    self?.flag = true
                    self?.spinner.stopAnimating()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
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
        if PlaylistDetailsViewController.selectedItems.count < 1 {
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
                PlaylistDetailsViewController.selectedItems = [:]
                self.navigationItem.rightBarButtonItems = [self.infoIcon]
            }))
            present(alert, animated: true)
        }
    }
    
    @objc private func showSummary() {
        if PlaylistDetailsViewController.selectedItems.count < 1 {
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
            let repeatStr = String(repeating: str, count: PlaylistDetailsViewController.selectedItems.count)
            let alert = UIAlertController(
                title: "Summary of Selections",
                message: "Tap on a track to remove it\(repeatStr)",
                preferredStyle: .alert
            )
            var i = 0
            for (key, value) in PlaylistDetailsViewController.selectedItems {
                let label = labelButton()
                let text = value.0
                label.text = text
                label.textColor = .secondaryLabel
                label.frame = CGRect(x: 15, y: 30+(49*(i+1)), width: 250, height: 25)
                label.onClick = {
                    let removeAlert = UIAlertController(
                        title: "Alert",
                        message: "Are you sure you want to remove \(text) from the selection?",
                        preferredStyle: .alert
                    )
                    removeAlert.addAction(UIAlertAction(
                        title: "Yes",
                        style: .default,
                        handler: {_ in
                            PlaylistDetailsViewController.selectedItems.removeValue(forKey: key)
                            if self.viewModels.first(where: { $0.id == key }) != nil {
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
        if PlaylistDetailsViewController.selectedItems.count < 1 {
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
                        selectedTracksID: PlaylistDetailsViewController.selectedItems.map{String($0.key)},
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

extension PlaylistDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UserTracksCollectionViewCell.identifier,
            for: indexPath
        ) as? UserTracksCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier,
            for: indexPath
        ) as? PlaylistHeaderCollectionReusableView,
        kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let headerViewModel = PlaylistHeaderViewViewModel(
            playlistName: playlist.name,
            ownerName: playlist.owner.display_name,
            artworkURL: URL(string: playlist.images.first?.url ?? "")
        )
        header.configure(with: headerViewModel)
        collectionView.allowsMultipleSelection = true
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        navigationItem.rightBarButtonItems = [resetIcon, infoIcon]
        if PlaylistDetailsViewController.selectedItems.count > 4 {
            HapticsManager.shared.vibrate(for: .warning)
            let alert = UIAlertController(title: "Alert", message: "You cannot select more than 5 tracks!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: nil))
            present(alert, animated: true)
            self.collectionView.reloadItems(at: [indexPath])
        }
        else {
            PlaylistDetailsViewController.selectedItems[viewModels[indexPath.row].id] = (viewModels[indexPath.row].track_name, indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        if PlaylistDetailsViewController.selectedItems.keys.contains(viewModels[indexPath.row].id) {
            PlaylistDetailsViewController.selectedItems.removeValue(forKey: viewModels[indexPath.row].id)
        }
        if PlaylistDetailsViewController.selectedItems.isEmpty {
            navigationItem.rightBarButtonItems = [infoIcon]
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height) {
            if self.flag {
                if self.nextUrl != "None" {
                    flag = false
                    fetchPlaylistDetails()
                }
            }
        }
    }
}
