//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by SherifShokry on 01/11/2021.
//

import Foundation
import XCTest
import EssentialFeed

class URLSessionHTTPClientTests : XCTestCase {
    
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequestes()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGETRequestWithURL(){
        let url = anyURL()
        let exp = expectation(description: "waiting for request")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url,url)
            XCTAssertEqual(request.httpMethod , "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url){ _ in }
        wait(for: [exp], timeout: 1.0)
    }
    
    
    
    
    func test_getFromURL_failsOnRequestError(){
        let requestError = anyNSError()
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as NSError?
        
        XCTAssertEqual(receivedError?.domain,requestError.domain)
        XCTAssertEqual(receivedError?.code,requestError.code)
        
    }
    
    func test_getFromURL_failsOnAllInvalidRepresntationCases(){
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPUrlResponse(), error: nil))
        //Here our url loading system replace the nil data with empty Data() so this will not return un expected error
//       XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPUrlResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil,response: nonHTTPUrlResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil,response: anyHTTPUrlResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPUrlResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPUrlResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPUrlResponse(), error: nil))
    }
    
    func test_getFromURL_suceedsOnHTTPURLResponseWithData() {
        let anyData = anyData()
        let response = anyHTTPUrlResponse()
        URLProtocolStub.stub(data: anyData, response: response, error: nil)
        let exp = expectation(description: "waiting for Success")
        makeSUT().get(from: anyURL()){ result in
            switch result{
            case let (.success(receivedData,receivedResponse)):
                XCTAssertEqual(receivedData, anyData)
                XCTAssertEqual(receivedResponse.url, response.url)
                XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
            default:
              XCTFail("expected success, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        
    }
    
    func test_getFromURL_suceedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPUrlResponse()
        URLProtocolStub.stub(data: nil, response: response, error: nil)
        let exp = expectation(description: "waiting for Success")
        makeSUT().get(from: anyURL()){ result in
            switch result{
            case let (.success(receivedData,receivedResponse)):
                let emptyData = Data()
                XCTAssertEqual(receivedData, emptyData)
                XCTAssertEqual(receivedResponse.url, response.url)
                XCTAssertEqual(receivedResponse.statusCode, response.statusCode)
            default:
              XCTFail("expected success, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        
    }
    
    
    
 
    
    
    
    
    
    // MARK: - Helpers
    
    
    private func makeSUT(_ file: StaticString = #filePath,_ line: UInt = #line) -> HTTPClient{
        let sut = URLSessionHTTPClient()
        
        trackForMemoryLeaks(sut,file,line)
        
        return sut
    }
    
    private func anyURL() -> URL {
        return URL(string: "www.essentialDeveloper.com")!
    }
    
    private func anyData() -> Data {
        return Data.init(bytes: "any data".utf8)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "domain", code: 1)
    }
    
    private func anyHTTPUrlResponse() -> HTTPURLResponse {
        return HTTPURLResponse()
    }
    
    private func nonHTTPUrlResponse() -> URLResponse {
        return URLResponse()
    }
    
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?,_ file: StaticString = #filePath,_ line: UInt = #line) -> Error? {
        
        URLProtocolStub.stub(data: data, response: response, error: error)
        let exp = expectation(description: "waiting for error")
        var receivedError : Error?
        makeSUT(file,line).get(from: anyURL()){ result in
            switch result {
            case let .failure(error):
                receivedError = error
                break
            default:
                XCTFail("Expected Failure, got \(result) instead",file: file,line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    
    private final class URLProtocolStub: URLProtocol {
        
        private static var stub : Stub?
        private static var capturedRequests : ((URLRequest) -> ())?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?){
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> ()){
            capturedRequests = observer
        }
        
        static  func startInterceptingRequestes(){
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests(){
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            capturedRequests = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            capturedRequests?(request)
            return request
        }
        
        
        override func startLoading() {
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
            
        }
        
        override func stopLoading() {}
        
        
        
    }
    
    
    //    private final class URLSessionSpy: URLSession {
    //
    //        private var stubs = [URL: Stub]()
    //
    //        struct Stub {
    //            let task : URLSessionDataTask
    //            let error: Error?
    //        }
    //
    //        func stub(url: URL , task: URLSessionDataTask,error : Error? = nil){
    //            stubs[url] = Stub(task: task, error: error)
    //        }
    //
    //        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
    //            guard let stub = stubs[url] else{
    //                fatalError("Could not find stub for this url \(url)")
    //            }
    //            completionHandler(nil,nil,stub.error)
    //            return stub.task
    //        }
    //
    //    }
    //
    //
    //    private class FakeURLSessionDataTask: URLSessionDataTask {
    //        override func resume() {}
    //    }
    //    private class URLSessionDataTaskSpy: URLSessionDataTask {
    //        var task = 0
    //
    //        override func resume() {
    //            task += 1
    //        }
    //
    //    }
    
    
}
