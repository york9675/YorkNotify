![header](https://capsule-render.vercel.app/api?type=waving&height=300&color=gradient&text=YorkNotify&desc=一個可以排程通知的%20iOS%20應用程式。&descAlign=50&descAlignY=65&section=header&animation=fadeIn)

<p align="center">
  <a href="https://github.com/york9675/YorkNotify/releases" target="_blank">
    <img alt="Version" src="https://img.shields.io/github/release/york9675/YorkNotify?style=for-the-badge" />
  </a>
  <a href="https://developer.apple.com/swift/" target="_blank">
    <img alt="Swift" src="https://img.shields.io/badge/swift-F54A2A?style=for-the-badge&logo=swift&logoColor=white" />
  </a>
  <a href="https://www.apple.com/ios" target="_blank">
    <img alt="iOS" src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white" />
  </a>
  <a href="#License" target="_blank">
    <img alt="License" src="https://img.shields.io/github/license/york9675/YorkNotify?logo=github&style=for-the-badge" />
  </a>
</p>
<p align="center"> 
  <a href="README.md">English</a> 
  ·
  <a href="README_TW.md">繁體中文</a> 
</p>

<div align="center">
  <table>
    <tr>
      <td><img src="./Screenshots/Home_TW.png" alt="Home" width="250"/></td>
      <td><img src="./Screenshots/Settings_TW.png" alt="Settings" width="250"/></td>
    </tr>
  </table>
</div>

- 排程通知並在指定時間傳送
- 使用SwiftUI製成的精美介面
- 易使用
- 完全免費開源且超實用

> [!NOTE]  
> 此應用程式由於開發者無法負擔那個貴死人的蘋果開發者計劃會費，因此未上架App Store，需要自行使用Xcode安裝到您的裝置上。歡迎透過下方Buy Me a Coffee按鈕贊助開發者，感謝！

# 安裝

本指南將幫助您將此專案匯入 Xcode 並將此程式在 iPhone 或 iOS 模擬器上執行。

## 目錄

- [備料](#備料)
- [在 Xcode 中匯入並執行專案的步驟](#在-xcode-中匯入並執行專案的步驟)
  - [1. 複製儲存庫](#1-複製儲存庫)
  - [2. 在 Xcode 中開啟項目](#2-在-xcode-中開啟項目)
  - [3. 設定簽名和功能](#3-設定簽名和功能)
  - [4. 選擇您的目標設備](#4-選擇您的目標設備)
  - [5. 建置並運行應用程式](#5-建置並運行應用程式)
- [故障排除](#故障排除)
- [問題回報 / 意見回饋](#問題回報--意見回饋)
- [貢獻](#貢獻)
- [許可證](#許可證)
- [贊助](#贊助)

## 備料

在開始之前，請確保您具備以下條件：

- **一台裝有 macOS 的電腦**。
- **Xcode** (需要macOS 13 或更高版本以支援iOS 16以上的開發) 您可以從 [App Store](https://apps.apple.com/us/app/xcode/id497799835) 下載 Xcode。
- **iPhone/iPad** (實體機或模擬機) 需要 iOS 16 或更高版本。如是實體機，請先開啟「開發者模式」。
- **Apple 開發者帳戶** (免費或付費) 用於程式碼簽署和裝置測試。

## 在 Xcode 中匯入並執行專案的步驟

### 1.複製儲存庫

- 您可以從 GitHub 儲存庫下載 ZIP 檔案形式的項目，並將其解壓縮到您所需的位置。

- 或者，使用 Git 將專案儲存庫複製到本機：

````bash
git clone https://github.com/york9675/YorkNotify.git
````

### 2. 在 Xcode 中開啟項目

1. **打開 Xcode**。
2. **開啟專案**：導覽至複製/下載專案的目錄，然後開啟 `YorkNotify/YorkNotify.xcodeproj`。

### 3. 設定簽名和功能

1. **選擇您的Team**：
 - 在 Xcode 中，按一下專案導覽器中的項目。
 - 前往 **Signing & Capabilities**。
 - 在 **Team** 下拉清單中，選擇您的 Apple ID（如果不存在，請在 Xcode > Preferences > Accounts 新增您的Apple ID）。
 - 確保勾選 **Automatically manage signing**。

2. **設定檔**：
 Xcode 將自動為您產生設定文件，讓您在設備上執行該應用程式。

### 4. 選擇您的目標設備

1. 在頂部工具列中，從下拉式選單中選擇您的目標裝置。
2. 確保您的裝置已透過 USB 或 Wi-Fi 連接，或者如果您沒有可用的實體設備，請選擇模擬器。

### 5. 建置並運行應用程式

1. **建置專案**：
 點選 Xcode 左上角的 **Run** 按鈕（播放圖示）。 Xcode 將編譯程式碼並建立應用程式。

2. **執行應用程式**：
 建置成功後，Xcode會自動將應用程式安裝到所選裝置或模擬器上。

3. **信任 iPhone 上的開發者（如果需要）**：
 如果您使用免費的開發者帳戶並在實體 iPhone 上進行測試，則可能需要手動信任該應用程式。前往：
 - **設定** > **一般** > **VPN與裝置管理** > **您的 Apple ID** > **信任**。

> [!WARNING]\
> 如果您使用免費的 Apple 開發者帳戶，應用程式的簽名有效期僅為 7 天。在此期限之後，應用程式將不能再使用，您需要透過在 Xcode 中重新執行專案來重新安裝它。

## 故障排除

- **建置錯誤**：如果遇到建置錯誤，請檢查 Xcode 中的建置輸出，以取得有關遺失檔案、配置或相依性的線索。

## 問題回報 / 意見回饋

如在使用上遇到任何問題或是有意見回饋，請填寫 **[此表單](https://forms.gle/o1hFjy4q98Ua1H7L7)** 來回報。

或者，您也可以透過創建Issues來回報。

## 貢獻

請透過建立Issues、提交Pull Request或改進檔案來為該專案做出貢獻。

## 許可證

該項目已獲得 MIT 許可證的許可。有關更多詳細信息，請參閱許可證文件。

## 支持

當我開始開發應用程式時，我的目標很簡單：創造出真正有幫助的應用程式並免費提供給大家。在這個充滿付費功能和廣告的世界中，我希望能建立一些任何人都能免費使用的東西，單純只是為了讓生活更方便。我開發的應用程式一直都是無廣告的，而且像這個專案一樣，有些甚至是開源的。如果我的應用程式能夠幫助哪怕是一小部分人提高效率或解決問題，那就值得了。

然而，作為一名學生和獨立開發者，我面臨了一些財務上的挑戰。每年3000多台幣的 Apple 開發者計劃會費成為了一個不小的障礙。這個會員資格是解鎖一些 iOS 功能（如具時效性通知）並將應用程式發布到 App Store 所必需的。不幸的是，這是我目前無法負擔的成本。我甚至不得不使用 Hackintosh 進行開發，因為我沒有能力購買 Mac。

儘管面臨這些挑戰，我依然承諾讓這款應用程式保持**完全免費**——不會有廣告或應用內購買。但是，為了讓應用程式功能完善並對 iOS 用戶完全開放，我需要一些資助來支付 Apple 開發者帳戶的費用。

### 如何支持

如果你認同這個專案並希望幫助它成長，以下是幾種支持的方式：

- **捐款：** 無論金額大小，都將幫助我支付每年的 Apple 開發者費用。你可以透過下方的 [Buy Me a Coffee](https://buymeacoffee.com/york0524) 按鈕贊助這個專案！
- **分享：** 將這個專案分享給你的朋友、家人，或任何可能受益或支持的人！
- **合作：** 如果你是開發者、設計師，或者有改進建議，歡迎透過創建Issues、提交 Pull Requests或改善文件來為這個專案做出貢獻！

無論你選擇如何支持，這都將幫助我解鎖這款應用程式的全部潛力，並保持它對所有人免費。感謝你幫助我維持這個願景的實現！

<p><a href="https://www.buymeacoffee.com/york0524"> <img align="left" src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" height="50" width="210" alt="york0524" /></a></p><br>

或者，您也可以簡單的給顆 :star: ！

_感謝你抽出時間閱讀，並感謝你提供的任何支持。讓我們一起改善這款應用程式，幫助更多的人！_

## 星星歷史

[![Star History Chart](https://api.star-history.com/svg?repos=york9675/YorkNotify&type=Date)](https://star-history.com/#york9675/YorkNotify&Date)

***

© 2024 York Development

使用 :heart: 及 Swift 在台灣製作！
