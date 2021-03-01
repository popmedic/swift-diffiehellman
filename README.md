![code coverage](https://gist.githubusercontent.com/popmedic/856e67e18cd23ea90772a825b159e00c/raw/swift-diffiehellman-total-coverage.svg)

---

# DiffieHellmanSecurity

A Swift structure for doing Diffie-Hellman encryption on data.

## Usage

```swift
do {
    // create keys for alice
    let alice = try DiffieHellman(label: "alice")
    // create keys for bob
    let bob = try DiffieHellman(label: "bob")
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
```
