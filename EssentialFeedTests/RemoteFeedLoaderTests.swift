//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by SherifShokry on 29/10/2021.
//

import Foundation
import XCTest


class RemoteFeedLoader {
    
    let client : HTTPClient
    let url : URL

    init(url: URL,client : HTTPClient){
        self.client = client
        self.url = url
    }
    
    func load(){
        client.get(from: url)
    }
    
}

protocol HTTPClient {
    func get(from url: URL)
}


class HTTPClientSpy : HTTPClient {
    
    var requestedUrl : URL?
    
    func get(from url: URL){
        self.requestedUrl = url
    }
}


class RemoteFeedLoaderTests : XCTestCase {
    
    func test_init_doesNotRequestDataFromURL(){
        let url =  URL(string: "www.essentialDeveloper.com")!
        let client = HTTPClientSpy()
        let _ = RemoteFeedLoader(url: url, client: client)
      
        XCTAssertNil(client.requestedUrl)
     }
    
    func test_load_requestDataFromUrl(){
        let url =  URL(string: "www.essentialDeveloper.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client : client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedUrl)
    }
    
    
}
