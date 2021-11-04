//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by SherifShokry on 04/11/2021.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }
    
    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
