//
//  AlbumCover.swift
//  CoverCollection
//
//  Created by Sam Blum on 11/3/18.
//  Copyright © 2018 Sam Blum. All rights reserved.
//

import Foundation

//Struct to hold album cover object details
struct AlbumCover: Codable {
    var albumTitle: String
    var artist: String
    var artworkURL: URL

//Create save destination for collection
    static let DocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("albumColletion").appendingPathExtension("plist")

//Loads collection into collectionView by accessing ArchiveURL
    static func loadCollection () -> [AlbumCover]? {
        guard let codedCollection = try? Data(contentsOf: ArchiveURL) else {return nil}
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode(Array<AlbumCover>.self, from: codedCollection)
       
    }

//Saves collection to ArchiveURL
    static func saveCollection (_ collection: [AlbumCover]) {
        let propertyListEncoder = PropertyListEncoder()
        let codedCollection = try? propertyListEncoder.encode(AlbumCollectionViewController.albumCollection)
        try? codedCollection?.write(to: ArchiveURL, options: .noFileProtection)
      
    }
    

//Initializer to decode JSON return from Apple Music API since not all keys returned are used
    //Warning: Do not model for future app development. This is Swift 3 and below syntax
    init?(json: [String: Any]) {

        guard let albumTitle = json["collectionName"] as? String,
            let artist = json["artistName"] as? String,
            let artworkURLString = json["artworkUrl100"] as? String,
            let artworkURLString2 = artworkURLString.replacingOccurrences(of: "100x100", with: "600x600") as? String,
            let artworkURL = URL(string: artworkURLString2) else { return nil }

        self.albumTitle = albumTitle
        self.artist = artist
        self.artworkURL = artworkURL
    
}
}
