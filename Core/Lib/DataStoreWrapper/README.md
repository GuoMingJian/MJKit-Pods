# DataStoreWrapper

MJKit 内的轻量存储抽象层，覆盖 **UserDefaults**、**应用沙盒 Documents 文件** 与 **Keychain**。所有结构化数据通过 `Codable` + `JSONEncoder` / `JSONDecoder` 序列化；敏感短字符串或令牌适合走 Keychain。

## 目录结构

| 文件 | 职责 |
|------|------|
| `DataStoreManager.swift` | 全局（非按用户隔离）的 UserDefaults 与 Documents 文件读写 |
| `UserDataStoreManager.swift` | 按 `userId` 隔离的 UserDefaults 键名与 `Documents/<userId>/` 子目录文件 |
| `SecureStorageManager.swift` | Keychain 存取字符串与 `Codable` 对象 |

## 设计要点

- **Codable**：`DataStoreManager` / `UserDataStoreManager` 的 UserDefaults 与文件 API 仅支持 `T: Codable`；写入为 JSON `Data`。
- **错误处理**：编码/解码/IO 失败时多为静默失败（返回 `nil` 或删除项），调用方若需强保证应自行校验或封装。
- **用户隔离**：使用 `UserDataStoreManager` 前必须先调用 `initializeUserId` 或 `configureUser`；若 `userId` 为空，内部键名会变为 `_<key>`，子目录名为空字符串，容易造成数据混淆，务必在登录成功后设置真实用户 ID。
- **Keychain**：`kSecClassGenericPassword`，`service` 为 `Bundle.main.bundleIdentifier`（缺省为 `MJKit.SecureStorage`）。读取时会依次尝试带 `service` 与不带 `service` 的查询，以兼容历史数据。

---

## 1. DataStoreManager

单例：`DataStoreManager.shared`。

### UserDefaults

| 方法 | 说明 |
|------|------|
| `storeUserDefault(_:forKey:)` | 存 `Codable`；`nil` 时删除该键 |
| `retrieveUserDefault(_:forKey:)` | 按类型读取，失败或不存在返回 `nil` |
| `removeUserDefault(forKey:)` | 删除键 |

### Documents 文件

文件路径：`Documents/<filename>`（`filename` 可含子路径片段，但需注意安全与规范）。

| 方法 | 说明 |
|------|------|
| `storeToFile(_:filename:)` | 写入 JSON；`nil` 时删除文件 |
| `retrieveFromFile(_:filename:)` | 读取并解码 |
| `removeFile(_:)` | 删除文件 |

### 属性包装器

- **`DefaultsStorage<T: Codable>`**：绑定 `UserDefaults`，可设 `defaultValue`；`wrappedValue` 置 `nil` 会删除键。
- **`FileStorage<T: Codable>`**：绑定 Documents 下单文件；`wrappedValue` 置 `nil` 会删除文件。

---

## 2. UserDataStoreManager

单例：`UserDataStoreManager.shared`。

### 初始化用户

```swift
UserDataStoreManager.shared.configureUser(userId: "user_123")
// 或与 initializeUserId 等价（项目内两处 API 行为一致，均为设置内部 userKey）
```

### UserDefaults（键名实际为 `"\(userId)_\(key)"`）

与 `DataStoreManager` 对称的 `storeUserDefault` / `retrieveUserDefault` / `removeUserDefault`。

- **`clearAllUserDefaults()`**：删除所有以 `"\(userId)_"` 为前缀的 UserDefaults 键。

### 文件（目录 `Documents/<userId>/`）

与全局文件 API 对称；首次写入前会创建用户子目录。

- **`clearAllUserFiles()`**：清空该用户目录下文件。
- **`clearAllUserData()`**：`clearAllUserDefaults()` + `clearAllUserFiles()`。

### 属性包装器

- **`UserDefaultsStorage<T: Codable>`**：逻辑同 `DefaultsStorage`，但走 `UserDataStoreManager`。
- **`UserFileStorage<T: Codable>`**：逻辑同 `FileStorage`，但走用户子目录。

