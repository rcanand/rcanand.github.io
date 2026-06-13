---
title: How to transfer keyboard control back from screenshare window to host on Mac
date: 2026-06-13
tags: [howto, til, mac, keyboardonly]
excerpt: "Screenshare windows take over key control in mac. Transfer to host with Ctrl-F3"
---
I use Lume to set up Openclaw in a sandbox Mac VM on a host Mac (more on that later). It uses VNC/Screen sharing to open the VM. 

I am a big fan of keyboard only navigation, When I am inside the Screenshare window, it takes over the keyboard. 

Before, I had to  click outside the VM with mouse. Working with AI, I found a keyboard only solution to give keyboard control back to the host.

The solution is different depending on whether the VM window is in full screen mode or not.

When VM is a window, NOT in full screen mode:
- When inside the VM window, click Ctrl+F3 to launch Mission Control on the host desktop.
- Then click Tab or enter to get to a window other than the VM.
- Now you are in the host.

When VM window is in full screen mode:
- When inside the screenshare desktop, click Ctrl+1 to return to main (host) desktop. 
- Then click ctrl+down arrow to open the host desktop.

In both cases, to get back into the VM window, and give it control of keyboard again, simply Cmd+Tab to it.
