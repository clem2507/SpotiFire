//
//  GenresCollectionViewCell.swift
//  SpotifyRecommender
//
//  Created by Clement Detry on 02/09/2022.
//

import Foundation
import UIKit
import SDWebImage

class GenresCollectionViewCell: UICollectionViewCell {
    static let identifier = "GenresCollectionViewCell"
    
    private let genreNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemGray6
        contentView.addSubview(genreNameLabel)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        genreNameLabel.sizeToFit()
        
        let genreNameSize = genreNameLabel.sizeThatFits(CGSize(width: contentView.width-10, height: contentView.height-10))

        genreNameLabel.frame = CGRect(x: 20, y: 13, width: genreNameSize.width, height: genreNameSize.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        genreNameLabel.text = nil
    }
    
    func configure(with viewModel: GenreCellViewModel) {
        genreNameLabel.text = viewModel.genre
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

