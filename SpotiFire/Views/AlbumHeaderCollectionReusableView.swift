//
//  AlbumHeaderCollectionReusableView.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 04/09/2022.
//

import SDWebImage
import UIKit

class AlbumHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "AlbumHeaderCollectionReusableView"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    private let artistLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.numberOfLines = 1
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGray6
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(artistLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = height/1.6
        imageView.frame = CGRect(x: (width-imageSize)/2, y: 20, width: imageSize, height: imageSize)
        nameLabel.frame = CGRect(x: 10, y: imageView.bottom+10, width: width-20, height: 44)
        artistLabel.frame = CGRect(x: 10, y: nameLabel.bottom-10, width: width-20, height: 44)
    }
    
    func configure(with viewModel: AlbumHeaderViewViewModel) {
        nameLabel.text = viewModel.albumName
        artistLabel.text = viewModel.artistName
        imageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
    }
}
