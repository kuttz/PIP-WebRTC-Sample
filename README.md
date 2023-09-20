
# PIP-WebRTC-Sample

Sample code for how to use Picture-in-Picture create in a WebRTC based video conferencing interface. This is not a production ready code!.

Note:- Somehow accessing the camera while the app is in the background is not working. If you're looking for that this is not for you. If I found any solution for that I will defenitly update this repo.




![App Screenshot 1](https://github.com/kuttz/DemosAndScreenShots/blob/2be20f0f9eb1d107b25ae57fc32117b734138f8c/PIP-WebRTC-Sample/ScreenShot1.PNG?raw=true)

![App Screenshot 2](https://github.com/kuttz/DemosAndScreenShots/blob/2be20f0f9eb1d107b25ae57fc32117b734138f8c/PIP-WebRTC-Sample/ScreenShot2.PNG?raw=true)

## Requirements


1. Xcode 12.1 or later
2. iOS 15 or later



## Setup Project

1. Setup a signaling server.

You can use the [SignalingServer](https://github.com/kuttz/signaling_server) to create a local server.

2. Open the `Config.swift` and set the `defaultSignalingServerUrl` variable to your signaling server ip/host. Don't use `localhost` or `127.0.0.1`.

3. Build and run on device or on a simulator (simulator does not support video capture)

## Demo video



https://github.com/kuttz/PIP-WebRTC-Sample/assets/25796581/f8860e4c-1309-4671-bf35-3b7725770ab0



## Related

Here is are some related projects

[SignalingServer](https://github.com/kuttz/signaling_server)

[WebRTC-Demo-SwiftUI](https://github.com/kuttz/webrtc_demo_swiftui)



