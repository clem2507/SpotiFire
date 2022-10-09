//
//  UserAlbumsCollectionViewCell.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 01/09/2022.
//

import Foundation
import UIKit
import SDWebImage

class UserAlbumsCollectionViewCell: UICollectionViewCell {
    static let identifier = "UserAlbumsCollectionViewCell"
    
    private let albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let albumNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()

    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        contentView.backgroundColor = .systemGray6
        contentView.backgroundColor = .systemGray6
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(albumNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        albumNameLabel.sizeToFit()
        artistNameLabel.sizeToFit()
        
        let imageSize: CGFloat = contentView.width
        let albumLabelSize = albumNameLabel.sizeThatFits(CGSize(width: contentView.width-10, height: contentView.height-10))
        let artistNameSize = artistNameLabel.sizeThatFits(CGSize(width: contentView.width-10, height: contentView.height-10))
        
        albumCoverImageView.frame = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
        albumNameLabel.frame = CGRect(x: 5, y: contentView.height-46, width: albumLabelSize.width, height: albumLabelSize.height)
        artistNameLabel.frame = CGRect(x: 5, y: contentView.height-24, width: artistNameSize.width, height: artistNameSize.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        albumNameLabel.text = nil
        artistNameLabel.text = nil
        albumCoverImageView.image = nil
    }
    
    func configure(with viewModel: AlbumCellViewModel) {
        albumNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        albumCoverImageView.sd_setImage(with: viewModel.image, completed: nil)
    }
}
