//
//  EventBusTests.swift
//  EventBusTests
//
//  Created by Benjamin Combes on 30/09/2015.
//  Copyright (c) 2015 BenjaminCombes. All rights reserved.
//

import XCTest
@testable import EventBus


struct UserDidLoginEvent {
    let userName: String
}

struct UserDidLogoutEvent { }

class TestReceiver: BusUser {
    var userName:String?
    var loggedIn = false
    
    init() {
        defaultBus.registerForEvent(UserDidLoginEvent.self) {
            (event: UserDidLoginEvent) in
            self.userName = event.userName
            self.loggedIn = true
        }
        
        defaultBus.registerForEvent(UserDidLogoutEvent.self) {
            (event: UserDidLogoutEvent) in
            self.loggedIn = false
        }

    }
}

class TestReceiver2: BusUser {
    var userName:String?
    var loggedIn = false

    init() {
        defaultBus.registerForEvent(UserDidLoginEvent.self) {
            (event: UserDidLoginEvent) in
            self.userName = event.userName
            self.loggedIn = true
        }

        defaultBus.registerForEvent(UserDidLogoutEvent.self) {
            (event: UserDidLogoutEvent) in
            self.loggedIn = false
        }

    }
}

class TestEmitter: BusUser {
    init() {

    }
}

class EventBusTests: XCTestCase {
    let userName = "test"
    let userName2 = "test2"
    
    var testReceiver: TestReceiver!
    var testEmitter: TestEmitter!

    override func setUp() {
        super.setUp()

        testReceiver = TestReceiver()
        testEmitter = TestEmitter()
    }
    
    override func tearDown() {
        super.tearDown()
        
        testEmitter.defaultBus.unregisterForAllEvents()
        testReceiver.defaultBus.unregisterForAllEvents()
    }
    
    func testTestClassesNotNil() {
        XCTAssertNotNil(testEmitter)
        XCTAssertNotNil(testReceiver)
    }
    
    func testBussesNotNil() {
        XCTAssertNotNil(testEmitter.defaultBus)
        XCTAssertNotNil(testReceiver.defaultBus)
    }
    
    func testBusesNotEquals() {
        XCTAssertNotEqual(unsafeAddressOf(testEmitter.defaultBus), unsafeAddressOf(testReceiver.defaultBus))
    }
    
    func testSimpleEvent() {
        XCTAssertFalse(testReceiver.loggedIn)
        testEmitter.defaultBus.postEvent(UserDidLoginEvent(userName: ""))
        XCTAssertTrue(testReceiver.loggedIn)
    }
    
    func testEventWithPayload() {
        XCTAssertNil(testReceiver.userName)
        testEmitter.defaultBus.postEvent(UserDidLoginEvent(userName: userName))
        XCTAssertEqual(userName, testReceiver.userName)
    }
    
    func testUnregister() {
        XCTAssertNil(testReceiver.userName)
        testEmitter.defaultBus.postEvent(UserDidLoginEvent(userName: userName))
        XCTAssertEqual(userName, testReceiver.userName)
        
        testEmitter.defaultBus.postEvent(UserDidLoginEvent(userName: userName2))
        XCTAssertEqual(userName2, testReceiver.userName)

        XCTAssertTrue(testReceiver.loggedIn)
        testReceiver.defaultBus.unregisterForEvent(UserDidLogoutEvent.self)
        testEmitter.defaultBus.postEvent(UserDidLogoutEvent())
        XCTAssertTrue(testReceiver.loggedIn)
        
        testReceiver.defaultBus.unregisterForAllEvents()
        testEmitter.defaultBus.postEvent(UserDidLoginEvent(userName: userName))
        XCTAssertEqual(userName2, testReceiver.userName)
        XCTAssertTrue(testReceiver.loggedIn)
    }
    
    func testUnregisterAll() {
        XCTAssertNil(testReceiver.userName)
        
        testEmitter.defaultBus.postEvent(UserDidLoginEvent(userName: userName))
        testReceiver.defaultBus.unregisterForAllEvents()
        
        XCTAssertTrue(testReceiver.loggedIn)
        XCTAssertEqual(userName, testReceiver.userName)
        
        testEmitter.defaultBus.postEvent(UserDidLogoutEvent())
        XCTAssertTrue(testReceiver.loggedIn)
        
        testEmitter.defaultBus.postEvent(UserDidLoginEvent(userName: userName2))
        XCTAssertEqual(userName, testReceiver.userName)
    }

    func testUnregisterSingleInstanceOfMultipleInstancesOfDifferentClasses() {
        let testReceiver2 = TestReceiver2()

        testEmitter.defaultBus.postEvent(UserDidLoginEvent(userName: userName))
        XCTAssertEqual(userName, testReceiver.userName)
        XCTAssertEqual(userName, testReceiver2.userName)

        testReceiver2.defaultBus.unregisterForEvent(UserDidLoginEvent.self)
        testEmitter.defaultBus.postEvent(UserDidLoginEvent(userName: userName2))
        XCTAssertNotNil(testReceiver.userName)
        XCTAssertNotNil(testReceiver2.userName)
        XCTAssertEqual(userName, testReceiver2.userName)
        XCTAssertEqual(userName2, testReceiver.userName)
    }

    func testUnregisterSingleInstanceOfMultipleInstancesOfTheSameClass() {
        let testReceiver2 = TestReceiver()

        testEmitter.defaultBus.postEvent(UserDidLoginEvent(userName: userName))
        XCTAssertEqual(userName, testReceiver.userName)
        XCTAssertEqual(userName, testReceiver2.userName)

        testReceiver2.defaultBus.unregisterForEvent(UserDidLoginEvent.self)
        testEmitter.defaultBus.postEvent(UserDidLoginEvent(userName: userName2))
        XCTAssertNotNil(testReceiver.userName)
        XCTAssertNotNil(testReceiver2.userName)
        XCTAssertEqual(userName, testReceiver2.userName)
        XCTAssertEqual(userName2, testReceiver.userName)
    }
}
