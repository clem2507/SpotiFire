//
//  HomeViewController.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 25/08/2022.
//

import UIKit
import SDWebImage

class HomeViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let scrollStackViewContainer: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let yourLibrarySectionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIScreen.main.bounds.width/16, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        label.text = "Library"
        return label
    }()
    
    private let yourPreferencesSectionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIScreen.main.bounds.width/16, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        label.text = "Preferences"
        return label
    }()
    
    private let spotifySelectionsSectionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIScreen.main.bounds.width/16, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        label.text = "Selections"
        return label
    }()
    
    private let artistsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray4.withAlphaComponent(0.9)
        button.layer.cornerRadius = 10
        button.titleLabel?.lineBreakMode = .byWordWrapping
        return button
    }()
    
    private let artistsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIScreen.main.bounds.width/28, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.text = "Top Artists"
        return label
    }()
    
    private let artistsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "PlaylistImage")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        let group = DispatchGroup()
        group.enter()
        var userArtists: UserArtistsResponse?
        APICaller.shared.getUserArtists(limit: 1) { result in
            defer {
                group.leave()
            }
            switch result {
            case.success(let model):
                userArtists = model
            case.failure(let error):
                print(error)
            }
        }
        group.notify(queue: .main) {
            if userArtists?.items.count ?? 0 == 1 {
                imageView.sd_setImage(
                    with: URL(
                        string: userArtists?.items.first?.images.first?.url ?? "",
                        relativeTo: nil
                    )
                )
            }
            else {
                imageView.sd_setImage(
                    with: URL(
                        string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPkmVTIf2hLA9GiWjgOfWTgTO7_KJaQcUv0mmvbzUA3pmOvuIlRpuZ-uY9th-2hFQ2yCY&usqp=CAU",
                        relativeTo: nil
                    )
                )
            }
        }
        return imageView
    }()
    
    private let topTracksButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray4.withAlphaComponent(0.9)
        button.layer.cornerRadius = 10
        button.titleLabel?.lineBreakMode = .byWordWrapping
        return button
    }()
    
    private let topTracksLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIScreen.main.bounds.width/28, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.text = "Top Tracks"
        return label
    }()
    
    private let topTracksImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "TopTrackImage")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        let group = DispatchGroup()
        group.enter()
        var userTopTracks: UserTracksResponse?
        APICaller.shared.getUserTopTracks(limit: 1) { result in
            defer {
                group.leave()
            }
            switch result {
            case.success(let model):
                userTopTracks = model
            case.failure(let error):
                print(error)
            }
        }
        group.notify(queue: .main) {
            if userTopTracks?.items.count ?? 0 == 1 {
                imageView.sd_setImage(
                    with: URL(
                        string: userTopTracks?.items.first?.album.images.first?.url ?? "",
                        relativeTo: nil
                    )
                )
            }
            else {
                imageView.sd_setImage(
                    with: URL(
                        string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPkmVTIf2hLA9GiWjgOfWTgTO7_KJaQcUv0mmvbzUA3pmOvuIlRpuZ-uY9th-2hFQ2yCY&usqp=CAU",
                        relativeTo: nil
                    )
                )
            }
        }
        return imageView
    }()
    
    private let recentTracksButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray4.withAlphaComponent(0.9)
        button.layer.cornerRadius = 10
        button.titleLabel?.lineBreakMode = .byWordWrapping
        return button
    }()
    
    private let recentTracksLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIScreen.main.bounds.width/28, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.text = "Recent Tracks"
        return label
    }()
    
    private let recentTracksImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "RecentTrackImage")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        let group = DispatchGroup()
        group.enter()
        var userRecentTracks: RecentlyPlayedResponse?
        APICaller.shared.getUserRecentlyPlayed(limit: 1) { result in
            defer {
                group.leave()
            }
            switch result {
            case.success(let model):
                userRecentTracks = model
            case.failure(let error):
                print(error)
            }
        }
        group.notify(queue: .main) {
            if userRecentTracks?.items.count ?? 0 == 1 {
                imageView.sd_setImage(
                    with: URL(
                        string: userRecentTracks?.items.first?.track.album.images.first?.url ?? "",
                        relativeTo: nil
                    )
                )
            }
            else {
                imageView.sd_setImage(
                    with: URL(
                        string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPkmVTIf2hLA9GiWjgOfWTgTO7_KJaQcUv0mmvbzUA3pmOvuIlRpuZ-uY9th-2hFQ2yCY&usqp=CAU",
                        relativeTo: nil
                    )
                )
            }
        }
        return imageView
    }()
    
    private let likedTracksButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray4.withAlphaComponent(0.9)
        button.layer.cornerRadius = 10
        button.titleLabel?.lineBreakMode = .byWordWrapping
        return button
    }()
    
    private let likedTracksLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIScreen.main.bounds.width/22, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        label.text = "Liked Tracks"
        return label
    }()
    
    private let likedTracksImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "likedTracksImage")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.sd_setImage(
            with: URL(
                string: "https://i1.sndcdn.com/artworks-y6qitUuZoS6y8LQo-5s2pPA-t500x500.jpg"),
            completed: nil
        )
        return imageView
    }()
    
    private let playlistsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray4.withAlphaComponent(0.9)
        button.layer.cornerRadius = 10
        button.titleLabel?.lineBreakMode = .byWordWrapping
        return button
    }()
    
    private let playlistsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIScreen.main.bounds.width/22, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        label.text = "Saved Playlists"
        return label
    }()
    
    private let playlistsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "PlaylistImage")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        let group = DispatchGroup()
        group.enter()
        var userPlaylists: UserPlaylistsResponse?
        APICaller.shared.getUserPlaylists(limit: 1) { result in
            defer {
                group.leave()
            }
            switch result {
            case.success(let model):
                userPlaylists = model
            case.failure(let error):
                print(error)
            }
        }
        group.notify(queue: .main) {
            if userPlaylists?.items.count ?? 0 == 1 {
                imageView.sd_setImage(
                    with: URL(
                        string: userPlaylists?.items.first?.images.first?.url ?? "",
                        relativeTo: nil
                    )
                )
            }
            else {
                imageView.sd_setImage(
                    with: URL(
                        string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPkmVTIf2hLA9GiWjgOfWTgTO7_KJaQcUv0mmvbzUA3pmOvuIlRpuZ-uY9th-2hFQ2yCY&usqp=CAU",
                        relativeTo: nil
                    )
                )
            }
        }
        return imageView
    }()
    
    private let albumsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray4.withAlphaComponent(0.9)
        button.layer.cornerRadius = 10
        button.titleLabel?.lineBreakMode = .byWordWrapping
        return button
    }()
    
    private let albumsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIScreen.main.bounds.width/22, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        label.text = "Saved Albums"
        return label
    }()
    
    private let albumsImage: UIImageView = {
        let wrapperView: UIView = {
            let view = UIView()
            view.backgroundColor = .clear
            return view
        }()
        let stackView: UIStackView = {
            let stack = UIStackView()
            stack.axis = .horizontal
            return stack
        }()
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "albumImage")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        let group = DispatchGroup()
        group.enter()
        var userAlbums: UserAlbumsResponse?
        var imagesList = [UIImage]()
        APICaller.shared.getUserAlbums(limit: 1) { result in
            defer {
                group.leave()
            }
            switch result {
            case.success(let model):
                userAlbums = model
            case.failure(let error):
                print(error)
            }
        }
        group.notify(queue: .main) {
            if userAlbums?.items.count ?? 0 == 1 {
                imageView.sd_setImage(
                    with: URL(
                        string: userAlbums?.items.first?.album.images.first?.url ?? "",
                        relativeTo: nil
                    )
                )
            }
            else {
                imageView.sd_setImage(
                    with: URL(
                        string: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPkmVTIf2hLA9GiWjgOfWTgTO7_KJaQcUv0mmvbzUA3pmOvuIlRpuZ-uY9th-2hFQ2yCY&usqp=CAU",
                        relativeTo: nil
                    )
                )
            }
        }
        return imageView
    }()
    
    private let genresButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray4.withAlphaComponent(0.9)
        button.layer.cornerRadius = 10
        button.titleLabel?.lineBreakMode = .byWordWrapping
        return button
    }()
    
    private let genresLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIScreen.main.bounds.width/28, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.text = "List of Genres"
        return label
    }()
    
    private let genresImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "genresImage")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.sd_setImage(
            with: URL(
                string: "https://techcrunch.com/wp-content/uploads/2021/03/Spotify-Mix-Image-2.jpg"),
            completed: nil
        )
        return imageView
    }()
    
    private let newReleasesButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray4.withAlphaComponent(0.9)
        button.layer.cornerRadius = 10
        button.titleLabel?.lineBreakMode = .byWordWrapping
        return button
    }()
    
    private let newReleasesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIScreen.main.bounds.width/28, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.text = "New Releases"
        return label
    }()
    
    private let newReleasesImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "newReleasesImage")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.sd_setImage(
            with: URL(
                string: "https://assets2.sharedplaylists.cdn.crowds.dk/playlists/bc/c1/34/sz300x300_digital-empire-new-releases-b14b1442fa.jpg"),
            completed: nil
        )
        return imageView
    }()
    
    private let libraryView: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: ((UIScreen.main.bounds.height/11)*3)+2*(UIScreen.main.bounds.height/33)+80).isActive = true
        return view
    }()
    
    private let preferencesView: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width/4.0)+100).isActive = true
        return view
    }()
    
    private let genresView: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: ((UIScreen.main.bounds.width/2.0)-(UIScreen.main.bounds.width/16.0)-(UIScreen.main.bounds.width/32.0))+115).isActive = true
        return view
    }()
    
    private let albumImagesView: UIView = {
        let view = UIView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Home"
        view.backgroundColor = .systemGray6
        self.navigationController?.navigationBar.tintColor = .label
        let profileIcon = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle"),
                                          style: .done,
                                          target: self,
                                          action: #selector(didTapProfile)
        )
        navigationItem.rightBarButtonItem = profileIcon
        artistsButton.addTarget(self, action: #selector(artistsAction), for: .touchUpInside)
        topTracksButton.addTarget(self, action: #selector(topTracksAction), for: .touchUpInside)
        recentTracksButton.addTarget(self, action: #selector(recentTracksAction), for: .touchUpInside)
        likedTracksButton.addTarget(self, action: #selector(likedTracksAction), for: .touchUpInside)
        playlistsButton.addTarget(self, action: #selector(playlistsAction), for: .touchUpInside)
        albumsButton.addTarget(self, action: #selector(albumsAction), for: .touchUpInside)
        genresButton.addTarget(self, action: #selector(genresAction), for: .touchUpInside)
        newReleasesButton.addTarget(self, action: #selector(newReleasesAction), for: .touchUpInside)
        setupScrollView()
    }
    
    private func setupScrollView() {
        let margins = view.layoutMarginsGuide
        view.addSubview(scrollView)
        scrollView.addSubview(scrollStackViewContainer)
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        scrollStackViewContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        scrollStackViewContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        scrollStackViewContainer.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        scrollStackViewContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        scrollStackViewContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        configureContainerView()
    }
    private func configureContainerView() {
        libraryView.addSubview(yourLibrarySectionLabel)
        libraryView.addSubview(likedTracksButton)
        libraryView.addSubview(likedTracksLabel)
        libraryView.addSubview(playlistsButton)
        libraryView.addSubview(playlistsLabel)
        libraryView.addSubview(albumsButton)
        libraryView.addSubview(albumsLabel)
        likedTracksButton.addSubview(likedTracksImage)
        playlistsButton.addSubview(playlistsImage)
        albumsButton.addSubview(albumsImage)
        
        preferencesView.addSubview(yourPreferencesSectionLabel)
        preferencesView.addSubview(artistsButton)
        preferencesView.addSubview(artistsLabel)
        preferencesView.addSubview(topTracksButton)
        preferencesView.addSubview(topTracksLabel)
        preferencesView.addSubview(recentTracksButton)
        preferencesView.addSubview(recentTracksLabel)
        artistsButton.addSubview(artistsImage)
        topTracksButton.addSubview(topTracksImage)
        recentTracksButton.addSubview(recentTracksImage)
        
        genresView.addSubview(spotifySelectionsSectionLabel)
        genresView.addSubview(genresButton)
        genresView.addSubview(genresLabel)
        genresView.addSubview(newReleasesButton)
        genresView.addSubview(newReleasesLabel)
        genresButton.addSubview(genresImage)
        newReleasesButton.addSubview(newReleasesImage)
        
        scrollStackViewContainer.addArrangedSubview(libraryView)
        scrollStackViewContainer.addArrangedSubview(preferencesView)
        scrollStackViewContainer.addArrangedSubview(genresView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let squareSize = view.width/4
        let listSize = view.height/11
        let gapSize = squareSize/4
        let yStartPosition = 5.0
        
        yourLibrarySectionLabel.frame = CGRect(
            x: gapSize,
            y: yStartPosition,
            width: 350,
            height: 60
        )
        likedTracksButton.frame = CGRect(
            x: gapSize,
            y: yourLibrarySectionLabel.frame.origin.y + yourLibrarySectionLabel.height,
            width: (squareSize*3)+(gapSize*2),
            height: listSize
        )
        likedTracksLabel.frame = CGRect(
            x: likedTracksButton.width/2,
            y: likedTracksButton.frame.origin.y + listSize/2 - 20,
            width: 350,
            height: 40
        )
        likedTracksImage.frame = CGRect(
            x: 0,
            y: 0,
            width: listSize,
            height: listSize
        )
        playlistsButton.frame = CGRect(
            x: gapSize,
            y: likedTracksButton.frame.origin.y + listSize + listSize/3,
            width: (squareSize*3)+(gapSize*2),
            height: listSize
        )
        playlistsLabel.frame = CGRect(
            x: likedTracksButton.width/2,
            y: playlistsButton.frame.origin.y + listSize/2 - 20,
            width: 350,
            height: 40
        )
        playlistsImage.frame = CGRect(
            x: 0,
            y: 0,
            width: listSize,
            height: listSize
        )
        albumsButton.frame = CGRect(
            x: gapSize,
            y: playlistsButton.frame.origin.y + listSize + listSize/3,
            width: (squareSize*3)+(gapSize*2),
            height: listSize
        )
        albumsLabel.frame = CGRect(
            x: likedTracksButton.width/2,
            y: albumsButton.frame.origin.y + listSize/2 - 20,
            width: 350,
            height: 40
        )
        albumsImage.frame = CGRect(
            x: 0,
            y: 0,
            width: listSize,
            height: listSize
        )
        
        yourPreferencesSectionLabel.frame = CGRect(
            x: gapSize,
            y: yStartPosition,
            width: 350,
            height: 60
        )
        artistsButton.frame = CGRect(
            x: gapSize,
            y: yourPreferencesSectionLabel.frame.origin.y + yourPreferencesSectionLabel.height,
            width: squareSize,
            height: squareSize
        )
        artistsLabel.frame = CGRect(
            x: gapSize + 3,
            y: artistsButton.frame.origin.y + squareSize - 3,
            width: 350,
            height: 40
        )
        artistsImage.frame = CGRect(
            x: 0,
            y: 0,
            width: squareSize,
            height: squareSize
        )
        topTracksButton.frame = CGRect(
            x: (gapSize*2) + squareSize,
            y: yourPreferencesSectionLabel.frame.origin.y + yourPreferencesSectionLabel.height,
            width: squareSize,
            height: squareSize
        )
        topTracksLabel.frame = CGRect(
            x: (gapSize*2) + squareSize + 3,
            y: topTracksButton.frame.origin.y + squareSize - 3,
            width: 350,
            height: 40
        )
        topTracksImage.frame = CGRect(
            x: 0,
            y: 0,
            width: squareSize,
            height: squareSize
        )
        recentTracksButton.frame = CGRect(
            x: (gapSize*3) + (squareSize*2),
            y: yourPreferencesSectionLabel.frame.origin.y + yourPreferencesSectionLabel.height,
            width: squareSize,
            height: squareSize
        )
        recentTracksLabel.frame = CGRect(
            x: (gapSize*3) + (squareSize*2) + 3,
            y: recentTracksButton.frame.origin.y + squareSize - 3,
            width: 350,
            height: 40
        )
        recentTracksImage.frame = CGRect(
            x: 0,
            y: 0,
            width: squareSize,
            height: squareSize
        )
        
        spotifySelectionsSectionLabel.frame = CGRect(
            x: gapSize,
            y: yStartPosition,
            width: 350,
            height: 60
        )
        genresButton.frame = CGRect(
            x: gapSize,
            y: spotifySelectionsSectionLabel.frame.origin.y + spotifySelectionsSectionLabel.height,
            width: (squareSize*2)-gapSize-gapSize/2,
            height: squareSize
        )
        genresLabel.frame = CGRect(
            x: gapSize + 3,
            y: genresButton.frame.origin.y + ((squareSize*2)-gapSize-gapSize/2) - 3,
            width: 350,
            height: 40
        )
        genresImage.frame = CGRect(
            x: 0,
            y: 0,
            width: (squareSize*2)-gapSize-gapSize/2,
            height: (squareSize*2)-gapSize-gapSize/2
        )
        newReleasesButton.frame = CGRect(
            x: (squareSize*2)+(gapSize/2),
            y: spotifySelectionsSectionLabel.frame.origin.y + spotifySelectionsSectionLabel.height,
            width: (squareSize*2)-gapSize-gapSize/2,
            height: (squareSize*2)-gapSize-gapSize/2
        )
        newReleasesLabel.frame = CGRect(
            x: (squareSize*2)+(gapSize/2)+3,
            y: genresButton.frame.origin.y + ((squareSize*2)-gapSize-gapSize/2) - 3,
            width: 350,
            height: 40
        )
        newReleasesImage.frame = CGRect(
            x: 0,
            y: 0,
            width: (squareSize*2)-gapSize-gapSize/2,
            height: (squareSize*2)-gapSize-gapSize/2
        )
    }
    
    @objc func didTapProfile() {
        let vc = ProfileViewController()
        vc.title = "Profile"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func artistsAction() {
        let vc = ArtistsViewController()
        vc.title = "Top Artists"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func topTracksAction() {
        let vc = TopTracksViewController()
        vc.title = "Top Tracks"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func recentTracksAction() {
        let vc = RecentlyPlayedViewController()
        vc.title = "Recent Tracks"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func likedTracksAction() {
        let vc = LikedTracksViewController()
        vc.title = "Liked Tracks"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func playlistsAction() {
        let vc = PlaylistsViewController()
        vc.title = "Saved Playlists"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func albumsAction() {
        let vc = AlbumsViewController()
        vc.title = "Saved Albums"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func genresAction() {
        let vc = GenresViewController()
        vc.title = "Genres"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func newReleasesAction() {
        let vc = NewReleasesViewController()
        vc.title = "New Releases"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
