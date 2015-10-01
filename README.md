[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# EventBus
A simple and type-safe facade for ```NSNotification``` with custom payload.

## Usage

### Simple example

To use EventBus on any class, just import ```EventBus``` and adopt ```BusUser```protocol.

Here is a simple (useless) example that registers to an event and posts it:
```swift
import EventBus

struct UserDidLoginEvent {
    let userName: String
}

class TestNotification: BusUser {
    init() {
        defaultBus.registerForEvent(UserDidLoginEvent.self) {
            (event: UserDidLoginEvent) in
            print("User name is \(event.userName)")
        }

        // Prints "User name is User1"
        defaultBus.postEvent(UserDidLoginEvent(userName: "User1"))
    }
}
```

### Posting event

An event is a simple class or structure, which name describes what it is (UserDidLogin or UserDidRegisterToNewsletter for example). Events can have members (to allow sending data along with it) or not.
Here is how to declare an event:

```swift
// An event with payload, to allow passing user name when user has logged in
struct UserDidLoginEvent {
    let userName: String
}
```

If you do not have any payload, your event class can be a simple empty structure:

```swift
// A simple event with no payload
struct UserDidLogoutEvent {}
```

Here is how to post instances of former events:

```swift
defaultBus.postEvent(UserDidLoginEvent(userName: "User1"))

defaultBus.postEvent(UserDidLogoutEvent())
```

### Registering to events

Here is how to register to an event:

```swift
defaultBus.registerForEvent(UserDidLoginEvent.self) {
    (event: UserDidLoginEvent) in
    print("User name is \(event.userName)")
}
```

If the event does not have any payload, or you don't need to access it, you can use the short version:

```swift
defaultBus.registerForEvent(UserDidLogoutEvent.self) {
    print("User did logout)")
}
```

### Unregistering

To avoid memory leaks, you must unregister from registered events:

```swift
defaultBus.unregisterForEvent(UserDidLoginEvent.self)
```

You can also unregister from all registered events:
```swift
defaultBus.unregisterForAllEvents()
```

## Requirements

- iOS 8.0+ / Mac OS X 10.9+ / watchOS 2
- Xcode 7.0+

## Installation

### Carthage

To integrate EventBus into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "benjamincombes/EventBus"
```
r
