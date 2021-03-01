import XCTest
@testable import DiffieHellmanSecurity

final class KeyChainAccessTests: XCTestCase {
    func test() {
        let key = "key"
        guard let data = "some data".data(using: .utf8) else { XCTFail("bad data"); return }
        let access = KeyChainAccess()
        do {
            try access.set(key: key, to: data)
            let actData = try access.get(key: key)
            XCTAssertEqual(data, actData)
            access.remove(key: key)
            XCTAssertThrowsError(try access.get(key: key), "should throw an error") { error in
                switch error {
                case KeyChainAccess.Error.unableToGet(let status):
                    XCTAssertEqual(status, errSecItemNotFound)
                default:
                    XCTFail("should throw an unableToGet error")
                }
            }
        } catch {
            XCTFail("should not throw: \"\(error)\"")
        }
    }

    static var allTests = [
        ("test", test)
    ]
}
