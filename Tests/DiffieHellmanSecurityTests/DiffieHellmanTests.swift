import XCTest
@testable import DiffieHellmanSecurity

final class DiffieHellmanTests: XCTestCase {
    override func setUp() {
        MockPersisting.reset()
    }

    override func tearDown() {
        MockPersisting.reset()
    }

    func testPrivateKeyGivenSetException() {
        MockPersisting.setHandler = { _, _ throws in
            throw MockError.test
        }
        XCTAssertThrowsError(
            try DiffieHellman(
                102175,
                Persisting: MockPersisting.self
            )
        ) { (error) in
            switch error {
            case MockError.test: break
            default: XCTFail("should throw MockError.test not \(error)")
            }
        }
    }

    func testPrivateKeyGivenSet() {
        let givenKey: UInt = 102175
        MockPersisting.setHandler = { key, value throws in
            XCTAssertEqual(key, .keychainKey)
            let valueKey: UInt = value.withUnsafeBytes { $0.load(as: UInt.self) }
            XCTAssertEqual(valueKey, givenKey)
        }
        do {
            let bob = try DiffieHellman(102175, Persisting: MockPersisting.self)
            XCTAssertEqual(bob.publicKey, 3472325210)
        } catch {
            XCTFail("should not throw error: \(error)")
        }
    }

    func testPrivateKeyFromKeyChain() {
        var givenKey: UInt = 102175
        MockPersisting.getHandler = { key throws -> Data? in
            XCTAssertEqual(key, .keychainKey)
            return Data(bytes: &givenKey, count: MemoryLayout<UInt>.size)
        }
        do {
            let bob = try DiffieHellman(Persisting: MockPersisting.self)
            XCTAssertEqual(bob.publicKey, 3472325210)
        } catch {
            XCTFail("should not throw error: \(error)")
        }
    }

    func testPrivateKeyGenerateNew() {
        let givenKey: UInt = 102175
        let expKey: UInt = 3472325210
        MockPersisting.getHandler = { _ throws -> Data? in
            throw MockError.test
        }

        do {
            let bob = try DiffieHellman(Persisting: MockPersisting.self,
                                        keygen: { () -> UInt in givenKey })
            XCTAssertEqual(expKey, bob.publicKey)
        } catch {
            XCTFail("should not throw error: \(error)")
        }
    }

    func test() {
        MockPersisting.setHandler = { key, value throws in }
        do {
            // create keys for alice
            let alicePrivate: UInt = 1234567890
            let alice = try DiffieHellman(alicePrivate, Persisting: MockPersisting.self)
            // create keys for bob
            let bobPrivate: UInt = 9876543210
            let bob = try DiffieHellman(bobPrivate, Persisting: MockPersisting.self)
            // message from bob to alice
            let bobsMsg = "Hello Alice, how are you? Bob.".data(using: .utf8)!
            // bob encrypts the message to alice
            let encMsg = bob.digest(bobsMsg, using: alice.publicKey)
            // make sure the message is now encrypted
            XCTAssertNotEqual(bobsMsg, encMsg)
            // alice decrypts the message from bob
            let decMsg = alice.digest(encMsg, using: bob.publicKey)
            // make sure they match
            XCTAssertEqual(bobsMsg, decMsg)
        } catch {
            XCTFail("should not throw error: \(error)")
        }
    }

    static var allTests = [
        ("testPrivateKeyGivenSetException", testPrivateKeyGivenSetException),
        ("testPrivateKeyGivenSet", testPrivateKeyGivenSet),
        ("testPrivateKeyFromKeyChain", testPrivateKeyFromKeyChain),
        ("testPrivateKeyGenerateNew", testPrivateKeyGenerateNew),
        ("test", test)
    ]
}
