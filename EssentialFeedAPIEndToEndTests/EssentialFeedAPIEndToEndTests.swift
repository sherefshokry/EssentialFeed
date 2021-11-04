//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by SherifShokry on 03/11/2021.
//

import XCTest
import EssentialFeed

class EssentialFeedAPIEndToEndTests: XCTestCase {

    func test_endToEndTestServerGetFeedresult_matchesFixedTestAccountData(_ file: StaticString = #filePath,_ line: UInt = #line){
        let url = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(client,file,line)
        trackForMemoryLeaks(loader,file,line)
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult : LoadFeedResult?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
        
        switch receivedResult {
        case let .success(receivedFeedItems):
            XCTAssertEqual(receivedFeedItems.count,8, "Expected 8 items in the test account feed")
        case let .failure(error):
            XCTFail("expected success,got \(error) instead")
        default:
            XCTFail("expected success,got no result instead")
        }
        
    }

}
