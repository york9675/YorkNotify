![header](https://capsule-render.vercel.app/api?type=waving&height=300&color=gradient&text=YorkNotify&desc=An%20iOS%20app%20that%20can%20schedule%20notifications.&descAlign=50&descAlignY=65&section=header&animation=fadeIn)

<p align="center">
  <a href="https://github.com/york9675/YorkNotify/releases" target="_blank">
    <img alt="Version" src="https://img.shields.io/github/release/york9675/YorkNotify?style=for-the-badge" />
  </a>
  <a href="#License" target="_blank">
    <img alt="License" src="https://img.shields.io/github/license/york9675/YorkNotify?logo=github&style=for-the-badge" />
  </a>
    <a href="https://developer.apple.com/swift/" target="_blank">
    <img alt="Swift" src="https://img.shields.io/badge/swift-F54A2A?style=for-the-badge&logo=swift&logoColor=white" />
  </a>
  <a href="https://www.apple.com/ios" target="_blank">
    <img alt="iOS" src="https://img.shields.io/badge/iOS-16.0+-000000?style=for-the-badge&logo=ios&logoColor=white" />
  </a>
</p>

<p align="center"> 
  <b>English</b>
  ·
  <a href="README_TW.md">繁體中文</a> 
</p>

<img src="./Screenshots/iOS.png" alt="iOS" width="300" />

**YorkNotify** is a fully-featured, beautifully designed iOS app that makes scheduling notifications incredibly easy.

- 📅 **Schedule Notifications**: Plan and receive reminders exactly when you need them.
- 🎨 **Beautiful Interface**: Designed with SwiftUI, giving it a smooth, modern feel.
- ✨ **User-Friendly**: Clean and intuitive, so setting notifications is quick and easy.
- 💸 **Free & Open Source**: No ads, no cost, and fully transparent.

> [!NOTE]  
> This application is not on the App Store because the developer cannot afford the Apple Developer Program membership fee. You need to install it on your device using Xcode. You are also welcome to sponsor developers through the Buy Me a Coffee button below, thank you!

# Screenshots

<details>
  <summary>Click to expand screenshots</summary>

## iOS
<img src="./Screenshots/iOS.png" alt="iOS" width="300" />

## iPadOS
![iPadOS](./Screenshots/iPadOS.png)

## macOS
![macOS](./Screenshots/macOS.png)

## watchOS
<img src="./Screenshots/watchOS.png" alt="watchOS" width="300" />

</details>

---

# installation

This guide will help you import this project into Xcode and run it on your iPhone or iOS simulator.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Steps to Import and Run the Project in Xcode](#steps-to-import-and-run-the-project-in-xcode)
  - [1. Clone the Repository](#1-clone-the-repository)
  - [2. Open the Project in Xcode](#2-open-the-project-in-xcode)
  - [3. Set Up Signing & Capabilities](#3-set-up-signing--capabilities)
  - [4. Choose Your Target Device](#4-choose-your-target-device)
  - [5. Build and Run the App](#5-build-and-run-the-app)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before you begin, ensure that you have the following:

- **A Computer** with macOS.
- **Xcode** installed. You can download Xcode from the [App Store](https://apps.apple.com/us/app/xcode/id497799835/) or from the [Apple Developer website](https://developer.apple.com/download/all/?q=Xcode).
- **iPhone/iPad** (physical device or simulator) requires iOS 16 or higher. If it is a physical machine, please enable "Developer Mode" first.
- **Apple Developer Account** (free or paid) for code signing and device testing.

## Steps to Import and Run the Project in Xcode

### 1. Clone the Repository

- You can download the project as a ZIP file from the GitHub repository and extract it to your desired location.

- Alternatively, clone the project repository to your local machine using Git:

```bash
git clone https://github.com/york9675/YorkNotify.git
```

### 2. Open the Project in Xcode

1. **Open Xcode**.
2. **Open the Project**: Navigate to the directory where you cloned/downloaded the project, then open the `YorkNotify/src/YorkNotify.xcodeproj`.

### 3. Set Up Signing & Capabilities

1. **Select Your Team**:  
   - In Xcode, click on the project in the project navigator.
   - Go to the **Signing & Capabilities** tab.
   - Under the **Team** dropdown, select your Apple ID (if it’s not there, add your Apple ID under Xcode > Preferences > Accounts).
   - Ensure that **Automatically manage signing** is checked.

2. **Provisioning Profile**:  
   Xcode will automatically generate a provisioning profile for you, allowing you to run the app on your physical device.

### 4. Choose Your Target Device

1. In the top toolbar, select your target device (e.g., iPhone simulator or your connected iPhone) from the dropdown menu.
2. Ensure your device is connected via USB or select a simulator if you don’t have a physical device available.

### 5. Build and Run the App

1. **Build the Project**:  
   Click the **Run** button (the play icon) in the top-left corner of Xcode. Xcode will compile the code and build the app.
   
2. **Run the App**:  
   After the build is successful, Xcode will automatically install the app on the selected device or simulator.

3. **Trusting the Developer on iPhone (if required)**:  
   If you’re using a free developer account and testing on a physical iPhone, you may need to manually trust the app. Go to:
   - **Settings** > **General** > **VPN & Device Management** > **Your Apple ID** > **Trust**.

> [!WARNING]\
> If you're using a free Apple Developer account, the app's code signing is only valid for 7 days. After that period, the app will no longer launch, and you'll need to reinstall it by re-running the project in Xcode.

## Troubleshooting

- **Build Errors**: If you encounter build errors, check the build output in Xcode for clues on missing files, configurations, or dependencies.

---

# Bug report / Feedback

If you encounter any problems during use or have feedback, please open an issue to report it.

# Contribution

Feel free to contribute to this project by creating issues, submitting pull requests, or improving documentation.

# License

[MIT](LICENSE)

# Support

If you believe in this project and would like to support its growth, here are a few ways you can contribute:

- **Donate:** Any amount, large or small, will help me. You can sponsor the project via [Buy Me a Coffee](https://buymeacoffee.com/york0524) using the button below!
- **Spread the Word:** Share this project with your network—friends, family, or anyone who might benefit from or support it!
- **Collaborate:** If you’re a developer, designer, or have ideas for improvement, feel free to contribute to the project by creating issues, submitting pull requests, or improving documentation!

Your support, in any form, will help unlock the full potential of this app and keep it free for everyone. Thank you for helping keep this vision alive!

<p><a href="https://www.buymeacoffee.com/york0524"> <img align="left" src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" height="50" width="210" alt="york0524" /></a></p><br>

Or, you can simply give the project a :star:!

_Thank you for taking the time to read and for any support you can offer. Together, we can improve this app and help more people!_

# Star History

[![Star History Chart](https://api.star-history.com/svg?repos=york9675/YorkNotify&type=Date)](https://star-history.com/#york9675/YorkNotify&Date)

---

© 2026 York Development

Made with :heart: and Swift in Taiwan.
