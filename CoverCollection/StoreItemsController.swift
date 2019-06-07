//
//  StoreItemsController.swift
//  CoverCollection
//
//  Created by Sam Blum on 11/3/18.
//  Copyright © 2018 Sam Blum. All rights reserved.
//

import Foundation

//Used to fetch items from Apple Music API
struct StoreItemController {

//Searches API using baseURL and query dictionary passed as parameter
    func fetchItems(matching query: [String: String], completion: @escaping ([AlbumCover]?) -> Void) {
        
        let baseURL = URL(string: "https://itunes.apple.com/search?")!
  

        guard let url = baseURL.withQueries(query) else {
            
            completion(nil)
            print("Unable to build URL with supplied queries. Please try again.")
            return
        }
//Searches URL and decodes JSON
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let data = data,
                let rawJSON = try? JSONSerialization.jsonObject(with: data),
                let json = rawJSON as? [String: Any],
                let resultsArray = json["results"] as? [[String: Any]] {
                
                //Stores results
                let albumCovers = resultsArray.compactMap { AlbumCover(json: $0) }
                completion(albumCovers)
                
            } else {
                print("Either no data was returned, or data was not serialized.")
                
                completion(nil)
                return
            }
        }
        
        task.resume()
    }
}
