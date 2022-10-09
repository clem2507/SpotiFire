//
//  UserArtistsCollectionViewCell.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 01/09/2022.
//

import Foundation
import UIKit
import SDWebImage

class UserArtistsCollectionViewCell: UICollectionViewCell {
    static let identifier = "UserArtistsCollectionViewCell"
    
    private let artistCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemGray6
        contentView.addSubview(artistCoverImageView)
        contentView.addSubview(artistNameLabel)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        artistNameLabel.sizeToFit()
        
        let imageSize: CGFloat = contentView.width
        let artistNameSize = artistNameLabel.sizeThatFits(CGSize(width: contentView.width-10, height: contentView.height-10))
        
        artistCoverImageView.frame = CGRect(x: 0, y: 0, width: imageSize, height: imageSize)
        artistNameLabel.frame = CGRect(x: 5, y: contentView.height-25, width: artistNameSize.width, height: artistNameSize.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        artistNameLabel.text = nil
        artistCoverImageView.image = nil
    }
    
    func configure(with viewModel: ArtistCellViewModel) {
        artistNameLabel.text = viewModel.name
        artistCoverImageView.sd_setImage(with: viewModel.image, completed: nil)
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.layer.borderWidth = 3.0
                self.layer.borderColor = UIColor.systemBlue.cgColor
            }
            else {
                self.layer.borderWidth = 0.0
            }
        }
    }
}
