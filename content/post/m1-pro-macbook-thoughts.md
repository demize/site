+++
title="M1 Pro Macbook Thoughts"
date="2022-01-04T02:30:00-05:00"
description="Initial thoughts on my 14\" M1 Pro Macbook"
+++

I bought in to the hype. I bought one of the 2021 Macbook Pros with an M1 Pro in it. I probably didn't *need* this much power, but hearing about these machines made me feel like I could effectively replace my desktop with one, and I liked that idea, so I picked one up.

<!--more-->

{{< toc >}}

## The Why

I guess you might want to know more about *why* I bought a Macbook. To start, it might help if you knew why I've historically not bought macbooks:

I've been fairly anti-laptop for a while, mostly because of my experiences with laptops in the late 2000s and most of the 2010s. They were more expensive than I felt they were worth, they had all sorts of weird issues, they never performed as well as I would have liked, et cetera. After I graduated college in 2017, I had little reason to use a laptop anymore, and I was mostly happy with what I had (a relatively old Thinkpad that I ran Linux on, later a Surface Go, and as of late 2019 a Surface Laptop 3) for what I needed to do when I wasn't at home (basically nothing). My issues with Macs specifically were mostly the same (they *are* pretty expensive machines; the Macbook I'm typing this on cost about as much as my gaming PC) but, on top of that, I never liked OSX when I tried to use it circa 2010 (on a late 2007 MBP with the trackpad/keyboard disconnect issues). So before this year, I would have told you I was pretty unlikely to buy a Macbook at all; the initial M1 launch didn't persuade me, and I wasn't thinking I'd really *want* a laptop anyway.

So why, then, did I decide to buy a laptop that's as expensive as my gaming PC? Well, partially because the Surface Laptop 3 proved to me that you can have a really nice laptop now that *doesn't* suffer from weird issues, but also because something about the M1 Pro/Max announcement got me thinking about the benefits of daily-driving a laptop rather than a desktop. And I realized that if I've got a laptop I'm using for everything, then it saves me from having to set stuff up on my laptop when I'm not at home (working on [my bot](https://github.com/demize/ghirahim_rs) recently I had to, at one point, set up my Rust development environment from scratch on my laptop to make a change), which alone I think is pretty good; on top of that, it's more flexible *at* home, even in this small one-bedroom apartment. I really like the idea that I can just pick up my computer and do whatever I was doing somewhere else, without being limited to my desk. Not possible with a desktop, but certainly possible with a laptop.

Of course, that alone wasn't enough to convince me. This model of Macbook pushed me to switch for a few reasons on top of that: excellent performance with the M1 Pro CPU, without compromising on battery life or power consumption as much as other laptops; the re-introduction of an array of ports and IO (and magsafe!); the fantastic screen, keyboard, speakers; it's an entire package that sold me, and nothing on the market really compared for a Windows laptop (or I probably would have bought one of them instead, and stuck Linux on it). Plus, the [Asahi Linux](https://asahilinux.org/) project seems to be progressing excellently, so I figured I'd be able to eventually replace the OS I hated.

## First Impressions

To summarize: I am very impressed, and haven't run into any issues after a day of using it.

### Hardware

The hardware is excellent. Just from a build quality perspective, it's built like a brick, which is a good quality in a laptop (if you ask me). It's about as thick as the thickest point on my SL3:

{{<figure src=/images/mbp-sl3-comparison.jpg alt="Comparison between the MBP and SL3, MBP on the left">}}

This makes it feel less like an ultrabook and more like a laptop, which is a good sign, because ultrabooks tend to trade performance for thinness. The Macbook is just a constant thickness throughout, but not too thick. Its design can be sort of hit or miss for people, but I'm a big fan of it.

Being built the way it is also let them put a lot of ports on. I'm a little disappointed there's no full-size USB-A on it, but I've already got a decent dock I can use if I need to, so I'm not too concerned there; it would be great for 2FA tokens, mainly, and it would be more convenient for flash storage (all the flash storage I own is USB-A).

The keyboard made some weird sounds when I touched the top-right corner of it at first, but that went away pretty quickly, and the keyboard is now just about my favorite keyboard I've ever used. I've got a Ducky One with Cherry MX Brown switches that I always liked, but I like the Macbook's so much more. The tactile feedback is so much better, and the lower travel distance (but slightly higher actuation force, it feels like) makes it easier to hit keys deliberately but harder to hit them accidentally. It's just such a good keyboard, and I didn't even think keyboards mattered that much to me! I probably wouldn't like it much for *gaming* but I don't plan on doing much of that on this machine anyway...

The screen is one of the things that really sold me on getting a Macbook, and I am not disappointed. It doesn't stand out too much for typical usage for me; I've never seen much difference from higher refresh rates, and color reproduction has never been one of my strongest concerns. I do feel like some websites with white backgrounds look more muted than I'd expect, but I can't say that's a problem (and it may just be me thinking too much about it). But HDR... oh boy, HDR. My TV and my desktop monitor know how to process an HDR signal, so they can say they support it, but this screen knows how to make it look good. I did not know the actual impact that HDR can make on video until I watched How to Train Your Dragon on this screen. I didn't even need to compare—I had never seen anything on a monitor or TV that had the dynamic range that this one was showing me. I did attempt some unscientific comparisons anyway (against a different color profile on the Macbook, and against my TV) and they hammered the point in. This is hands-down the best display I own now.[^1]

The speakers are pretty solid too; they're not as good as my Presonus powered monitors in terms of frequency reproduction and sound quality (especially because I have some second-hand JBL subwoofer hooked up along with them) but they actually beat them in soundstage: stereo separation is surprisingly good with the Macbook speakers, and to get it that good with my powered monitors I would need to mess with positioning and angling (and I do not have the space for that). If I'm listening to music I'm probably gonna prefer headphones or speakers because of the better frequency reproduction, but I have no qualms about using these speakers for everything else.

My biggest complaint about the hardware is that the Fn key is on the left and the Control key is on the right. I'm too used to other keyboards, where the Control key is on the left and Fn to the right of it.

### Software
#### The OS
And that's a perfect segue into this section: my biggest issues are things I'm used to that don't work how I expect. I'm very used to Windows (and Linux, given Linux has adopted a lot of the same things I use habitually as well) and I'm finding a lot of little things that don't work the way I expect them to.

One thing I try to do *all the time* on anything with a trackpad is double tap and drag. Selecting text, moving a window, dragging a file from one folder to another, I always try to double tap and drag. While that *is* an option in MacOS, it's implemented specifically as an accessibility feature, and it comes with a major caveat because of that approach: there is, at minimum, a half-second period where you can lift your finger and then resume dragging from elsewhere on the trackpad. I think that's a great option, but unfortunately it's not an *option*, since there's no way to remove that delay. I had to switch to three-finger dragging, which works, but still trips me up (I can't consistently remember to use three fingers, I just keep trying to double tap and drag and then getting reminded it won't work). If I'm, say, moving a window I want to be able to move it and then move the cursor again (perhaps to click into the window I just moved, or to click on another window) and that delay means I keep moving the window again when I try to just move the cursor.

Most of my other issues are things I'm finding easier to get used to; different keyboard shortcuts (because Macs have Fn, Control, Option, Command, and they don't work like Ctrl, Alt, Windows Key), inconsistent behavior of the "close" button on windows, the organization of the dock, things like that. A lot of it, like the whole existence of the system-wide menu bar, is just an issue of knowing where to look for things.

But overall, I'm finding I don't hate MacOS the way I used to. I'm not sure *why*—my concerns before were always about the things like the menu bar and the dock—but I'm not minding it. I'm honestly likely to just stick with MacOS going forward, because I'll definitely get used to it, and then these complaints will be about Windows instead! For the most part, MacOS works like I expect any OS to, and my gripes are all pretty minor (though I do wish they'd have an option to have *no* grab lock on tap-and-drag).

#### Third-party Applications

Third-party applications mostly work as expected. Even x86_64 applications!

For some reason, Firefox seems to have an issue playing audio from Twitch (occasional crackling/popping), but I can just watch Twitch in Safari (though I did have to buy Tampermonkey so I could use FFZ). I don't know what the root cause of this issue is, but Twitch audio seems fine in Safari, and that's an acceptable enough workaround for me to not worry about it.[^2]

Being able to run iPhone and iPad apps is pretty nice, though it also feels like a bit of a crappy workaround to companies not providing native versions of their applications. I don't mind it for apps like Plexamp, which are 100% mobile-first in design, but the actual Plex Media Player would sure be nice to have native.

Rosetta exists, and it works, and it's fine; things running under Rosetta are noticeably less responsive than things running natively, but to use Plex as an example again, it makes for a decent workaround. Rather than installing the mobile version of Plex I'm running the x86_64 version under Rosetta (and while navigating my media library is a crappy experience, it can play 4K remuxes perfectly fine). I'm not a huge fan of how Plex has basically said "M1 support will come when it comes" and left it at that, but as long as something works, I won't be too mad at them.

The other standout application experience so far has been... Discord. They recently started publishing Canary builds as Apple Silicon compatible universal binaries, and let me tell you, it is the most responsive Discord has ever felt (even with a bunch of BetterDiscord plugins). It's *way* snappier than Discord on my Windows desktop.

I'm just generally surprised so far how well this tiny laptop compares to my massive gaming PC. I haven't tried any games on it yet (and I don't plan on; if I want a mobile gaming experience I've got a Steam Deck reserved) but in general usage it meets (or excels, in the case of Discord) the standards set by my desktop. As a concrete example, `cargo build`ing my bot after a clean takes about a minute and a half on this Macbook and about a minute and fifteen seconds on my desktop.[^3] That's a practically negligible difference, and while my Ryzen 5 5600X isn't the highest-end CPU, I'm very happy that the M1 Pro can keep up with it so well.

## Later Thoughts

A few scattered thoughts, after having used this laptop for nearly a month:

1. They really should have included a grounded power adapter with it. The included power adapter is (at least in North America) ungrounded, and if you've ever used a metal-bodied laptop connected to wall power with an ungrounded adapter, you probably know why this is an issue. When you touch the metal body, it creates a capacitative effect that is best described as feeling tingly, weird, and really uncomfortable. It's not harmful (to you or the laptop) but it's generally regarded as Not Nice, and it can be addressed by providing a path to ground through the adapter.
This is a really common issue on high-end laptops, for some reason. My SL3 had the same issue, but it had fabric on the wristrest, so it was fairly well mitigated. I mitigated it myself on the Macbook through the use of a [dbrand skin](https://twitter.com/demize95/status/1474410863318740997).
2. The integration between the Macbook and my other Apple devices is really nice. Unlock with Apple Watch just works, and it's usually faster than I'd be able to unlock with Touch ID. Airpods integration is pretty nice too; I got a pair of Airpods Pros for this integration and I am not disappointed, they switch between devices about as seamlessly as they could.  Handoff is... not as useful as perhaps I'd like, but that's mostly because not every app supports it and I don't have everything configured the same on both devices (thankfully they don't sync over things like email account credentials).
This also means I've fallen into Apple's trap, and I'm now pretty integrated into their ecosystem. I didn't feel very integrated when I just had an iPhone, but now...
3. Its power management is *incredibly* aggressive. Plugged in to the wall, full battery, walk away for a few minutes, and it's asleep. It wakes from sleep instantly, so it can be hard to tell it was ever asleep, so this usually isn't much of a problem... but Firefox seemed to lose its place on some sites, like gmail and tweetdeck, while it was asleep at my father's house (with his less than stellar internet).
This is a pretty minor issue, since it can be solved just by refreshing pages that aren't loading properly, and it only really seemed to trip up Firefox. I wouldn't even really say this is a complaint, mostly just something I noticed, and aggressive power management definitely has its benefits.
4. Scrolling with a mouse is... weird. I had to buy a third-party application (SmoothScroll) to make scrolling with a mouse behave more reasonably. It has to be disabled for some applications since they don't handle its scrolling modifications well (it has this built-in, thankfully), and it has to hook in as an accessibility application (which is always sort of uncomfortable to do) but it makes scrolling much smoother and much more usable.
5. The notch is usually fine. Usually.
But when it's not fine, it's really annoying. I've only run into it being an issue in Stellaris, where the game runs at half-resolution (for some reason) in borderless windowed, but doesn't use the space where the notch is, and native resolution in fullscreen, including the notched area. This isn't really a complaint either; the OS usually does a pretty good job of keeping things out of the notch, and I don't really expect Stellaris to be notch-aware.
6. Typing accented letters is really easy. My habit of holding down the "a" key and letting an input fill up with lowercase 'a's while I think of what I want to write is no longer viable. I don't type accented letters very often, but given how often I do that other thing, I  would unironically prefer the objectively less useful repetition I get on Windows.
7. I don't know if this really fits as a thought about the laptop, but I was impressed with the location tracking, to the extent I encountered it: my phone telling me that I forgot the laptop when I had deliberately left it behind, either in the car or at my father's house. It did not notify me when I left it behind at home, and it was easy to add my father's house as a saved location so it would stop notifying me about it there. That's a pretty neat feature, truthfully.
8. Three-finger-drag was easier to get used to than I expected, but it makes the OS feel a lot less responsive... because it *also* has that half-second delay. I don't get why Apple went out of their way to make the OS feel *worse* here. They could have implemented an option to have no delay, but no, they'd rather take things that should be instant (say, dragging a browser tab out to form its own window) and make them take half a second longer than they ought to. It just baffles me! They've put so much work into making a powerful laptop and an OS and software suite that takes advantage of it, and then they made this basic feature make it feel like a laggy mess.

## Conclusions

Overall, the 2021 Macbook Pros are very nice machines. Their build quality, keyboard, screen, speakers all make for what is probably the nicest laptop I've ever used. The M1 Pro ensures that it actually pulls double duty: it works as a decent workstation for the sorts of work I typically do on my own machines, but it's efficient and light enough to lug around with me wherever.[^4] MacOS is, despite my prior thoughts about it, perfectly usable and useful as an OS, and the integration between all the devices in the ecosystem is actually pretty nice (even if I don't get much use out of some of it). The OS does exhibit some of the rigidity that Apple is \[in]famous for, but they're (mostly) addressable through various methods. I still wish I had better double-tap-and-drag support, I find it *much* more usable than click-and-drag or three-finger-drag on a trackpad, but alas. Despite my issues with the OS, I still feel like this laptop was worth every penny.

[^1]: This laptop convinced me to buy a better TV since the initial draft of this post. I'm not sure which display is better, between my LG C1 and this laptop. They're both pretty nice, though.

[^2]: This is turning out to be a pretty inconsistent issue, but at this point Twitch mostly seems fine. I'm not sure what changed.

[^3]: Since my initial draft, I've upgraded my desktop to a Ryzen 7 5800X, and that shaved about 30 seconds off the compile time, down to 41 seconds. I'm putting this in as a footnote mainly because it's not terribly relevant—my desktop may have gotten faster, but the Macbook is still pretty respectable.

[^4]: While I was at my father's house over the past couple weeks, he dug up this tiny laptop sleeve. Neither of us actually thought this Macbook would fit in it, but I tried it, and it's a perfect fit. This laptop is smaller than it feels like, and that's a really good thing. That laptop sleeve is mine now.
