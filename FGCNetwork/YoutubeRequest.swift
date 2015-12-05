//
//  YoutubeRequest.swift
//  FGCNetwork
//
//  Created by Jason nghe on 11/29/15.
//  Copyright © 2015 Peter Duong. All rights reserved.
//

//
//  YoutubeAPI.swift
//  FGCNetwork
//
//  Created by Jason nghe on 11/23/15.
//  Copyright © 2015 Peter Duong. All rights reserved.
//

import Foundation

struct Youtube {
    var title: String?
    var videoId: String?
    var channelTitle: String?
    var description: String?
    var thumbnail: String?
}


class YoutubeRequest {
    
    let apiKey = "AIzaSyApR_uJPNcIOkSiSnI7thU3EoFtbkOQK_g"
    var youtubeList: Array<Youtube> = []
    
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
    
    func fetchVideosOf(player: String?, withGame game: String, completionHandler: (youtubeObjects: Array<Youtube>?) -> Void) {
        if let player = player {
            // Form the request URL string.
            var urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(game)%20\(player)&type=video&key=\(apiKey)"
            urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            // Create a NSURL object based on the above string.
            let targetURL = NSURL(string: urlString)
            
            performGetRequest(targetURL) { (data, HTTPStatusCode, error) -> Void in
                if HTTPStatusCode == 200 && error == nil {
                    do {
                        // Convert JSON data to dict
                        let resultsDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<NSObject, AnyObject>
                        // Get all items from the playlist
                        let items: Array<Dictionary<NSObject, AnyObject>> = resultsDict["items"] as! Array<Dictionary<NSObject,AnyObject>>
                        for var i = 0; i < items.count; i++ {
                            let playlistSnippetDict = (items[i] as Dictionary<NSObject, AnyObject>)["snippet"] as! Dictionary<NSObject, AnyObject>
                            
                            // Init a new dict and store the data
                            var youtubeObject = Youtube()
                            youtubeObject.description = playlistSnippetDict["description"] as? String
                            youtubeObject.thumbnail =  ((playlistSnippetDict["thumbnails"] as! Dictionary<NSObject, AnyObject>)["high"] as! Dictionary<NSObject, AnyObject>)["url"] as? String
                            
                            youtubeObject.title = playlistSnippetDict["title"] as? String
                            youtubeObject.videoId = (playlistSnippetDict["resourceId"] as! Dictionary<NSObject, AnyObject>)["videoId"] as? String
                            youtubeObject.channelTitle = playlistSnippetDict["channelTitle"] as? String
                            
                            // Append the fetched Videos into the videos array
                            self.youtubeList.append(youtubeObject)
                            completionHandler(youtubeObjects: self.youtubeList)
                        }
                        
                    } catch {
                        
                    }
                } else {
                    print("HTTPStatusCode = \(HTTPStatusCode)")
                    print("Error while loading videos: \(error)")
                    
                }
            }
        }
    }
    
    func fetchVideosOf(playlist playlistId: String, maxResults: Int = 5, completionHandler: (youtubeObjects: Array<Youtube>?) -> Void) {
        // From url request string


        let urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(playlistId)&maxResults=\(maxResults)&key=\(apiKey)"
        
        // Create a NSURL based on above string
        let targetURL = NSURL(string: urlString)
        
        performGetRequest(targetURL) { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                do {
                    // Convert JSON data to dict
                    let resultsDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<NSObject, AnyObject>

                    // Get all items from the playlist
                    let items: Array<Dictionary<NSObject, AnyObject>> = resultsDict["items"] as! Array<Dictionary<NSObject,AnyObject>>
                    
                    for var i = 0; i < items.count; i++ {
                        let playlistSnippetDict = (items[i] as Dictionary<NSObject, AnyObject>)["snippet"] as! Dictionary<NSObject, AnyObject>
                        

                        let description =  playlistSnippetDict["description"] as? String
                        let title = playlistSnippetDict["title"] as? String
                        let videoId = (playlistSnippetDict["resourceId"] as! Dictionary<NSObject, AnyObject>)["videoId"] as? String
                        let channelTitle = playlistSnippetDict["channelTitle"] as? String
                        
                        var thumbnail: String? = nil
                        if let thumbnails = playlistSnippetDict["thumbnails"] as? Dictionary<NSObject, AnyObject> {
                            if let defaultImage = thumbnails["default"] as? Dictionary<NSObject, AnyObject> {
                                if let url = defaultImage["url"] as? String {
                                    thumbnail = url
                                }
                            }
                        }
                        
                        // Init a new dict and store the data
                        var youtube = Youtube()
                        if let description = description {
                            youtube.description = description
                            if let thumbnail = thumbnail {
                                youtube.thumbnail = thumbnail
                                if let title = title {
                                    youtube.title = title
                                    if let videoId = videoId {
                                        youtube.videoId = videoId
                                        if let channelTitle = channelTitle {
                                            youtube.channelTitle = channelTitle
                                            self.youtubeList.append(youtube)
                                        }
                                    }
                                }
                            }
                        }

                        completionHandler(youtubeObjects: self.youtubeList)
                    }
                    
                } catch {
                    
                }
            } else {
                print("HTTPStatusCode = \(HTTPStatusCode)")
                print("Error while loading videos: \(error)")
                
            }
        }
        
        
    }
}