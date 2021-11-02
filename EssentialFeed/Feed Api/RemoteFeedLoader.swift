//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by SherifShokry on 29/10/2021.
//

import Foundation


public final class RemoteFeedLoader: FeedLoader{
    
    private let client : HTTPClient
    private let url : URL
    
    public enum Error : Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
    
    
    public init(url: URL,client : HTTPClient){
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> ()){
        client.get(from: url){[weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data,response):
               // print(self)
               completion(FeedItemsMapper.map(data, response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
 
    
}


//func fetchImages() async throws -> [UIImage] {
//do {
//    let images = try await fetchImages()
//    let resizedImages = try await resizeImages(images
//    print("Fetched \(images.count) images.")
//} catch {
//    print("Fetching images failed with error \(error)")
//}
//}

