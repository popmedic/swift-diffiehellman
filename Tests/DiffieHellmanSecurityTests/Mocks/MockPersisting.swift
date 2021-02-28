import XCTest
@testable import DiffieHellmanSecurity

struct MockPersisting: Persisting {
    static var getHandler: ((String) throws -> Data?)?
    static var setHandler: ((String, Data) throws -> Void)?
    static var removeHandler: ((String) -> Void)?

    static func reset() {
        getHandler = nil
        setHandler = nil
        removeHandler = nil
    }

    func get(key: String) throws -> Data? { try MockPersisting.getHandler?(key) }
    func set(key: String, to data: Data) throws { try MockPersisting.setHandler?(key, data) }
    func remove(key: String) {MockPersisting.removeHandler?(key) }
}
