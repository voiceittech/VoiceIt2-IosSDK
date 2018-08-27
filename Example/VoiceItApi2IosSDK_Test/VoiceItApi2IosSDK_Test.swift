//
//  VoiceItApi2IosSDK_Test.swift
//  VoiceItApi2IosSDK_Test
//
//  Created by Armaan Bindra on 8/26/18.
//  Copyright © 2018 armaanbindra. All rights reserved.s

import UIKit
import XCTest

class VoiceItApi2IosSDK_Test: VoiceItTest {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUsers() {
        print("TEST USER API CALLS")
        // Setup Expectations
        var expectations = [XCTestExpectation]()
        expectations.append(XCTestExpectation(description: "Test Get All Users"))
        expectations.append(XCTestExpectation(description: "Test Create User"))
        expectations.append(XCTestExpectation(description: "Test Check User Exists"))
        expectations.append(XCTestExpectation(description: "Test Get Groups For User"))
        expectations.append(XCTestExpectation(description: "Test Delete User"))
        
        print("\tTEST GET ALL USERS")
        self.myVoiceIt?.getAllUsers({
            jsonResponse in
            VoiceItTest.basicAssert(expectedRC: "SUCC", expectedSC: 200, jsonResponse: jsonResponse!)
            expectations[0].fulfill()
        })
        
        print("\tTEST CREATE USER")
        self.myVoiceIt?.createUser({
            createUserResponse in
            let userResponse = TestHelper.decodeUserJSON(jsonString: createUserResponse!)
            XCTAssertEqual(userResponse?.responseCode, "SUCC")
            XCTAssertEqual(userResponse?.status, 201)
            expectations[1].fulfill()
            print("\tTEST CHECK USER EXISTS")
            self.myVoiceIt?.checkUserExists(userResponse?.userId, callback: {
                checkUserExistsResponse in
                VoiceItTest.basicAssert(expectedRC: "SUCC", expectedSC: 200, jsonResponse: checkUserExistsResponse!)
                expectations[2].fulfill()
                print("\tTEST GET GROUPS FOR USER")
                self.myVoiceIt?.getGroupsForUser(userResponse?.userId, callback: {
                    getGroupsForUserResponse in
                    VoiceItTest.basicAssert(expectedRC: "SUCC", expectedSC: 200, jsonResponse: getGroupsForUserResponse!)
                    expectations[3].fulfill()
                    print("\tTEST DELETE USER")
                    self.myVoiceIt?.deleteUser(userResponse?.userId, callback: {
                        deleteUserResponse in
                        VoiceItTest.basicAssert(expectedRC: "SUCC", expectedSC: 200, jsonResponse: deleteUserResponse!)
                        expectations[4].fulfill()
                    })
                })
            })
      })
      wait(for: expectations, timeout: TIMEOUT)
    }
    
    func testGroups() {
        print("TEST GROUP API CALLS")
        // Setup Expectations
        var expectations = [XCTestExpectation]()
        expectations.append(XCTestExpectation(description: "Test Get All Groups"))
        expectations.append(XCTestExpectation(description: "Test Create Group"))
        expectations.append(XCTestExpectation(description: "Test Get Group"))
        expectations.append(XCTestExpectation(description: "Test Group Exists"))
        expectations.append(XCTestExpectation(description: "Test Add User To Group"))
        expectations.append(XCTestExpectation(description: "Test Remove User From Group"))
        expectations.append(XCTestExpectation(description: "Test Delete Group"))
        
        print("\tTEST GET ALL GROUPS")
        myVoiceIt?.getAllGroups({
            jsonResponse in
            VoiceItTest.basicAssert(expectedRC: "SUCC", expectedSC: 200, jsonResponse: jsonResponse!)
            expectations[0].fulfill()
        })
        
        print("\tTEST CREATE GROUP")
        myVoiceIt?.createGroup("Test Group", callback: {
            createGroupResponse in
            let groupResponse = TestHelper.decodeGroupJSON(jsonString: createGroupResponse!)
            XCTAssertEqual(groupResponse?.responseCode, "SUCC")
            XCTAssertEqual(groupResponse?.status, 201)
            expectations[1].fulfill()
            print("\tTEST GET GROUP")
            self.myVoiceIt?.getGroup(groupResponse?.groupId, callback: {
                getGroupResponse in
                VoiceItTest.basicAssert(expectedRC: "SUCC", expectedSC: 200, jsonResponse: getGroupResponse!)
                expectations[2].fulfill()
                print("\tTEST GROUP EXISTS")
                self.myVoiceIt?.groupExists(groupResponse?.groupId, callback: {
                    groupExistsResponse in
                    VoiceItTest.basicAssert(expectedRC: "SUCC", expectedSC: 200, jsonResponse: groupExistsResponse!)
                    expectations[3].fulfill()
                    self.myVoiceIt?.createUser({
                        createUserResponse in
                        let user = TestHelper.decodeUserJSON(jsonString: createUserResponse!)
                            print("\tTEST ADD USER TO GROUP")
                            self.myVoiceIt?.addUser(toGroup: groupResponse?.groupId, userId: user?.userId, callback: {
                                addUserResponse in
                                VoiceItTest.basicAssert(expectedRC: "SUCC", expectedSC: 200, jsonResponse: addUserResponse!)
                                expectations[4].fulfill()
                                print("\tTEST REMOVE USER FROM GROUP")
                                self.myVoiceIt?.removeUser(fromGroup: groupResponse?.groupId, userId: user?.userId, callback: {
                                    removeUserResponse in
                                    VoiceItTest.basicAssert(expectedRC: "SUCC", expectedSC: 200, jsonResponse: removeUserResponse!)
                                    expectations[5].fulfill()
                                    print("\tTEST DELETE GROUP")
                                    self.myVoiceIt?.deleteGroup(groupResponse?.groupId, callback: {
                                        deleteGroupResponse in
                                        VoiceItTest.basicAssert(expectedRC: "SUCC", expectedSC: 200, jsonResponse: deleteGroupResponse!)
                                        expectations[6].fulfill()
                                    })
                                })
                            })
                        })
                })
            })
        })
        
        wait(for: expectations, timeout: TIMEOUT)
    }
    
    func testPhrases() {
        print("TEST PHRASE API CALLS")
        // Setup Expectations
        var expectations = [XCTestExpectation]()
        expectations.append(XCTestExpectation(description: "Test Get Phrases"))
        
        print("\tTEST GET PHRASES")
        myVoiceIt?.getPhrases("en-US", callback : {
            jsonResponse in
            VoiceItTest.basicAssert(expectedRC: "SUCC", expectedSC: 200, jsonResponse: jsonResponse!)
            expectations[0].fulfill()
        })
        wait(for: expectations, timeout: TIMEOUT)
    }
    
    //    func testPerformanceExample() {
    //        // This is an example of a performance test case.
    //        self.measure {
    //            // Put the code you want to measure the time of here.
    //        }
    //    }
    
}
