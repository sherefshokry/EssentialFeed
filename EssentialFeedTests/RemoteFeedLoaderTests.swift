//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by SherifShokry on 29/10/2021.
//

import Foundation
import XCTest
import EssentialFeed

class RemoteFeedLoaderTests : XCTestCase {
    
    func test_init_doesNotRequestDataFromURL(){
        let (_,client) = makeSUT()
        
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_requestDataFromUrl(){
        
        let (sut,client) = makeSUT()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedUrl)
    }
    
    
    // Mark: - Helpers
    
    private func makeSUT(url : URL = URL(string: "www.essentialDeveloper.com")!) -> (sut: RemoteFeedLoader,client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: client)
        return (remoteFeedLoader,client)
    }
    
    
    private class HTTPClientSpy : HTTPClient {
        
        var requestedUrl : URL?
        
        func get(from url: URL){
            self.requestedUrl = url
        }
    }
    
    
}
