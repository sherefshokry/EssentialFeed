//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by SherifShokry on 29/10/2021.
//

import Foundation


public final class RemoteFeedLoader {
    
    private let client : HTTPClient
    private let url : URL
    
    public init(url: URL,client : HTTPClient){
        self.client = client
        self.url = url
    }
    
    public func load(){
        client.get(from: url)
    }
    
}

public protocol HTTPClient {
    func get(from url: URL)
}

