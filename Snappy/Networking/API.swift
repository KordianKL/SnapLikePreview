//
//  Created by Kordian Ledzion on 17.05.2017.
//  Copyright © 2017 Droids on Roids. All rights reserved.
//

import UIKit
import Alamofire

enum Endpoint {
    case uploadPhoto(image: UIImage, fromUserId: Int, toUserId: Int?)
    case getPhotos(userId: Int?)
    case removePhoto(filename: String, toUserId: Int?)
    
    var url: String {
        switch self {
        case .uploadPhoto:
            return "upload"
        case .getPhotos:
            return "get"
        case .removePhoto:
            return "remove"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .getPhotos:
            return .get
        case .uploadPhoto, .removePhoto:
            return .post
        }
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        switch self {
        case .uploadPhoto(let image, let fromUserId, let toUserId):
            return { multipartFormData in
                multipartFormData.append(image.data!, withName: "file", fileName: "file.jpg", mimeType: "image/jpeg")
                multipartFormData.append("\(fromUserId)".data(using: .utf8)!, withName: "from_userId")
                if let toUserId = toUserId {
                    multipartFormData.append("\(toUserId)".data(using: .utf8)!, withName: "to_userId")
                }
            }
        default:
            return nil
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .removePhoto(let fileName, _):
            return ["file_name": fileName]
        default: return nil
        }
    }
}

final class API {
    
    static let baseURL = URL(string: "https://snappyapp.herokuapp.com/images/")
    
    class func request(_ endpoint: Endpoint, completion: @escaping (((Bool), [String: Any]?) -> Void)) {
        guard let url = URL(string: endpoint.url, relativeTo: API.baseURL) else { fatalError() }
        
        switch endpoint {
        case .uploadPhoto:
            Alamofire.upload(multipartFormData: endpoint.multipartFormData!, to: url) { encodingResult in
                switch encodingResult {
                case .success(let request, _, _):
                    print("Encoding success")
                    
                    request.responseJSON { json in
                        switch json.result {
                        case .success(let value):
                            print("Response success: \(value)")
                            let dict = value as? [String: Any]
                            completion(dict?["error"] == nil, nil)
                            
                        case .failure(let error):
                            print("Response failure: \(error.localizedDescription)")
                            completion(false, nil)
                        }
                    }
                    
                case .failure(let error):
                    print("Encoding failure: \(error.localizedDescription)")
                    completion(false, nil)
                }
            }
            
        default:
            let request = try! URLRequest(url: url, method: endpoint.method)
            Alamofire.request(url, method: endpoint.method, parameters: endpoint.parameters).responseJSON { response in
                switch response.result {
                case .success(let value):
                    guard let valueDictionary = value as? [String: Any] else { return completion(false, nil) }
                    print(valueDictionary)
                    completion(true, valueDictionary)
                    
                case .failure(let error):
                    print("ERROR: \(error.localizedDescription)")
                    completion(false, nil)
                }
            }
        }
    }
}
