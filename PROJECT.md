# MJKit 项目说明

面向 iOS 的基础组件库，通过 [CocoaPods](https://cocoapods.org/) 分发。代码以 Swift 为主，并包含少量 Objective-C（如 `NSDictionary+NSLog`）。

---

## 基本信息

| 项 | 说明 |
| --- | --- |
| Pod 名称 | `MJKit` |
| 当前版本 | `1.0.2`（以 `MJKit.podspec` 为准） |
| 最低系统 | iOS **14.0** |
| Swift | **5.0** |
| 许可证 | MIT（见仓库根目录 `LICENSE`） |
| 作者 | 郭明健 |
| 主页 / 源码 | [GitHub: GuoMingJian/MJKit-Pods](https://github.com/GuoMingJian/MJKit-Pods) |

---

## 功能概览

MJKit 将常用能力归纳为以下几类：

1. **布局与设备常量**：状态栏、导航栏、TabBar、安全区、屏幕尺寸、按设计稿比例缩放等（`MJ` 结构体）。
2. **类型与工具扩展**：`String`、`Date`、`UIColor`、`UIView`、`UITableView`、数值与 `Encodable` 等扩展；自定义调试打印 `MJ.printInfo`；通知名 `Notification.Name.MJ`。
3. **通用 UI**：表格/集合/滚动容器基类、Web、弹窗、对话框、加载、跑马灯文本、签名、邮箱输入、字数限制文本视图、日期选择等。
4. **业务能力封装**：网络状态、HUD、相册/相机选择（HXPhotoPicker / ZL）、轮播、文件与下载、音频播放、定位与地图视图、权限与 Keychain 存储、UUID 等。
5. **资源**：`MJKit.bundle`（多语言 `Localizable.strings`）、`MJKit.xcassets`（通用图标、文件类型图、地图相关图等）。

---

## 安装

在 `Podfile` 中：

```ruby
pod 'MJKit'
```

本地开发（与 `Podfile` 同级目录放置本仓库时）：

```ruby
pod 'MJKit', :path => './MJKit'
```

---

## CocoaPods 依赖

`MJKit.podspec` 中声明的第三方库：

| 依赖 | 版本约束（约） |
| --- | --- |
| MJRefresh | ~> 3.7.9 |
| EmptyDataSet-Swift | ~> 5.0.0 |
| SnapKit | ~> 5.7.1 |
| Then | ~> 3.0.0 |
| HXPhotoPicker | ~> 5.0.5 |
| ZLPhotoBrowser | ~> 4.5.8 |
| SDWebImage | ~> 5.21.1 |
| NVActivityIndicatorView | ~> 5.2.0 |
| KeychainAccess | ~> 4.2.2 |

**已注释、未默认启用**：`AliyunOSSiOS`、`MobileVLCKit`（仓库内仍有阿里云 OSS 相关 Swift 封装，需自行在 podspec 中解除注释并处理集成）。

---

## 目录结构（`Core/`）

```
Core/
├── Base/                 # MJConstant（MJ 常量与通用扩展）、MJCommon（Bundle/语言/图片加载）
├── CommonUI/             # 可复用视图与控制器基类
├── Extensions/           # UIKit/Foundation 扩展；MJRuntime；Lib 下 ObjC 分类
├── Lib/                  # 子功能模块
│   ├── ActiveLabel/      # 可点击链接/提及等富文本标签
│   ├── AliyunOSS/        # OSS 管理与服务封装（依赖需单独接入）
│   ├── DataStoreWrapper/ # UserDefaults / 文件 / Keychain 等存储抽象
│   ├── HUDManager/       # 加载与提示 HUD
│   ├── HXPicker/         # 媒体选择与浏览器封装
│   ├── Location/         # 定位管理器、地图视图
│   ├── MJAuthorization/  # 权限类型与工具（含独立 bundle 文案）
│   ├── MJBannerView/     # 轮播与布局、页码控件
│   ├── MJFiles/          # 文件工具、下载、音频播放
│   ├── NetworkMonitor/   # 网络连通性状态
│   └── UUID/             # UUID 相关工具
├── MJKit.bundle/         # 主模块本地化（en / zh-Hans / zh-Hant）
└── MJKit.xcassets/       # 内置图片资源
```

---

## 主要公开类型（按模块）

### Base

- **`MJ`**（`MJConstant.swift`）：屏幕与安全区尺寸、导航高度、日期格式常量、数值转换、`UserDefaults` 便捷方法、`Encodable` 转字典/JSON、`MJ.printInfo` 等。
- **`MJLanguage`**、`String.mj_Localized` / `mj_localizedAuth`：基于 `MJKit.bundle` 与 `MJAuthorization.bundle` 的本地化。
- **`UIImage.mj_Image`** / **`String.mj_Image()`**：从 MJKit 资源包加载图片。

### CommonUI（节选）

- `BaseTableView`、`BaseCollectionView`、`BaseScrollView`
- `BaseWebViewController`、`BasePopController`
- `BaseDialogView`、`MJLoadingView`、`MJScrollTextView`
- `MJSignatureView`、`MJEmailTextField`、`LimitTextView`
- `DatePickViewController`、`MJPanView`、`MJPaddingLabel`

### Extensions（节选）

- 设备：`IPhoneDevice`
- 视图：`UIView+Ext`、红点、`PopView`、`Toast(MJTipView)`
- 控件：`UIButton`、`UILabel`、`UITextField`、`UITextView`、`UISwitch`、`UITableView`
- 其他：`String+Ext`、`String+MD5`、`Date+Ext`、`UIColor+Ext`、`UIFont+Ext`、`UIImage+Ext`、`ViewController+`
- **`MJRuntime`**：运行时相关封装

### Lib（节选）

- **`HUDManager`**：全局 HUD
- **`NetworkMonitor`** / **`ConnectivityStatus`**：网络状态
- **`DataStoreManager`**、`DefaultsStorage`、`FileStorage`；**`UserDataStoreManager`**；**`SecureStorage`**（Keychain）
- **`MJAuthorization`**、**`MJAuthorizationTool`**：权限枚举与检测
- **`HXPicker`**、**`ZLPicker`**、**`HXBrowser`**：相册/拍摄/浏览
- **`MJBannerView`** 及 `MJBannerViewLayout`、`MJBannerViewPageControl`
- **`MJFiles`**、**`MJFileDownloadManager`**、**`MJAudioPlayerManager`**
- **`MJLocationManager`**、**`MJMapView`**
- **`AliyunOssManager`**、**`AliyunOssService`**（需 OSS SDK）
- **`MJUUID`**
- **`ActiveLabel`** 及代理协议

---

## 资源与本地化

- 主文案：`Core/MJKit.bundle` 下 `en.lproj`、`zh-Hans.lproj`、`zh-Hant.lproj` 的 `Localizable.strings`。
- 权限相关文案：`Core/Lib/MJAuthorization/MJAuthorization.bundle` 内对应语言的 `Localizable.strings`。
- 图片：`Core/MJKit.xcassets`（含 `FilesType`、`Location` 等子目录）。

---

## 维护与发布（摘自 README）

发布新版本时通常需要：修改代码 → 更新 `MJKit.podspec` 中的 `s.version` → 打 tag 并推送 → 执行 `pod trunk push`（具体参数见仓库根目录 `README.md` 中的注释说明）。

---

## 许可证

MIT，Copyright (c) 2026 郭明健。完整条款见 `LICENSE`。
