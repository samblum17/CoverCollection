//
//  AlbumCollectionViewCell.swift
//  CoverCollection
//
//  Created by Sam Blum on 11/3/18.
//  Copyright © 2018 Sam Blum. All rights reserved.
//

import UIKit


//Protocol to remove a cell from collection
protocol AlbumCollectionViewCellDelegate: class
{
    func delete(cell: AlbumCollectionViewCell)
}

//Custom cell in collectionView
class AlbumCollectionViewCell: UICollectionViewCell {
    weak var delegate: AlbumCollectionViewCellDelegate?
//Variables to hold album art objects
    @IBOutlet var albumArtImage: UIImageView!
    @IBOutlet var albumTitleLabel: UILabel!
    @IBOutlet var deleteButtonBackgroundView: UIVisualEffectView!
    var urlString = ""
    
//Method to remove album from collection programatticaly
    var deleteButtonSet: String! {
        didSet{
            albumArtImage.image = UIImage(named: "updated_delete")
            deleteButtonBackgroundView.layer.cornerRadius = deleteButtonBackgroundView.bounds.width / 2.0
            deleteButtonBackgroundView.layer.masksToBounds = true
            deleteButtonBackgroundView.isHidden = !isEditing
            
        }
    }
//Method to show x image in top right of cell
    var isEditing: Bool = false {
        didSet {
            deleteButtonBackgroundView.isHidden = !isEditing 
        }
    }

//Accesses delegate to delete cell when button tapped
    @IBAction func deleteButtonPressed(_ sender: Any) {
        delegate?.delete(cell: self)
        
    }
}

