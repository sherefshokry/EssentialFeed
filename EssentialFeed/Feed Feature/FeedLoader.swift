//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by SherifShokry on 29/10/2021.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> ())
}
