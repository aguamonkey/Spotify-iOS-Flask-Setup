//
//  KeychainManager.swift
//  UnheardSpotifySearch
//
//  Created by Joshua Browne on 04/02/2024.
//

import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()

    func save(service: String, account: String, data: String) -> Bool {
        guard let data = data.data(using: .utf8) else {
            print("Error converting string to data")
            return false
        }

        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ] as [String: Any]

        SecItemDelete(query as CFDictionary) // Always try to delete any existing item first.

        let status = SecItemAdd(query as CFDictionary, nil)
        let success = status == errSecSuccess
        print("Keychain save status: \(success), for service: \(service), account: \(account). Status code: \(status)")
        return success
    }

    func load(service: String, account: String) -> String? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String : Any]

        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess, let data = item as? Data, let result = String(data: data, encoding: .utf8) else {
            print("Failed to load item for service: \(service), account: \(account). Status: \(status)")
            return nil
        }

        print("Successfully retrieved item for service: \(service), account: \(account). Data: \(result)")
        return result
    }
}
