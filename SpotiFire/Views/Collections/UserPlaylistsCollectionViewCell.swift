//
//  UserPlaylistsCollectionViewCell.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 01/09/2022.
//

import Foundation
import UIKit
import SDWebImage

class UserPlaylistsCollectionViewCell: UICollectionViewCell {
    static let identifier = "UserPlaylistsCollectionViewCell"
    
    private let playlistCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let playlistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    private let playlistOwnerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemGray6
        contentView.addSubview(playlistCoverImageView)
        contentView.addSubview(playlistNameLabel)
        contentView.addSubview(playlistOwnerLabel)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playlistNameLabel.sizeToFit()
        playlistOwnerLabel.sizeToFit()
        
        let imageSize: CGFloat = contentView.width
        let playlistNameSize = playlistNameLabel.sizeThatFits(CGSize(width: contentView.width-10, height: contentView.height-10))
        let playlistOwnerSize = playlistOwnerLabel.sizeThatFits(CGSize(width: contentView.width-10, height: contentView.height-10))

        playlistCoverImageView.frame = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
        playlistNameLabel.frame = CGRect(x: 5, y: contentView.height-46, width: playlistNameSize.width, height: playlistNameSize.height)
        playlistOwnerLabel.frame = CGRect(x: 5, y: contentView.height-24, width: playlistOwnerSize.width, height: playlistOwnerSize.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playlistNameLabel.text = nil
        playlistOwnerLabel.text = nil
        playlistCoverImageView.image = nil
    }
    
    func configure(with viewModel: PlaylistCellViewModel) {
        playlistNameLabel.text = viewModel.name
        playlistOwnerLabel.text = viewModel.owner
        playlistCoverImageView.sd_setImage(with: viewModel.image, completed: nil)
    }
}
