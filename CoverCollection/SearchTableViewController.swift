//
//  SearchTableViewController.swift
//  CoverCollection
//
//  Created by Sam Blum on 11/3/18.
//  Copyright © 2018 Sam Blum. All rights reserved.
//

import UIKit
import GoogleMobileAds


//Searches for album covers
class SearchTableViewController: UITableViewController, UINavigationControllerDelegate {

//Outlets and objects
    @IBOutlet var newAlbumSearchBar: UISearchBar!
    var activityIndicatorView: UIActivityIndicatorView!
    let imageCache = NSCache<AnyObject, AnyObject>() //Cache images for faster loading
    @IBOutlet var bannerView: GADBannerView!
    
//Array to hold search results
    var searchItems = [AlbumCover]()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    //Swipe down on keyboard to dismiss
        tableView.keyboardDismissMode = .interactive
        
    //Set up ads
        //Change adUnitID when ready to deploy to App Store
        bannerView.adUnitID = "ca-app-pub-3264342285166813/9747755757"
        bannerView.rootViewController = self
        let request = GADRequest()
        bannerView.load(request)

    }
    
    

    let itemController = StoreItemController()
    
//Searches Apple Music API using defined query
    func fetchMatchingItems() {
        
        self.searchItems = []
        self.tableView.reloadData()
        
        let searchTerm = newAlbumSearchBar.text ?? ""
        
        if !searchTerm.isEmpty {
            
    // set up query dictionary
            let query = [
                "term" : searchTerm,
                "lang" : "en_us",
                "entity" : "album"
            ]
            
    // use the item controller to fetch items
            itemController.fetchItems(matching: query, completion: { (searchItems) in
                
    //Searches for covers on highest priority queue
                DispatchQueue.main.async {
                    if let searchItems = searchItems {
                        self.searchItems = searchItems
                        self.activityIndicatorView.stopAnimating()
                        self.tableView.separatorStyle = .singleLine
                        self.tableView.reloadData()
                        
                        //When no results, show alert message
                        if self.searchItems.count == 0 {
                            let alertController = UIAlertController(title: "No results", message: "No albums to display. Either the album you searched for was spelled incorrectly or network connection was lost. Please try again.", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }  else {
                        print ("Unable to reload")
                    }
                }
            }
           
            
            )
    }
    }

//Set up result cell
    func configure(cell: UITableViewCell, forItemAt indexPath: IndexPath) {
        
        let item = searchItems[indexPath.row]
        
        cell.textLabel?.text = item.albumTitle
        cell.detailTextLabel?.text = item.artist
        //Placeholder loading image
        cell.imageView?.image = #imageLiteral(resourceName: "NewSolid_gray")
        
        //Set actual album art image from cache
        if let imageFromCache = imageCache.object(forKey: item.artworkURL as AnyObject) as? UIImage {
            DispatchQueue.main.async {
                cell.imageView?.image = imageFromCache
            }
            //If not found in cache, pull from web, cache, and load into cell
        } else {
            let task = URLSession.shared.dataTask(with: item.artworkURL) { (data,response, error) in
                
                guard let imageData = data else {
                    return
                }
                
                //Highest priority queue
                DispatchQueue.main.async {
                    
                    let imageToCache = UIImage(data: imageData)
                    self.imageCache.setObject(imageToCache!, forKey: item.artworkURL as AnyObject)
                    cell.imageView?.image = imageToCache
                }
            }
        
        task.resume()
     
        }
    }
    
    // MARK: - Table view data source
    
    
//Number of rows defined by amount of results in array
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchItems.count
        
        }
    
//Customize cell by accessing configure method
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath)
      
        
//        if let albumCollectionVC = self.tabBarController?.viewControllers?.first as? AlbumCollectionViewController {
//            albumCollectionVC.
//        }

        // Configure the cell...
        configure(cell: cell, forItemAt: indexPath)
        return cell
    }
    
//Set up help button
    @IBOutlet var helpButton: UIBarButtonItem!
    @IBAction func helpButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Welcome to Cover Collection!", message: "- To start your album cover collection, simply search for an album and select the artwork you would like to add.\n- Searching for an album requires an internet connection.\n- Reorganize your collection by pressing edit. Hold an album cover and drag to the desired location to reorder. Press the x to remove.\n- Set the color scheme to be dark or light mode manually by tapping the button in the upper left corner or automatically with iOS 13 integration based on your current display settings.\n- Tap an album cover to search and play the album straight from the app. Manage playback in control center.\n- More questions? Leave a review on the App Store, and we'd love to help.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Thanks", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
//Action when result is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
//        self.performSegue(withIdentifier: "toCollection", sender: indexPath.row)
        let alertController = UIAlertController(title: "Would you like to add this album artwork to your collection?", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Add to My Collection", style: .default, handler: { action in
                let selectedAlbum = self.searchItems[indexPath.row]
                AlbumCollectionViewController.albumCollection.append(selectedAlbum)
                self.tabBarController?.selectedIndex = 0
            }
        ))
        AlbumCover.saveCollection(AlbumCollectionViewController.albumCollection)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        self.tableView.deselectRow(at: indexPath, animated: true)
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // you can set this as per your requirement.
            popoverController.permittedArrowDirections = [] //to hide the arrow of any particular direction
        }
    }
    
//Load network indicator on background view
    override func loadView() {
        super.loadView()
        
        activityIndicatorView = UIActivityIndicatorView(style: .gray)
        
        tableView.backgroundView = activityIndicatorView
    }

}

//Allows searching when search button tapped on keyboard
extension SearchTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ newAlbumSearchBar: UISearchBar) {
        activityIndicatorView.startAnimating()
        tableView.separatorStyle = .none
        fetchMatchingItems()
        newAlbumSearchBar.resignFirstResponder()
    }
}

                //MARK- Unused methods and tests


    
//            let alertController = UIAlertController(title: "No results", message: "Please check your internet connection and album spelling, and then try again.", preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//            self.present(alertController, animated: true, completion: nil)
//        }




    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


