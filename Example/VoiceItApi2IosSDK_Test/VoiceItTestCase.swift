//
//  VoiceItTestCase.swift
//  VoiceItApi2IosSDK_Test
//
//  Created by Armaan Bindra on 8/26/18.
//  Copyright © 2018 armaanbindra. All rights reserved.
//

import XCTest
@testable import VoiceItApi2IosSDK

class VoiceItTest : XCTestCase {
    var myVoiceIt:VoiceItAPITwo?
    var viewController: UIViewController!
    var VI_API_KEY: String?
    var VI_API_TOKEN: String?
    let TIMEOUT = 1000.0
    var started = false
    
    class func basicAssert(expectedRC: String, expectedSC: Int, jsonResponse : String){
//        print(jsonResponse)
        let ret = TestHelper.decodeSimpleJSON(jsonString: jsonResponse)!
        XCTAssertEqual(ret.responseCode, expectedRC)
        XCTAssertEqual(ret.status, expectedSC)
    }
    
    override func setUp() {
        if let viApiKey = TestHelper.getEnvironmentVar("VIAPIKEY") {
            VI_API_KEY = viApiKey
        }
        
        if let viApiTok = TestHelper.getEnvironmentVar("VIAPITOKEN") {
            VI_API_TOKEN = viApiTok
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController()
        self.myVoiceIt  = VoiceItAPITwo(viewController, apiKey: VI_API_KEY, apiToken: VI_API_TOKEN)
    }
}
