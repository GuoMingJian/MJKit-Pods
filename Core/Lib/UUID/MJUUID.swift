//
//  MJUUID.swift
//
//  Created by 郭明健 on 2025/6/7.
//

import UIKit
import KeychainAccess

public class MJUUID {
    static let KEYCHAIN_SERVICE: String = String.appBundleId()
    static let UUID_KEY: String = "UUID_KEY"
    
    static func getUUID() -> String {
        let keychain = Keychain(service: KEYCHAIN_SERVICE)
        var uuid: String = ""
        do {
            uuid = try keychain.get(UUID_KEY) ?? ""
        }
        catch let error {
#if DEBUG
            print("MJUUID error1 ====> \(error)")
#endif
        }
        if uuid.isEmpty {
            let newId = UUID().uuidString
            do {
                try keychain.set(newId, key: UUID_KEY)
                uuid = newId
#if DEBUG
                print("MJUUID new ====> \(newId)")
#endif
            }
            catch let error {
#if DEBUG
                print("MJUUID error2 ====> \(error)")
#endif
                uuid = newId
            }
        }
        return uuid
    }
}
