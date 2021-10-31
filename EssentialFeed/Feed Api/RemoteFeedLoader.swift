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
    
    public enum Error : Swift.Error {
        case connectivity
        case invalidData
    }
    public enum Result : Equatable{
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL,client : HTTPClient){
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> ()){
        client.get(from: url){ result in
        //    guard self != nil else { return }
            switch result {
            case let .success(data,response):
                print(self)
                completion(FeedItemsMapper.map(data, response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
 
    
}


