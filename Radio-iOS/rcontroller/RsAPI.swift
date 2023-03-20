

import Foundation

internal struct RsAPI {
    
    
    static func getArtwork(for metadata: String, size: Int, completionHandler: @escaping (_ artworkURL: URL?) -> ()) {
        
        
        guard !metadata.isEmpty, metadata !=  " - ", let url = getURL(with: metadata) else {
            completionHandler(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            guard error == nil, let data = data else {
                completionHandler(nil)
                return
            }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            var artworkURL: URL!
            
            let parsedResult = json as? [String: Any]
            let resultCounts = parsedResult![Keys.resultCount] as! Int
            if (resultCounts == 0){
                
                artworkURL = URL(string: DEF_IMG)
                
            } else {
                
                let results = parsedResult![Keys.results] as? Array<[String: Any]>
                let result = results?.first
                var artwork = result?[Keys.artwork] as? String
                
                artwork = artwork!.replacingOccurrences(of: "100x100", with: "600x600")
                artworkURL = URL(string: artwork!)
            }
            
            completionHandler(artworkURL)
        }).resume()
    }
    
    private static func getURL(with term: String) -> URL? {
        var components = URLComponents()
        components.scheme = Domain.scheme
        components.host = Domain.host
        components.path = Domain.path
        components.queryItems = [URLQueryItem]()
        components.queryItems?.append(URLQueryItem(name: Keys.term, value: term))
        components.queryItems?.append(URLQueryItem(name: Keys.entity, value: Values.entity))
        
        return components.url
    }
    
    
    private struct Domain {
        static let scheme = "https"
        static let host = "itunes.apple.com"
        static let path = "/search"
    }
    
    private struct Keys {
        static let term = "term"
        static let entity = "entity"
        static let resultCount = "resultCount"
        
        static let results = "results"
        static let artwork = "artworkUrl100"
    }
    
    private struct Values {
        static let entity = "song"
    }
}

