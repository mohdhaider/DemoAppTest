import Foundation


typealias NetworkTaskCompletion = (URLRequest?, URLResponse?, Data?, Error?) -> Void

final class ImageNetworkLayer {
    
    private enum RequestMethod: String {
        case GET, POST, PUT, DELETE
    }
    
    static let shared = ImageNetworkLayer()
    
    private var session: URLSession {
        return URLSession(configuration: .ephemeral)
    }
    
    private init() {
        
    }
    
    private func httpMethodString(for method: RequestMethod) -> String {
        return method.rawValue
    }
    
    private func resumeTask(with request: URLRequest, completion: @escaping NetworkTaskCompletion) {
        
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error) -> Void in
            
            completion(request, response, data, error)
            
        })
        task.resume()
    }
}

extension ImageNetworkLayer {
    
    private func request(with urlString: String) -> URLRequest? {
        
        guard let escapedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        guard let requestURL = URL(string: escapedUrlString) else {
            return nil
        }
        return URLRequest(url: requestURL)
    }
    
    func get(url: String, completion: @escaping NetworkTaskCompletion) {
        
        guard var request = request(with: url) else {
            completion(nil, nil, nil, nil)
            return
        }
        request.httpMethod = httpMethodString(for: .GET)
        resumeTask(with: request as URLRequest, completion: completion)
    }
}

