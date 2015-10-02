//
// Created by Benjamin Combes on 30/09/2015.
// Copyright (c) 2015 Pretty Fun Therapy. All rights reserved.
//

import Foundation

public class Bus {

    private static var busObservers = [String: Any]()

    weak var target: BusUser?

    init(target: BusUser) {
        self.target = target
    }

    /**
    Registers for a specific event: when an event of the provided type is posted, callback will be performed
    - parameter eventType:  The type of the event to register for. For example, CustomEvent.self
    - parameter onPosted:   The callback to be performed when event is received

    You can use the short form :
    bus.registerForEvent(CustomEvent.self) { (event: CustomEvent) in print("Received") }
    */
    public func registerForEvent<Event:Any>(eventType: Event.Type, onPosted onPostedCallback: (Event) -> Void) {
        if let target = self.target {
            let busObserver = busObserverForType(eventType)
            busObserver.register(eventType, forTarget: target, onPosted: onPostedCallback)
        }
    }

    public func registerForEvent<Event:Any>(eventType: Event.Type, onPostedEmpty onPostedEmptyCallback: (Void) -> Void) {
        if let target = self.target {
            let busObserver = busObserverForType(eventType)
            busObserver.register(eventType, forTarget: target, onPosted: onPostedEmptyCallback)
        }
    }

    /**
    Posts an event, that will be delivered to all recipients that registered for it
    - parameter event:      Anything containing custom data, for example a struc or class instance
    */
    public func postEvent<Event:Any>(event: Event) {
        let busObserver = busObserverForType(event.dynamicType)
        busObserver.post(event)
    }

    /**
    Unregisters from an event ; callback won't be performed anymore
    */
    public func unregisterForEvent<Event:Any>(eventType: Event.Type) {
        if let target = self.target {
            let busObserver = busObserverForType(eventType)
            busObserver.unregister(target)
        }
    }

    /**
    Unregisters from all registered events ;  callback won't be performed anymore
    */
    public func unregisterForAllEvents() {
        if let target = self.target {
            for busObserver in Bus.busObservers.values {
                if let objectObserver = busObserver as? BusObserverProtocol {
                    objectObserver.unregister(target)
                }
            }
        }
    }

    // MARK: private

    private func busObserverForType<Event:Any>(eventType: Event.Type) -> BusObserver<Event> {
        var busObserver = Bus.busObservers["\(eventType)"] as! BusObserver<Event>?
        if busObserver == nil {
            busObserver = BusObserver<Event>()
            Bus.busObservers["\(eventType)"] = busObserver
        }
        return busObserver!
    }
}

public protocol BusUser: AnyObject {
    var defaultBus: Bus { get }

    var hashValue: Int { get }
}

public extension BusUser {

    private var _defaultBus: Bus! {
        get {
            return objc_getAssociatedObject(self, &_defaultBusDictionaryAssociationKey) as? Bus
        }
        set(newValue) {
            objc_setAssociatedObject(self, &_defaultBusDictionaryAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    public var defaultBus: Bus {
        get {
            if _defaultBus == nil {
                _defaultBus = Bus(target: self)
            }
            return _defaultBus
        }
    }

    var hashValue: Int {
        get {
            if (objc_getAssociatedObject(self, &_defaultHashDictionaryAssociationKey) as? Int) == nil {
                objc_setAssociatedObject(self, &_defaultHashDictionaryAssociationKey, Int(arc4random_uniform(1000000000)), .OBJC_ASSOCIATION_RETAIN)
            }

            return objc_getAssociatedObject(self, &_defaultHashDictionaryAssociationKey) as! Int
        }
    }
}

// MARK: private

private enum Keys: String {
    case Event = "fr.benjamincombes.eventbus.EventKey"
}

private class Wrapper<T> {
    var wrappedValue: T
    init(value: T) {
        wrappedValue = value
    }
}

protocol BusObserverProtocol {
    func unregister(target: BusUser)
}

class BusObserver<Event:Any>: NSObject, BusObserverProtocol {
    typealias CallbackWithEvent = ((Event) -> Void)
    typealias CallbackWithoutEvent = ((Void) -> Void)

    var callbacks = [String: CallbackWithEvent]()
    var emptyCallbacks = [String: CallbackWithoutEvent]()

    var isRegisteredForNotification = false
    var isRegisteredForEmptyNotification = false

    override required init() {
        super.init()
    }

    func register(eventType: Event.Type, forTarget target: BusUser, onPosted onPostedCallback: (Event) -> Void) {
        if !isRegisteredForNotification {
            isRegisteredForNotification = true
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "onNotification:", name: "\(eventType)", object: nil)
        }
        callbacks["\(target.hashValue)"] = onPostedCallback
    }

    func register(eventType: Event.Type, forTarget target: BusUser, onPosted onPostedEmptyCallback: (Void) -> Void) {
        if !isRegisteredForEmptyNotification {
            isRegisteredForEmptyNotification = true
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "onNotificationEmpty:", name: "\(eventType)", object: nil)
        }
        emptyCallbacks["\(target.hashValue)"] = onPostedEmptyCallback
    }

    func onNotification(notification: NSNotification) {
        if let aUserInfo = notification.userInfo,
        let wrappedEvent = aUserInfo[Keys.Event.rawValue] as? Wrapper<Event> {
            for callback in callbacks.values {
                callback(wrappedEvent.wrappedValue)
            }
        }
    }

    func onNotificationEmpty(notification: NSNotification) {
        for emptyCallback in emptyCallbacks.values {
            emptyCallback()
        }
    }

    func post(event: Event) {
        var userInfo = [String: AnyObject]()
        userInfo[Keys.Event.rawValue] = Wrapper(value: event)

        let notification = NSNotification(name: "\(event.dynamicType)", object: nil, userInfo: userInfo)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }

    func unregister(target: BusUser) {
        if callbacks["\(target.hashValue)"] != nil {
            callbacks["\(target.hashValue)"] = nil
        }
        if emptyCallbacks["\(target.hashValue)"] != nil {
            emptyCallbacks["\(target.hashValue)"] = nil
        }

        if callbacks.count <= 0 && emptyCallbacks.count <= 0 {
            NSNotificationCenter.defaultCenter().removeObserver(self)
            isRegisteredForNotification = false
            isRegisteredForEmptyNotification = false
        }
    }

    func notificationName() {

    }
}

private var _defaultBusDictionaryAssociationKey: UInt8 = 0
private var _defaultHashDictionaryAssociationKey: UInt8 = 2
