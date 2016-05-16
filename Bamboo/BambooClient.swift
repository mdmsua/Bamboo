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
    
    private let paths: [Path: String] = [.Info: "info", .Result: "result?max-result=100"]
    
    init(_ host: NSURL, username: String, password: String) {
        self.host = NSURL(string: "/rest/api/latest/", relativeToURL: host)!
        self.username = username
        self.password = password
    }
    
    private func createRequest(verb: Verb, path: String) -> NSMutableURLRequest {
        let url = NSURL(string: path, relativeToURL: self.host)
        let request = NSMutableURLRequest(URL: url!)
        let login = NSString(format: "%@:%@", self.username, self.password)
        let loginData: NSData = login.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPMethod = verb.rawValue
        return request
    }
    
    private func executeRequest(request: NSMutableURLRequest, handler: (error: NSError?, data: [NSObject: AnyObject]?) -> Void) {
        let session = NSURLSession.sharedSession()
        session.dataTaskWithRequest(request, completionHandler: {
            (data, response, error) -> Void in
            if error == nil {
                let response = response as! NSHTTPURLResponse
                if response.statusCode == 200 {
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! [NSObject: AnyObject]
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
    
    func result(handler: (error: NSError?, results: [Result]?) -> Void) -> Void {
        let request = self.createRequest(.Get, path: paths[.Result]!)
        self.executeRequest(request) {
            (error, data) -> Void in
            if let error = error {
                handler(error: error, results: nil)
            }
            else if let data = data {
                if data["results"] is NSObject && data["results"]!["result"] is [NSObject] {
                    let resultsJson = data["results"]!["result"] as! [NSObject]
                    var results = [Result]()
                    for resultJson in resultsJson {
                        if let itemJson = resultJson as? [NSObject: AnyObject] {
                            if let result = Result(itemJson) {
                                results.append(result)
                            }
                        }
                    }
                    handler(error: nil, results: results)
                }
            }
        };
    }
    
}