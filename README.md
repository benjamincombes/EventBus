# EventBus
A simple and type-safe facade for ```NSNotification``` with custom payload.

## Usage

### Simple example

To use EventBus on any class, just import ```EventBus``` and adopt ```BusUser```protocol.

Here is a simple (useless) example that registers to an event and post it:
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

Here is how to post an event to inform that user did login:

```swift

// Events are simple structures or classes created to pass data
struct UserDidLoginEvent {
    let userName: String
}

defaultBus.postEvent(UserDidLoginEvent(userName: "User1"))
```

If you do not have any payload, your event class can be a simple empty structure :
```swift
import EventBus

// Events are simple structures or classes created to pass data
struct UserDidLogoutEvent {}

defaultBus.postEvent(UserDidLogoutEvent())
```

### Registering to events

Here is how to register for the an event:

```swift
defaultBus.registerForEvent(UserDidLoginEvent.self) {
    (event: UserDidLoginEvent) in
    print("User name is \(event.userName)")
}
```

If the event does not have any payload, or you don't need to access the event, you can use the short version:
```swift
defaultBus.registerForEvent(UserDidLoginEvent.self) {
    print("User name is \(event.userName)")
}
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
