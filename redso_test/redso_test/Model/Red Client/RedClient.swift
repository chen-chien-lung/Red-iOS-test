//
//  RedClient.swift
//  redso_test
//
//  Created by Joe Chen on 2019/8/28.
//  Copyright © 2019 Joe Chen. All rights reserved.
//

import Foundation

class RedClient {
    
    
    enum Endpoints {
        static let base = "https://us-central1-redso-challenge.cloudfunctions.net/catalog"
        
        case getInfo(String, Int)
        
        var stringValue: String {
            
            switch self {
            case .getInfo(let team, let page):
                return Endpoints.base + "?team=\(team)&page=\(page)"
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                print("decode error")
            }
        }
        task.resume()
        
        return task
    }
    
    class func getinfoDetail(team :String, page:Int ,completion: @escaping (infoResponse?, Error?) -> Void) {
        let body = infoRequest(team: team, page: page)
        taskForGETRequest(url: Endpoints.getInfo(body.team, body.page).url, responseType: infoResponse.self) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func downloadImage(imgUrl: String, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: URL(string: imgUrl)!) { data, response, error in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
        task.resume()
    }
}
