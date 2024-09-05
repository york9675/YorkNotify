# YorkNotify

[繁體中文](readme_TW.md)

An iOS app that can schedule notifications.

# installation

This guide will help you import this project into Xcode and run it on your iPhone or iOS simulator.

## Prerequisites

Before you begin, ensure that you have the following:

- **A Computer** with macOS.
- **Xcode** installed (requires macOS 13 or higher to support development for iOS 15 and above). You can download Xcode from the [Mac App Store](https://apps.apple.com/us/app/xcode/id497799835).
- **iPhone/iPad** (physical device or simulator) requires iOS 15 or higher.
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
2. **Open the Project**: Navigate to the directory where you cloned/downloaded the project, then open the `YorkNotify/YorkNotify.xcodeproj`.

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

## Troubleshooting

- **Build Errors**: If you encounter build errors, check the build output in Xcode for clues on missing files, configurations, or dependencies.

## Contribution

Feel free to contribute to this project by creating issues, submitting pull requests, or improving documentation.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.

## Support

<p><a href="https://www.buymeacoffee.com/york0524"> <img align="left" src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" height="50" width="210" alt="york0524" /></a></p><br><br>