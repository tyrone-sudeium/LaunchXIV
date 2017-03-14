# LaunchXIV - A Better Launcher for Final Fantasy XIV

This is a custom launcher for the the Mac version of Final Fantasy XIV. It is
currently incomplete and not working, but watch this space for updates.

Features:

- Zero-interaction logins: just open LaunchXIV and your game will launch!
  - Note: If you use one-time passwords, this must still be manually entered
- Secure storage of your credentials in the macOS keychain.
- Completely Mac native settings + login window.

**Security Warning**:
You shouldn't just randomly trust random applications from the internet with
your passwords! Even though I do provide codesigned binaries for download here,
that's only secure when there's an implied trust that I won't ever provide a
binary that does malicious things that aren't reflected in the source code! The
only truly safe way is to audit the code yourself and compile your own
binaries. This is a nuisance, but Apple provides Xcode and developer accounts
for free.

If you can't be bothered and feel like you can trust me, a complete stranger
on the internet implicitly, then go ahead and download the binary. The latest
stable version is available by clicking the Releases link above.

# FAQ

## How do I change the password?

If you run the launcher and the Square Enix servers reject your credentials,
the LaunchXIV will trash your saved password and show the settings page again.
Here you will be offered a chance to update your password.

## What does this do, exactly?

It generates a login session with the Square Enix servers the same way the
default launcher does, except LaunchXIV can save your username and password
securely in the macOS Keychain so you don't have to type it every time. It
then passes this session to the main Final Fantasy app, which makes it look
like the game just launches without needing a login.

## Why?

The Mac port of Final Fantasy XIV is lazy. People on the internet have built
"ports" using the same porting technology (Wine) in just a couple of hours
of configuring. *That* is how lazy this port is, it could literally be done
in the span of hours. This laziness means we get the very same nasty launcher
you get in Windows, and it's bad enough there, but on macOS it just stinks up
the whole place.

Despite this, I absolutely *adore* Final Fantasy XIV. If Square Enix don't want
to do their job properly, I guess it's up to us, the fans, to do it for them.
You're welcome.

## Can I use this to play on Mac with my PC license?

No. Square Enix in their divine wisdom decided to *require* a separate, 
full-price license for the Mac client, despite the fact that they put almost
literally *zero effort* into making it, since it's just a Transgaming Cider
wrapped app. The `ffxiv.exe`, `ffxivlauncher.exe` and friends included in the
Mac app are even *binary identical* to the Windows one, which makes it
particularly egregious that they charge you a separate license for it. However,
any circumvention of this mechanism is copyright "theft" at worst, and an EULA
violation at best, so I do not endorse it, nor provide any means with which to
do it.

## Does this completely replace the standard launcher?

No, it only works if your game client is completely up to date, with no patches
available for download. If you need to register your account, or patch the
game, or otherwise do anything other than just log in and launch, you will need
to use the default launcher.
