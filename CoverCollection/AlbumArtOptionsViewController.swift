//
//  AlbumArtOptionsViewController.swift
//  CoverCollection
//
//  Created by Sam Blum on 11/3/18.
//  Copyright © 2018 Sam Blum. All rights reserved.
//

import UIKit
import SafariServices

class AlbumArtOptionsViewController: UIViewController {
    
    @IBOutlet var albumArtImage: UIImageView!
    @IBOutlet var fullScreenButton: UIButton!
    @IBOutlet var viewInSafariButton: UIButton!
    
    var selectedAlbum: AlbumCover?
    var albumIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func optionsButtonPressed(_ sender: Any) {
        guard let image = albumArtImage.image else {return}
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = sender as? UIView
        present(activityController,animated: true, completion: nil)
    }
    
    @IBAction func safariButtonPressed(_ sender: Any) {
        guard let albumName = selectedAlbum?.albumTitle else {return}
        if let url = URL(string: "https://www.google.com/search?q=\(albumName)") {
             let safariViewController = SFSafariViewController(url: url)
            present(safariViewController,animated: true, completion: nil)
        }
    
    
}
}
