//
//  TwitchRequest.swift
//  FGCNetwork
//
//  Created by Jason nghe on 11/29/15.
//  Copyright © 2015 Peter Duong. All rights reserved.
//

import Foundation

//
//  TwitchRequest.swift
//  FGCNetwork
//
//  Created by Jason nghe on 11/29/15.
//  Copyright © 2015 Peter Duong. All rights reserved.
//

import Foundation

struct Stream {
    var status: String!
    var displayName: String!
    var channelName: String!
    var URL: String!
    var previewImageURL: String!
    var viewers: Int!
    var videoId: Int!
}

class TwitchRequest {
    // designated Init
    init() {
    }
    
    // MARK: - Youtube API Implementation
    func performGetRequest(targetURL: NSURL!, completion: (data: NSData?, HTTPStatusCode: Int, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: targetURL)
        request.HTTPMethod = "GET"
        
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        let session = NSURLSession(configuration: sessionConfiguration)
        
        let task = session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(data: data!, HTTPStatusCode: (response as! NSHTTPURLResponse).statusCode, error: error)
            })
        }
        task.resume()
    }
    
    func fetchStreamsOf(game: String?, completionHandler: (stream: Stream?) -> Void) {
        // Form the request URL string.
        var urlString = "https://api.twitch.tv/kraken/streams?game=\(game!)&stream_type=live&limit=1"
        urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        // Create a NSURL object based on the above string.
        let targetURL = NSURL(string: urlString)
        
        performGetRequest(targetURL) { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                do {
                    // Convert JSON data to dict
                    let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<NSObject, AnyObject>
                    
                    // Get all items from the playlist
                    let items: Array<Dictionary<NSObject, AnyObject>> = jsonResult[TwitchKey.Streams] as! Array<Dictionary<NSObject,AnyObject>>
                    if !items.isEmpty {
                        for var i = 0; i < items.count; i++ {
                            let resultDict = items[i][TwitchKey.Channel] as! Dictionary<NSObject,AnyObject>
                            
                            var streamObject = Stream()
                            streamObject.displayName = resultDict[TwitchKey.DisplayName] as? String
                            streamObject.status = resultDict[TwitchKey.Status] as? String
                            streamObject.channelName = resultDict[TwitchKey.Name] as? String
                            streamObject.previewImageURL = (items[i][TwitchKey.Preview] as? Dictionary<NSObject, AnyObject>)![TwitchKey.Large] as? String
                            streamObject.viewers = items[i][TwitchKey.Viewers] as? Int
                            streamObject.videoId = items[i][TwitchKey.VideoId] as? Int
                            streamObject.URL = resultDict[TwitchKey.URL] as? String
                            
                            completionHandler(stream: streamObject)
                        }
                    } else {
                        completionHandler(stream: nil)
                    }
                } catch {
                }
            } else {
                print("HTTPStatusCode = \(HTTPStatusCode)")
                print("Error while loading videos: \(error)")
            }
        }
    }
    
    struct TwitchKey {
        static let Streams = "streams"
        static let Game = "game"
        static let Viewers = "viewers"
        static let VideoId = "_id"
        static let Channel = "channel"
        static let Status = "status"
        static let DisplayName = "display_name"
        static let Name = "name"
        static let URL = "url"
        static let Preview = "preview"
        static let Small = "small"
        static let Medium = "medium"
        static let Large = "large"
    }
    
}