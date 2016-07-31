//
//  BambooClient.swift
//  Bamboo
//
//  Created by Dmytro Morozov on 08.05.16.
//  Copyright © 2016 Dmytro Morozov. All rights reserved.
//

import Foundation

class BambooClient {
    
    private let host: NSURL
    
    private let username: String
    
    private let password: String
    
    private enum Path {
        case Info
        case Result
    }
    
    private enum Verb: String {
        case Get = "GET"
        case Post = "POST"
        case Put = "PUT"
        case Delete = "DELETE"
    }
    
    private let paths: [Path: String] = [.Info: "info", .Result: "result"]
    
    init(_ host: NSURL, username: String, password: String) {
        self.host = NSURL(string: "/rest/api/latest/", relativeToURL: host)!
        self.username = username
        self.password = password
    }
    
    private func createRequest(verb: Verb, path: String, query: String? = nil) -> NSMutableURLRequest {
        let url = NSURL(string: query == nil ? path : "\(path)?\(query!)", relativeToURL: self.host)
        let request = NSMutableURLRequest(URL: url!)
        let login = NSString(format: "%@:%@", self.username, self.password)
        let loginData: NSData = login.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPMethod = verb.rawValue
        return request
    }
    
    private func executeRequest(request: NSMutableURLRequest, handler: (error: NSError?, data: [String: AnyObject]?) -> Void) {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 10
        NSURLSession(configuration: configuration).dataTaskWithRequest(request, completionHandler: {
            (data, response, error) -> Void in
            if error == nil {
                let response = response as! NSHTTPURLResponse
                if response.statusCode == 200 {
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [String: AnyObject]
                        handler(error: nil, data: json)
                    } catch let error as NSError {
                        handler(error: error, data: nil)
                    }
                } else {
                    let error = NSError(domain: "NSHTTPURLResponse", code: response.statusCode, userInfo: response.allHeaderFields)
                    handler(error: error, data: nil)
                }
            } else {
                handler(error: error, data: nil)
            }
        }).resume()
    }
    
    func info(handler: (error: NSError?, info: Info?) -> Void) -> Void {
        let request = self.createRequest(.Get, path: paths[.Info]!)
        self.executeRequest(request, handler: {
            (error, data) -> Void in
            if error == nil {
                if let info = Info(data!) {
                    handler(error: nil, info: info)
                } else {
                    handler(error: nil, info: nil)
                }
            } else {
                handler(error: error, info: nil)
            }
        });
    }
    
    func result(page: Page<Result>?, handler: (error: NSError?, result: Page<Result>?) -> Void) -> Void {
        let request = self.createRequest(.Get, path: paths[.Result]!, query: page?.next)
        self.executeRequest(request) {
            (error, data) -> Void in
            if let error = error {
                handler(error: error, result: nil)
            }
            else if let data = data, let result = Page<Result>(data) {
                handler(error: nil, result: result)
            }
        };
    }
    
}
