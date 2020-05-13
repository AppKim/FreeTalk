//
//  ChatModel.swift
//  FreeTalk
//
//  Created by 김준석 on 2020/05/06.
//  Copyright © 2020 swift. All rights reserved.
//

import ObjectMapper

class ChatModel: Mappable {
    
    // Chat Members
    public var users :Dictionary<String,Bool> = [:]
    // Chat Content
    public var comments :Dictionary<String,Comment> = [:]
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map){
        users <- map["users"]
        comments <- map["comments"]
    }
    
    public class Comment :Mappable{
        
        public var uid :String?
        public var message :String?
        public var timestamp :Int?
        
        public required init?(map: Map){
            
        }
        public func mapping(map: Map) {
            uid <- map["uid"]
            message <- map["message"]
            timestamp <- map["timestamp"]
        }
        
        
    }

}
