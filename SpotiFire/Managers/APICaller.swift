//
//  APICaller.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 25/08/2022.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private init() {}
    
    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }
    
    enum APIError: Error {
        case failedToGetData
    }
    
    // MARK: - Profile
    
    public func getCurrentUserProfile(completion: @escaping ((Result<UserProfile, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me"),
                      type: .GET
        ) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Artists
    
    public func getUserArtists(limit: Int, completion: @escaping ((Result<UserArtistsResponse, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/top/artists?limit=\(limit)&time_range=long_term"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(UserArtistsResponse.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Tracks
    
    public func getUserLikedTracks(limit: Int, offset: Int, completion: @escaping ((Result<LikedTracksResponse, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/tracks?limit=\(limit)&offset=\(offset)"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(LikedTracksResponse.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getUserTopTracks(limit: Int, completion: @escaping ((Result<UserTracksResponse, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/top/tracks?limit=\(limit)&time_range=short_term"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(UserTracksResponse.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getUserRecentlyPlayed(limit: Int, completion: @escaping ((Result<RecentlyPlayedResponse, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/player/recently-played?limit=\(limit)"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(RecentlyPlayedResponse.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Albums
    
    public func getUserAlbums(limit: Int, completion: @escaping ((Result<UserAlbumsResponse, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/albums?limit=\(limit)"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(UserAlbumsResponse.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getAlbumDetails(for album: AlbumsResponse, completion: @escaping ((Result<AlbumDetailsResponse, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/albums/" + album.album.id), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(AlbumDetailsResponse.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getAlbumTracks(album: AlbumsResponse, offset: Int, completion: @escaping ((Result<TrackResponse, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/albums/\(album.album.id)/tracks?offset=\(offset)"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(TrackResponse.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getNewReleases(limit: Int, completion: @escaping ((Result<NewReleasesResponse, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/new-releases?limit=\(limit)&country=FR"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(NewReleasesResponse.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Playlists
    
    public func getUserPlaylists(limit: Int, completion: @escaping ((Result<UserPlaylistsResponse, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/playlists?limit=\(limit)"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(UserPlaylistsResponse.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getPlaylistDetails(for playlist: Playlist, completion: @escaping ((Result<PlaylistDetailsResponse, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/playlists/\(playlist.id)"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(PlaylistDetailsResponse.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getPlaylistTracks(playlist: Playlist, offset: Int, completion: @escaping ((Result<PlaylistDetailTracksResponse, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/playlists/\(playlist.id)/tracks?offset=\(offset)"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(PlaylistDetailTracksResponse.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func createPlaylist(name: String, tracksID: [String], completion: @escaping ((Bool) -> Void)) {
        getCurrentUserProfile{ [weak self] result in
            switch result {
            case .success(let profile):
                let urlString = Constants.baseAPIURL + "/users/\(profile.id)/playlists"
                self?.createRequest(with: URL(string: urlString), type: .POST) { baseRequest in
                    var request = baseRequest
                    let json = [
                        "name": name,
                        "public": false
                    ] as [String : Any]
                    request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
                    let task = URLSession.shared.dataTask(with: request) { data, _, error in
                        guard let data = data, error == nil else {
                            completion(false)
                            return
                        }
                        do {
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            if let response = result as? [String: Any], response["id"] as? String != nil {
                                let playlistID = response["id"] as? String ?? ""
                                self?.addTracksToPlaylist(playlistID: playlistID, tracksID: tracksID) { success in
                                    if success {
                                        completion(true)
                                    }
                                    else{
                                        completion(false)
                                    }
                                }
                            }
                            else {
                                completion(false)
                            }
                        }
                        catch {
                            print(error.localizedDescription)
                            completion(false)
                        }
                    }
                    task.resume()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    public func addTracksToPlaylist(playlistID: String, tracksID: [String], completion: @escaping ((Bool)) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/playlists/\(playlistID)/tracks?uris=" + tracksID.joined(separator:",")),
                      type: .POST
        ) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(false)
                    return
                }
                
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let response = result as? [String: Any], response["snapshot_id"] as? String != nil {
                        completion(true)
                    }
                    print(result)
                }
                catch {
                    print(error.localizedDescription)
                    completion(false)
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Genres
    
    public func getAvailableGenreSeeds(completion: @escaping ((Result<Genres, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/recommendations/available-genre-seeds"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(Genres.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Recommendations
    
    public func getRecommendationsArtists(selectedArtistsID: [String], limit: Int, minPopularity: Int, completion: @escaping ((Result<RecommendedTracksResponse, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/recommendations?limit=\(limit)&min_popularity=\(minPopularity)&seed_artists=" + selectedArtistsID.joined(separator:",")), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(RecommendedTracksResponse.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getRecommendationsTracks(selectedTracksID: [String], limit: Int, minPopularity: Int, completion: @escaping ((Result<RecommendedTracksResponse, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/recommendations?limit=\(limit)&min_popularity=\(minPopularity)&seed_tracks=" + selectedTracksID.joined(separator:",")), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(RecommendedTracksResponse.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getRecommendationsGenres(selectedGenresID: [String], limit: Int, minPopularity: Int, completion: @escaping ((Result<RecommendedTracksResponse, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/recommendations?limit=\(limit)&min_popularity=\(minPopularity)&seed_genres=" + selectedGenresID.joined(separator:",")), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(RecommendedTracksResponse.self, from: data)
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Add To Queue
    
    public func addTracksToQueue(selectedTrackID: String, userDeviceID: String, completion: @escaping ((Bool) -> Void)) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/player/queue?uri=\(selectedTrackID)&device_id=\(userDeviceID)"), type: .POST) { request in
//            let task = URLSession.shared.dataTask(with: request) { data, _, error in
//                guard let data = data, error == nil else {
//                    completion(false)
//                    return
//                }
//                completion(true)
                
//                do {
//                    print(data)
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
//                    completion(true)
//                    print(result)
//                }
//                catch {
//                    print(error.localizedDescription)
//                    completion(false)
//                }
                
//            }
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(false)
                    return
                }
                if data.isEmpty {
                    completion(true)
                }
                else {
                    completion(false)
                }
//                do {
//                    print("data \(data)")
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
//                    print("result \(result)")
//                    if let response = result as? [String: Any], response["snapshot_id"] as? String != nil {
//                        completion(true)
//                    }
//                    print(result)
//                }
//                catch {
//                    print(error.localizedDescription)
//                    completion(false)
//                }
            }
//            task.resume()
            task.resume()
        }
    }
    
    // MARK: - Playback
    
    public func getUserDevices(completion: @escaping ((Result<UserDeviceResponse, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/player/devices"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(UserDeviceResponse.self, from: data)
                    completion(.success(result))
                    print(result)
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Search
    
    public func search(query: String, search_type: String, completion: @escaping ((Result<SearchResultsResponse, Error>) -> Void)) {
        createRequest(
            with: URL(string: Constants.baseAPIURL+"/search?limit=12&type=\(search_type)&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"),
            type: .GET
        ) { request in
            print(request.url?.absoluteString ?? "none")
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(SearchResultsResponse.self, from: data)
                    completion(.success(result))
                }
                catch {
                    completion(.failure(error))
                    print(error.localizedDescription)
                }
            }
            task.resume()
        }
    }
    
    
    // MARK: - Private
    
    enum HTTPMethod: String {
        case GET
        case POST
    }
    
    private func createRequest(with url: URL?, type: HTTPMethod, completion: @escaping ((URLRequest) -> Void)) {
        AuthManager.shared.withValidToken { token in
            guard let apiURL = url else {
                return
            }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)",
                             forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
        }
    }
}
