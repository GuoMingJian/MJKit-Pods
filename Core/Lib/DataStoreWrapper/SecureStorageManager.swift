//
//  SecureStorageManager.swift
//  MJKit
//
//  Created by 郭明健 on 2025/10/15.
//

import Foundation
import Security

public final class SecureStorageManager {
    private init() {}
    
    public static let shared = SecureStorageManager()
    
    private static var keychainService: String {
        Bundle.main.bundleIdentifier ?? "MJKit.SecureStorage"
    }
    
    private func baseQuery(forKey key: String, returnData: Bool = false, useService: Bool = true) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        if useService {
            query[kSecAttrService as String] = Self.keychainService
        }
        if returnData {
            query[kSecReturnData as String] = kCFBooleanTrue
            query[kSecMatchLimit as String] = kSecMatchLimitOne
        }
        return query
    }
    
    private func copyMatchingData(_ query: [String: Any]) -> Data? {
        var queryResult: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &queryResult)
        guard status == errSecSuccess, let data = queryResult as? Data else { return nil }
        return data
    }
    
    public func storeString(_ value: String, forKey key: String) {
        guard let encodedData = value.data(using: .utf8) else { return }
        
        removeValue(key)
        var keychainQuery = baseQuery(forKey: key, useService: true)
        keychainQuery[kSecValueData as String] = encodedData
        
        SecItemAdd(keychainQuery as CFDictionary, nil)
    }
    
    public func retrieveString(_ key: String) -> String? {
        let queries = [baseQuery(forKey: key, returnData: true, useService: true),
                       baseQuery(forKey: key, returnData: true, useService: false)]
        for q in queries {
            if let data = copyMatchingData(q), let str = String(data: data, encoding: .utf8) {
                return str
            }
        }
        return nil
    }
    
    public func removeValue(_ key: String) {
        SecItemDelete(baseQuery(forKey: key, useService: true) as CFDictionary)
        SecItemDelete(baseQuery(forKey: key, useService: false) as CFDictionary)
    }
    
    public func storeObject<T: Codable>(_ value: T, forKey key: String) {
        let jsonEncoder = JSONEncoder()
        guard let encodedData = try? jsonEncoder.encode(value) else { return }
        
        removeValue(key)
        var keychainQuery = baseQuery(forKey: key, useService: true)
        keychainQuery[kSecValueData as String] = encodedData
        
        SecItemAdd(keychainQuery as CFDictionary, nil)
    }
    
    public func retrieveObject<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        let queries = [baseQuery(forKey: key, returnData: true, useService: true),
                       baseQuery(forKey: key, returnData: true, useService: false)]
        let decoder = JSONDecoder()
        for q in queries {
            if let data = copyMatchingData(q), let obj = try? decoder.decode(type, from: data) {
                return obj
            }
        }
        return nil
    }
}

@propertyWrapper
public struct SecureStorage<T: Codable> {
    private let storageKey: String
    
    public init(key: String) {
        self.storageKey = key
    }
    
    public var wrappedValue: T? {
        get {
            return SecureStorageManager.shared.retrieveObject(T.self, forKey: storageKey)
        }
        set {
            if let value = newValue {
                SecureStorageManager.shared.storeObject(value, forKey: storageKey)
            } else {
                SecureStorageManager.shared.removeValue(storageKey)
            }
        }
    }
}
