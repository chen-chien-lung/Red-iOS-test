//
//  GetInfoResponse.swift
//  redso_test
//
//  Created by Joe Chen on 2019/8/29.
//  Copyright © 2019 Joe Chen. All rights reserved.
//

import Foundation


struct infoResponse: Codable {
    
    let results: [details]
    
    enum CodingKeys:String, CodingKey {
        case results
    }
}

struct details: Codable {
    
    let id: String?
    let type: String?
    let name: String?
    let position: String?
    let expertise: [String]?
    let avatar : String?
    let url : String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case name
        case position
        case expertise
        case avatar
        case url
    }
    
}
