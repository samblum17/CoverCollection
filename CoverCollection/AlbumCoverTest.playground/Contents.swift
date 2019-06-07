import UIKit

var str = "Hello, playground"

let baseURL = URL(string: "https://api.music.apple.com/v1/catalog/us/search?")!
let query: [String : Any] = [
    "term" : "Kids See Ghosts",
    "lang" : "en_us",
    "types" : ["albums"]
    
    ]
struct AlbumCover {
    var term: String
    var artwork: String
    init?(json: [String: Any]) {
        
        guard let term = json["term"] as? String,
            let artwork = json["artwork"] as? String
            else { return nil }
        
        self.term = term
        self.artwork = artwork
        
        
    }
}
extension URL {
    
    func withQueries(_ queries: [String: String]) -> URL? {
        
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = queries.compactMap { URLQueryItem(name: $0.0, value: $0.1) }
        return components?.url
    }
}
func fetchItems(matching query: [String: String], completion: @escaping ([AlbumCover]?) -> Void) {
guard let url = baseURL.withQueries(query) else {
    completion(nil)
    print("Unable to build URL with supplied queries. Please try again.")
    return
}

let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
    
    if let data = data,
        let rawJSON = try? JSONSerialization.jsonObject(with: data),
        let json = rawJSON as? [String: Any],
        let resultsArray = json["results"] as? [[String: Any]] {
        
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


let aString = "this is a test"
let bString = aString.replacingOccurrences(of: "this", with: "test", options: .literal, range: nil)



