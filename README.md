# LaunchXIV - A Little Launcher for Final Fantasy XIV

This is a custom launcher for the the Mac version of Final Fantasy XIV. It's
barebones and probably full of a lot of bugs but it should more or less do
what it says on the tin.

Features:

- Zero-interaction logins: just open LaunchXIV and your game will launch!
  - Note: If you use one-time passwords, this must still be manually entered
- Secure storage of your credentials in the macOS keychain.
- Completely Mac native settings + login window.

**Security Warning**:
You shouldn't just randomly trust random applications from the internet with
your passwords! The only truly safe way to use software involving your passwords
like this is to audit the code yourself and compile your own binaries. This is
a nuisance, but Apple provides Xcode and developer accounts
for free.

If you can't be bothered and feel like you can trust me, a complete stranger
on the internet implicitly, then go ahead and download the binary. The latest
stable version is available by clicking the Releases link above.

# Building / Compiling

> NOTE: You will probably need to change the app's bundle ID and sign in with
> your own Apple Developer account if you want the keychain stuff to work
> properly.

* Clone this repo (obviously).
* Install Xcode 12.4+.
* Open `LaunchXIV.xcodeproj` in Xcode.
* Build & Run.

# FAQ

## What does it look like?

Something like this:

![Path Select Window](/Assets/SS1-Path.png)

![Login Window](/Assets/SS2-Login.png)

## When will this be working?

Should work right now.

## How do I change the password?

If you run the launcher and the Square Enix servers reject your credentials,
the LaunchXIV will trash your saved password and show the settings page again.
Here you will be offered a chance to update your password.

You can also hold down your ⌥ key (option / alt) while the app starts up and
it will reset all settings.

## What does this do, exactly?

It generates a login session with the Square Enix servers the same way the
default launcher does, except LaunchXIV can save your username and password
securely in the macOS Keychain so you don't have to type it every time. It
then passes this session to the main Final Fantasy app, which makes it look
like the game just launches without needing a login.

## Why?

No offense to the wonderful people at Codeweavers, but the Mac port of Final 
Fantasy XIV is lazy. Since it's using a compatibility layer (CrossOver, the
paid, commercial fork of the open source Wine project), it literally just runs
the exact same code as the Windows version, with a significant performance and
integration penalty. There's no reason for a Mac app to repeatedly ask for your
login credentials when macOS provides a standard, secure, widely utilised
mechanism for storing them: the keychain, but because it runs the same code as
Windows, it can't.

If Square Enix don't want to do their job properly, I guess it's up to us, the 
fans, to do it for them. You're welcome.

## Can I use this to play on Mac with my PC license?

No. I'm pretty sure such a thing is _technically possible_ since CrossOver/wine 
is open source, though.

## Does this completely replace the standard launcher?

No, it only works if your game client is completely up to date, with no patches
available for download. If you need to register your account, or patch the
game, or otherwise do anything other than just log in and launch, you will need
to use the default launcher.

## I'm a developer. What cool shit is there to see?

Glad you asked!

### General Anatomy of a macOS App

If you've mostly only done iOS development or server-side Swift, and you're
curious what Mac apps are like, the codebase is a fairly simple, general
example of what to expect.

### macOS Drag and Drop

The drag and drop mechanism in macOS is old, arcane, poorly documented and
unintuitive. If you're curious about how it works, and want a simple, working
example, check out
[`PathSettingViewController.swift`](LaunchXIV/PathSettingViewController.swift)
for an `NSView` subclass that provides the drag and drop support.

### JavaScript-to-Swift bridging

The response from the login web view is a JavaScript script which executes
`window.external.user(str)` where `str` is the login response data. This could
probably be parsed out manually by hand, or with a regular expression, but
macOS has a perfectly good JavaScript interpreter built in, so why not just
execute it?

In order to get the data out, we need to define `window.external` on the global
JS object, and because we need the string back in Swift, the `external` object
and the `user` function should really be a Swift object and Swift method
respectively.

The [`SidParseOperation.swift`](LaunchXIV/SidParseOperation.swift)
contains an example of this bridging.

### `NSOperation` usage

If you've ever been curious about `NSOperation` but were too shy to ask, check
out [`AsyncOperation.swift`](LaunchXIV/AsyncOperation.swift) for
a really lightweight, useful `NSOperation` base subclass, which makes a state
machine that automatically integrates with the `isFinished` and `isExecuting`
infrastructure that `NSOperation`s need.

