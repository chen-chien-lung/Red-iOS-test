//
//  GetInfoRequest.swift
//  redso_test
//
//  Created by Joe Chen on 2019/8/29.
//  Copyright © 2019 Joe Chen. All rights reserved.
//

import Foundation

struct infoRequest: Codable {
    
    let team : String
    let page : Int
    
    enum CodingKeys:String, CodingKey {
        case team
        case page
    }
}
