import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(KeyChainAccessTests.allTests),
        testCase(DiffieHellmanTests.allTests)
    ]
}
#endif
