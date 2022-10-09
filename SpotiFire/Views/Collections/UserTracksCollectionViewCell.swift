//
//  UserTracksCollectionViewCell.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 01/09/2022.
//

import Foundation
import UIKit
import SDWebImage

class UserTracksCollectionViewCell: UICollectionViewCell {
    static let identifier = "UserTracksCollectionViewCell"
    
    private let trackCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    private let trackArtistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 1
        return label
    }()
    
    private let trackAlbumLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemGray6
        contentView.addSubview(trackCoverImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(trackAlbumLabel)
        contentView.addSubview(trackArtistLabel)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        trackNameLabel.sizeToFit()
        trackArtistLabel.sizeToFit()
        trackAlbumLabel.sizeToFit()
        
        let imageSize: CGFloat = contentView.height
        let trackNameSize = trackNameLabel.sizeThatFits(CGSize(width: contentView.width-10, height: contentView.height-10))
        let trackArtistSize = trackArtistLabel.sizeThatFits(CGSize(width: contentView.width-10, height: contentView.height-10))
        let trackAlbumsize = trackAlbumLabel.sizeThatFits(CGSize(width: contentView.width-10, height: contentView.height-10))

        trackCoverImageView.frame = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
        trackNameLabel.frame = CGRect(x: 75, y: contentView.height-55, width: trackNameSize.width, height: trackNameSize.height)
        trackArtistLabel.frame = CGRect(x: 75, y: contentView.height-27, width: trackArtistSize.width, height: trackArtistSize.height)
        trackAlbumLabel.frame = CGRect(x: trackArtistLabel.frame.origin.x+trackArtistSize.width, y: contentView.height-27, width: trackAlbumsize.width, height: trackAlbumsize.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackNameLabel.text = nil
        trackArtistLabel.text = nil
        trackAlbumLabel.text = nil
        trackCoverImageView.image = nil
    }
    
    func configure(with viewModel: TrackCellViewModel) {
        trackNameLabel.text = viewModel.track_name
        trackArtistLabel.text = viewModel.artist_name + " - "
        trackAlbumLabel.text = viewModel.album_name
        trackCoverImageView.sd_setImage(with: viewModel.image, completed: nil)
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.layer.borderWidth = 2.0
                self.layer.borderColor = UIColor.systemBlue.cgColor
            }
            else {
                self.layer.borderWidth = 0.0
            }
        }
    }
}

