//
//  AlbumCollectionViewController.swift
//  CoverCollection
//
//  Created by Sam Blum on 11/3/18.
//  Copyright © 2018 Sam Blum. All rights reserved.
//

import UIKit
import SafariServices
import MediaPlayer

//Cell identifier
private let reuseIdentifier = "CoverCell"

//Controls the collectionView
class AlbumCollectionViewController: UICollectionViewController, MPMediaPickerControllerDelegate {
//    static let shared = AlbumCollectionViewController()
   
//Outlets for buttons and views (some unused)
    @IBOutlet var albumArtImage: UIImageView!
    @IBOutlet var albumArtButton: UIButton!
    @IBOutlet var helpButton: UIBarButtonItem!
  
    
    
    @IBOutlet var darkModeButton: UIBarButtonItem!
    @IBOutlet var emptyCollectionView: UIView!
    @IBOutlet var emptyCollectionLabel: UILabel!
//Holds album covers in array
    static var albumCollection: [AlbumCover] = []
    let imageCache = NSCache<AnyObject, AnyObject>() //Cache image for faster loading

//User default declaration (used for style preferences not saving collection)
    let defaults = UserDefaults.standard
    
//Allows music to be controlled directly in app
    var mediaPlayer = MPMusicPlayerController.systemMusicPlayer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        navigationItem.rightBarButtonItem = editButtonItem
//Loads collection and saves
        if let savedCollection = AlbumCover.loadCollection() {
            AlbumCollectionViewController.albumCollection = savedCollection
        }
                
        checkForStylePreferences()
        showEmptyView()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    
   
//Moves covers and saves to new indexPath using a temp
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let firstCover = AlbumCollectionViewController.albumCollection[sourceIndexPath.row]
        
        AlbumCollectionViewController.albumCollection[sourceIndexPath.row] = AlbumCollectionViewController.albumCollection[destinationIndexPath.row]
        
        AlbumCollectionViewController.albumCollection[destinationIndexPath.row] = firstCover
        AlbumCover.saveCollection(AlbumCollectionViewController.albumCollection)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        //MARK- See if bug fix works by using viewWillAppear instaed of viewDidAppear
//        collectionView.reloadData()
//        collectionView?.performBatchUpdates(nil, completion: nil)
      

    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        collectionView?.performBatchUpdates(nil, completion: nil)

    }
//Loads album art from API
    func fetchImage(url: URL, completion: @escaping (UIImage?) ->
        Void) {
//        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//            if let data = data,
//                let image = UIImage(data: data) {
//                completion(image)
//            } else {
//                completion(nil)
//            }
//        }
        
        
        //Check if image is cached, load in if so
        if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? UIImage {
            //Highest priority queue
            DispatchQueue.main.async {
                let image = imageFromCache
                completion(image)
                return
            }
            //Image not cached, so pull from web, cache, and display
        } else {
            let task = URLSession.shared.dataTask(with: url) { (data,response, error) in
                
                guard let imageData = data else {
                    return
                }
                //Highest priority queue
                DispatchQueue.main.async {
                    let imageToCache = UIImage(data: data!)
                    self.imageCache.setObject(imageToCache!, forKey: url as AnyObject)
                    completion (imageToCache)
                }
                
                
            }
        
            task.resume()

        }
        
        
        
    }

//Return 1 section with x number of items in section (determined in next method)
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

//Number of items in section determined my number of album covers in collection
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return AlbumCollectionViewController.albumCollection.count
    }

//Assigns cell objects to corresponding album cover
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AlbumCollectionViewCell
        cell.deleteButtonBackgroundView.isHidden = true
        let albumCover = AlbumCollectionViewController.albumCollection[indexPath.row]
//Uncomment below line for debugging
//        print(albumCover.albumTitle)

        fetchImage(url: albumCover.artworkURL)
        { (image) in
            guard let image = image else { return }
    //Fetches album art image on highest priority queue
            DispatchQueue.main.async {
                if let currentIndexPath =
                    self.collectionView.indexPath(for: cell),
                    currentIndexPath != indexPath {
                    return
                }
                cell.albumArtImage.image = image
                cell.albumTitleLabel.text? = albumCover.albumTitle
                cell.setNeedsLayout()
        //Create border around cover
                cell.layer.borderColor = UIColor.lightGray.cgColor
                cell.layer.borderWidth = 0.5
                cell.delegate = self
        //Shows delete x when in editing mode
                cell.deleteButtonBackgroundView.isHidden = !self.isEditing
        //Save collection
                AlbumCover.saveCollection(AlbumCollectionViewController.albumCollection)
                self.showEmptyView()
                
            }
        }

        return cell

}
//Play music when cell is tapped
    @IBAction func playButtonTapped(_ sender: Any) {
        let mediaPickerVC = MPMediaPickerController(mediaTypes: .music)
        mediaPickerVC.popoverPresentationController?.sourceView = view
        mediaPickerVC.allowsPickingMultipleItems = true
        mediaPickerVC.showsCloudItems = true
        mediaPickerVC.delegate = self
        mediaPickerVC.prompt = "Create a queue of songs and albums"
        present(mediaPickerVC, animated: true, completion: nil)
        
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaPicker.dismiss(animated: true, completion: nil)
        mediaPlayer.setQueue(with: mediaItemCollection)
        mediaPlayer.play()
    }
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
        
    }
    
    //MARK- PRE-IOS13 CODE USED FOR MANUAL DARK MODE 
