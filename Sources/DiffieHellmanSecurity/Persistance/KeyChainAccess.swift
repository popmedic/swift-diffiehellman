import Foundation

struct KeyChainAccess: Persisting {
    enum Error: Swift.Error {
        case unableToGet(OSStatus), unableToSet
    }
    func get(key: String) throws -> Data? {
        let query = [kSecClass as String: kSecClassGenericPassword,
                     kSecAttrAccount as String: key,
                     kSecReturnData as String: kCFBooleanTrue!,
                     kSecMatchLimit as String: kSecMatchLimitOne ] as [String: Any]

        var dataTypeRef: AnyObject?

        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        guard status == noErr else { throw Error.unableToGet(status) }
        // swiftlint:disable force_cast
        return dataTypeRef as! Data?
        // swiftlint:enable force_cast
    }

    func set(key: String, to data: Data) throws {
        let query = [kSecClass as String: kSecClassGenericPassword as String,
                        kSecAttrAccount as String: key,
                        kSecValueData as String: data] as [String: Any]

        SecItemDelete(query as CFDictionary)

        guard SecItemAdd(query as CFDictionary, nil) == noErr else { throw Error.unableToSet }
    }

    func remove(key: String) {
        let query = [kSecClass as String: kSecClassGenericPassword as String,
                     kSecAttrAccount as String: key] as [String: Any]

        SecItemDelete(query as CFDictionary)
    }
}
