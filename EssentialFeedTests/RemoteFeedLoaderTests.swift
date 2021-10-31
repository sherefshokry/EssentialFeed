
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
        
        XCTAssertTrue(client.requestedUrls.isEmpty)
    }
    
    func test_load_requestDataFromUrl(){
        let url = URL(string: "www.essentialDeveloper.com")!
        let (sut,client) = makeSUT(url: url)
        
        sut.load{_ in}
        
        XCTAssertEqual(client.requestedUrls , [url])
    }
    
    func test_loadTwice_requestDataFromUrlTwice(){
        let url = URL(string: "www.essentialDeveloper.com")!
        let (sut,client) = makeSUT(url: url)
        
        sut.load{_ in}
        sut.load{_ in}
        
        XCTAssertEqual(client.requestedUrls , [url,url])
    }
    
    func test_load_deliversErrorWhenClientError(){
        let url = URL(string: "www.essentialDeveloper.com")!
        let (sut,client) = makeSUT(url: url)
        
        expect(sut, toCompleteWith: .failure(.connectivity), when: {
            client.complete(with: .connectivity)
        })
        
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse(){
        let url = URL(string: "www.essentialDeveloper.com")!
        let (sut,client) = makeSUT(url: url)
        let samples = [199,201,300,400,500]
        samples.enumerated().forEach { index,code in
            expect(sut, toCompleteWith: .failure(.invalidData), when: {
                let json = makeItemsJSON(items: [])
                client.complete(withStatusCode: code, withData: json, at: index)
            })
        }
        
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON(){
        let (sut,client) = makeSUT()
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            let invalidJSON = Data("Invalid JSON".utf8)
            client.complete(withStatusCode: 200,withData: invalidJSON)
        }
    }
    
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyList(){
        let (sut,client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            let emptyData = makeItemsJSON(items: [])
            client.complete(withStatusCode: 200, withData: emptyData)
        }
        
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems(){
        let (sut,client) = makeSUT()
        
        let item1 = makeItem(id: UUID(),
                             imageUrl: URL(string: "www.a-url.com")!)
        
        let item2 = makeItem(id: UUID(),
                             description: "Another description",
                             location: "Another Location",
                             imageUrl: URL(string: "www.another-url.com")!)
        
        
        let items = [item1.model,item2.model]
        expect(sut, toCompleteWith: .success(items)) {
            let jsonData = makeItemsJSON(items: [item1.json,item2.json])
            client.complete(withStatusCode: 200, withData: jsonData)
        }
        
    }
    
    
    
    
    // Mark: - Helpers
    
    private func makeSUT(url : URL = URL(string: "www.essentialDeveloper.com")!,_ file: StaticString = #filePath,_ line: UInt = #line) -> (sut: RemoteFeedLoader,client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(sut,file,line)
        trackForMemoryLeaks(client,file,line)
        return (sut,client)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject,_ file: StaticString = #filePath ,_ line: UInt = #line){
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance,"Instance should have been deallocated , Potential memory leak",file: file , line: line)
        }
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageUrl : URL) -> (model: FeedItem, json:[String:Any]) {
        let item = FeedItem(id: id, description: description , location: location, imageUrl: imageUrl)
        let json = [
            "id" : item.id.uuidString ,
            "description" : item.description ,
            "location" : item.location ,
            "image": item.imageURL.absoluteString
        ].compactMapValues{ $0 }
        //            .reduce(into: [String:Any]()) { (acc,e) in
        //            if let value = e.value { acc[e.key] = value }
        //        }
        
        return (item,json)
        
    }
    
    func makeItemsJSON(items : [[String:Any]]) -> Data {
        let itemsJSON = ["items" : items]
        let jsonData = try! JSONSerialization.data(withJSONObject: itemsJSON)
        return jsonData
    }
    
    
    private func expect(_ sut : RemoteFeedLoader,toCompleteWith result : RemoteFeedLoader.Result , when action: () -> Void,file: StaticString = #filePath  , line: UInt = #line){
        
        var capturedResults : [RemoteFeedLoader.Result] = []
        sut.load{ capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults , [result] ,file : file ,line: line)
    }
    
    
    private class HTTPClientSpy : HTTPClient {
        private var messages : [(url : URL,completion :(HTTPClientResult) -> () )] = []
        
        var requestedUrls :[URL] {
            return messages.map{ $0.url }
        }
        
        func get(from url: URL, completion: @escaping ((HTTPClientResult) -> ())) {
            self.messages.append((url,completion))
        }
        
        
        func complete(with error: RemoteFeedLoader.Error ,at index: Int = 0){
            self.messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode statusCode : Int,withData data : Data  ,at index : Int = 0){
            let urlResponse = HTTPURLResponse(url: requestedUrls[index]
                                              , statusCode: statusCode
                                              , httpVersion: nil
                                              , headerFields: nil)
            self.messages[index].completion(.success(data, urlResponse!))
            
            
        }
        
    }
    
    
}
