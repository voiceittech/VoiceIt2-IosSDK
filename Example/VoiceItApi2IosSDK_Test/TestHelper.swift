//
//  TestHelper.swift
//  VoiceItApi2IosSDK_Test
//
//  Created by Armaan Bindra on 8/26/18.
//  Copyright © 2018 armaanbindra. All rights reserved.
//

import Foundation

struct VoiceItResponse: Decodable {
    let responseCode: String
    let message: String
    let status: Int
}

struct UserResponse: Decodable {
    let userId: String
    let responseCode: String
    let message: String
    let status: Int
}

struct GroupResponse: Decodable {
    let groupId: String
    let responseCode: String
    let message: String
    let status: Int
}

class TestHelper {
    
    class func getEnvironmentVar(_ name: String) -> String? {
        guard let rawValue = getenv(name) else { return nil }
        return String(utf8String: rawValue)
    }
    
    class func decodeSimpleJSON(jsonString: String) -> VoiceItResponse?{
        let jsonData = jsonString.data(using: .utf8)
        guard let ret = try? JSONDecoder().decode(VoiceItResponse.self, from: jsonData!) else {
            return nil
        }
        return ret
    }
    
    class func decodeUserJSON(jsonString: String) -> UserResponse?{
        let jsonData = jsonString.data(using: .utf8)
        guard let ret = try? JSONDecoder().decode(UserResponse.self, from: jsonData!) else {
            return nil
        }
        return ret
    }
    
    class func decodeGroupJSON(jsonString: String) -> GroupResponse?{
        let jsonData = jsonString.data(using: .utf8)
        guard let ret = try? JSONDecoder().decode(GroupResponse.self, from: jsonData!) else {
            return nil
        }
        return ret
    }
}