//Variable used for dark mode configuring (prior to iOS 13)
    /*For ios13 dark mode compatibility- natively switches now that
     deployment is set. Keep manual option active too*/
static var isOn: Bool = true

//Toggle dark mode (prior to iOS 13)
    @IBAction func darkModeButtonTapped(_ sender: Any) {
        darkModeTabBar()
        saveStylePreferences()
        let item = self.navigationItem.leftBarButtonItem!
        let button = item.customView as! UIButton
        if AlbumCollectionViewController.isOn == false {
            button.setTitle("Dark Mode", for: .normal)
            AlbumCollectionViewController.isOn = true
            self.collectionView.backgroundColor = UIColor.white
//            UITabBar.appearance().barTintColor = UIColor.white
            self.navigationController?.navigationBar.barTintColor = .white
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        } else {
            AlbumCollectionViewController.isOn = false
            button.setTitle("Light Mode", for: .normal)
        self.collectionView.backgroundColor = UIColor.black
//        UITabBar.appearance().barTintColor = UIColor.black
        self.navigationController?.navigationBar.barTintColor = .black
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

                }

    }

    func darkModeTabBar() {
        if AlbumCollectionViewController.isOn == true {
    self.tabBarController?.tabBar.barStyle = .black
    UserDefaults.standard.set(AlbumCollectionViewController.isOn, forKey: "darkModeState")
    saveStylePreferences()
        }else{
    self.tabBarController?.tabBar.barStyle = .default
    UserDefaults.standard.set(AlbumCollectionViewController.isOn, forKey: "darkModeState")


        }

    }

//User defaults to save style preferences
    func saveStylePreferences() {
        defaults.set(AlbumCollectionViewController.isOn, forKey: "saveDarkMode")
    }


    func checkForStylePreferences() {
        let prefersDarkMode = defaults.bool(forKey: "saveDarkMode")
        if prefersDarkMode {
            AlbumCollectionViewController.isOn = true
            darkModeButtonTapped(Any?.self)
        }
    }
    
    //MARK: Before 2.0.1 help button was where Dark Mode Button is now//
        //^Move help button back for iOS 13 update
    
    
    // MARK: UICollectionViewDelegate unused methods

    
    // Uncomment this method to specify if the specified item should be highlighted during tracking
//    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
//        return true
//    }
    

    
    // Uncomment this method to specify if the specified item should be selected
//    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        return true
//    }
    
   

//
//    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
//    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
//        return true
//    }
//

            // MARK - Deleting Cells
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        AlbumCollectionViewController.albumCollection.remove(at: indexPath.row)
        collectionView.deleteItems(at: [indexPath])
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if let indexPaths = collectionView?.indexPathsForVisibleItems {
            for indexPath in indexPaths {
                if let cell = collectionView?.cellForItem(at: indexPath) as? AlbumCollectionViewCell {
                    cell.isEditing = editing
                }
            }
        }

        AlbumCover.saveCollection(AlbumCollectionViewController.albumCollection)
        
    }
//Shows directions for adding covers when collection is empty
    func showEmptyView () {
        if AlbumCollectionViewController.albumCollection.isEmpty {
            emptyCollectionView.isHidden = false
        } else {
            emptyCollectionView.isHidden = true
        }
    }
   
   
}

//Accesses cell class for deleting cells
extension AlbumCollectionViewController : AlbumCollectionViewCellDelegate {
    func delete(cell: AlbumCollectionViewCell) {
        if let indexPath = collectionView?.indexPath(for: cell) {
            AlbumCollectionViewController.albumCollection.remove(at: indexPath.row)
            collectionView?.deleteItems(at: [indexPath])
        }
       
        AlbumCover.saveCollection(AlbumCollectionViewController.albumCollection)
        showEmptyView()
    }
}
 


