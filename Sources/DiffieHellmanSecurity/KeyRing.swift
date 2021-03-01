import Foundation

public struct KeyRing {
    private let persist: Persisting
    private let persistKey: String
    private let privateKey: UInt
    private let base: UInt
    private let modulus: UInt
    /// public key computed from the private key
    public let publicKey: UInt

    // swiftlint:disable identifier_name
    /*
     creates a new DiffieHellman key ring.
     */
    public init(_ privateKey: UInt? = nil,
                label: String = "",
                base: UInt = 2147483647,     // defaults to a really big prime number
                modulus: UInt = 4294967291,  // defaults to a really big prime number
                Persisting: Persisting.Type? = nil,
                keygen: (() -> UInt)? = nil) throws {
        // use the persisting type they pass in
        let keygen = keygen ?? { UInt.random(in: UInt.min...UInt.max) }
        let Persisting = Persisting ?? KeyChainAccess.self
        persist = Persisting.init()
        persistKey = "\(persistKeyPrefix)\(label.isEmpty ? "" : ".\(label)")"

        // if given a private key, then set it in the key chain
        if var privateKey = privateKey {
            self.privateKey = privateKey
            let data = Data(bytes: &privateKey, count: MemoryLayout<UInt>.size)
            try persist.set(key: persistKey, to: data)
        } else if let privateKey = try? persist.get(key: persistKey) {
            // if not given a private key, check if there is on in the key chain,
            // if so use it
            self.privateKey = privateKey.withUnsafeBytes { $0.load(as: UInt.self) }
        } else {
            // if not given a private key, and none in the key chain, generate a
            // private key, then set it in the key chain
            var privateKey = keygen()
            self.privateKey = privateKey
            let data = Data(bytes: &privateKey, count: MemoryLayout<UInt>.size)
            try persist.set(key: persistKey, to: data)
        }

        // use the initialization vector passed in, or default to some really big
        // prime numbers
        self.base = base
        self.modulus = modulus

        // compute the public key from the private key and the base and modulus
        publicKey = Self.compute(self.privateKey, base: self.base, modulus: self.modulus)
    }
    // swiftlint:enable identifier_name

    public func digest(_ input: Data, using publicKey: UInt) -> Data {
        // compute the secret key by using this private key based with public key
        // passed in, assuming the modulus is the same used to produce both public
        // keys, this secret is the same when (x.pub, y.private) or (y.pub, x.priv)
        // are used.
        var key = Self.compute(privateKey, base: publicKey, modulus: modulus)
        let size = MemoryLayout<UInt>.size // should be 8 bytes (64 bits)
        // get the 64 bits from the UInt into 8, 8 bit (UInt8) octet array (Data)
        let data = Data(bytes: &key, count: size)
        var output = Data()
        var buffer = Data(repeating: 0, count: size)
        for (idx, byte) in input.enumerated() {
            // run through filling the buffer, so buffer index will be index mod size
            let bidx = idx % size
            // set the buffer at buffer index to the key byte at buffer index ORd
            // with the buffer index XORd with the current byte in the input.
            buffer[bidx] = byte ^ (data[bidx] | UInt8(bidx))
            // if it is time to roll around the buffer index, then append the full buffer
            if bidx == (size - 1) {
                output.append(buffer)
            } else if idx == (input.count - 1) {
                // if it is the end of the input, then append what is in the buffer
                output.append(buffer[0...bidx])
            }
        }
        // return the digested output
        return output
    }

    public func clearKeyChain() {
        persist.remove(key: persistKey)
    }
}

private extension KeyRing {
    static func compute(_ key: UInt, base: UInt, modulus: UInt) -> UInt {
        // swiftlint:disable identifier_name
        var k = key
        var b = base
        var r: UInt = 0
        var y: UInt = 1
        while k > 0 {
            r = k % 2
            // fast exponention
            if r == 1 { y = (y*b) % modulus }
            b = b*b % modulus
            k /= 2
        }
        return y
        // swiftlint:enable identifier_name
    }
}

let persistKeyPrefix: String = "com.kscardina.diffieHellman.privateKey"
