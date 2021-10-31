//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by SherifShokry on 31/10/2021.
//

import Foundation

public enum HTTPClientResult {
    case success(Data,HTTPURLResponse)
    case failure(RemoteFeedLoader.Error)
}


public protocol HTTPClient {
    func get(from url: URL,completion: @escaping (HTTPClientResult) -> ())
}