注意：`UserDefaultsStorage` 在 `newValue == nil` 时仍会调用 `storeUserDefault(nil, ...)`，效果为删除键（与 `DataStoreManager` 的 `DefaultsStorage` 略有不同写法，行为一致）。

---

## 3. SecureStorageManager

单例：`SecureStorageManager.shared`。

| 方法 | 说明 |
|------|------|
| `storeString(_:forKey:)` | UTF-8 字符串写入 Keychain（会先 `removeValue` 再添加） |
| `retrieveString(_:)` | 读取字符串 |
| `removeValue(_:)` | 删除条目 |
| `storeObject(_:forKey:)` | `Codable` → JSON Data 写入 |
| `retrieveObject(_:forKey:)` | 解码读取 |

### 属性包装器

- **`SecureStorage<T: Codable>`**：仅适用于 `Codable`；`nil` 时删除。字符串请直接用 `storeString` / `retrieveString`。

---

## 使用示例

### 示例 A：全局 UserDefaults（与 Demo 一致）

```swift
private let key = "app.settings.greeting"

// 写入
DataStoreManager.shared.storeUserDefault("你好", forKey: key)

// 读取
let text: String? = DataStoreManager.shared.retrieveUserDefault(String.self, forKey: key)

// 删除
DataStoreManager.shared.removeUserDefault(forKey: key)
```

参考工程内演示页：`NeonMe/Classes/Modules/Test/TestDataStoreDemoVC.swift`。

### 示例 B：自定义 Codable 模型

```swift
struct UserPreference: Codable {
    var theme: String
    var fontScale: Double
}

let pref = UserPreference(theme: "dark", fontScale: 1.0)
DataStoreManager.shared.storeUserDefault(pref, forKey: "preference.main")

if let loaded = DataStoreManager.shared.retrieveUserDefault(UserPreference.self, forKey: "preference.main") {
    print(loaded.theme)
}
```

### 示例 C：`DefaultsStorage` / `FileStorage`

```swift
final class AppState {
    @DefaultsStorage(key: "app.lastOpenAt", defaultValue: nil)
    var lastOpenAt: Date?

    @FileStorage(filename: "cache/offline_payload.json", defaultValue: nil)
    var offlinePayload: [String: String]?
}
```

### 示例 D：多用户隔离

```swift
// 登录成功后
UserDataStoreManager.shared.configureUser(userId: currentUserId)

struct Draft: Codable { var body: String }

UserDataStoreManager.shared.storeUserDefault(Draft(body: "草稿"), forKey: "post.draft")
let draft = UserDataStoreManager.shared.retrieveUserDefault(Draft.self, forKey: "post.draft")

// 退出登录并清理该用户本地数据
UserDataStoreManager.shared.clearAllUserData()
```

### 示例 E：Keychain 令牌

```swift
SecureStorageManager.shared.storeString(accessToken, forKey: "auth.access_token")
let token = SecureStorageManager.shared.retrieveString("auth.access_token")
SecureStorageManager.shared.removeValue("auth.access_token")
```

### 示例 F：`SecureStorage` 包装器

```swift
struct OAuthPayload: Codable {
    var accessToken: String
    var refreshToken: String
}

final class AuthStore {
    @SecureStorage(key: "oauth.payload")
    var payload: OAuthPayload?
}
```

---

## 选型建议

| 场景 | 推荐 |
|------|------|
| 全局轻量配置、与用户无关 | `DataStoreManager` + `DefaultsStorage` / `FileStorage` |
| 按账号隔离的偏好与缓存 | `UserDataStoreManager` + 先 `configureUser` |
| 密码、Token、密钥材料 | `SecureStorageManager` / `SecureStorage` |
| 大文件 / 非 JSON 二进制 | 不宜直接用本模块文件 API（当前为 JSON 专用）；可扩展或改用专用存储 |

---

## 依赖

- `DataStoreManager.swift`：`UIKit`（模块级 import，实际逻辑仅 Foundation 即可满足）。
- `UserDataStoreManager.swift`、`SecureStorageManager.swift`：`Foundation`；Keychain 使用 `Security`。
