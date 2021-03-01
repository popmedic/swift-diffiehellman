//
//  File.swift
//  
//
//  Created by Kevin Scardina on 2/28/21.
//

import Foundation
import ArgumentParser
import DiffieHellmanSecurity

struct dhdigest: ParsableCommand {
    enum Error: Swift.Error {
        case inputFileDoesNotExist(String), outputFileAlreadyExists
    }
    enum Mode: String, ExpressibleByArgument {
        case enc, dec, show, clear
    }
    @Option(
        name: [.long, .short],
        help: "file to read for input"
    ) var label: String = ""
    @Option(
        name: [.long, .short],
        help: "file to read for input"
    ) var inputPath: String = ""
    @Option(
        name: [.long, .short],
        help: "file to write for output"
    ) var outputPath: String = ""
    @Option(
        name: [.long, .short],
        help: """
              modes:
                 show: show public key
                clear: removes private key from chain
                  dec: dec(decrypt) file
                  enc: enc(encrypt) file
                ** defaults to show **
              """
    ) var mode: Mode = .show
    @Option(
        name: [.long, .short],
        help: "file to write for output"
    ) var friendKey: UInt = 0
    @Flag(
        name: [.long, .short],
        help: "minimize output"
    ) var brevity: Bool = false

    mutating func run() throws {
        let persistKey = label.isEmpty ? "SYSTEM" : label
        switch mode {
        case .clear:
            let ring = try KeyRing(label: label)
            print(
                "removing private key for:",
                ring.publicKey,
                "persist key:",
                persistKey,
                "..."
            )
            ring.clearKeyChain()
            print(
                "removed private key for:",
                ring.publicKey,
                "persist key:",
                persistKey
            )
        case .show:
            let ring = try KeyRing(label: label)
            if !brevity { print("Public Key for \(persistKey):") }
            print(ring.publicKey)
        case .dec, .enc:
            // validate input file
            guard FileManager.default.fileExists(atPath: inputPath) else {
                throw Error.inputFileDoesNotExist(inputPath)
            }
            // validate output file
            guard !outputPath.isEmpty,
                  !FileManager.default.fileExists(atPath: outputPath) else {
                throw Error.outputFileAlreadyExists
            }

            let ring = try KeyRing(label: label)
            print(
                """
                Using:
                   🏷        label: \(label)
                   ⏩  input-path: \(inputPath)
                   ⏪ output-path: \(outputPath)
                   🔑  public-key: \(ring.publicKey)
                   🔑  friend-key: \(friendKey)
                   ⚙️         mode: \(mode)
                """)
            let inputURL = URL(fileURLWithPath: inputPath)
            print("🤓 reading from \(inputURL)")
            let data = try Data(contentsOf: inputURL)
            print("🏭 digesting...")
            let enc = ring.digest(data, using: friendKey)
            let outputURL = URL(fileURLWithPath: outputPath)
            print("✍️ writing to \(outputURL)")
            try enc.write(to: outputURL)
            print("🚪 complete.")
        }
    }
}

dhdigest.main()
