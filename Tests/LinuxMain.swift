import XCTest

import DiffieHellmanSecurityTests

var tests = [XCTestCaseEntry]()
tests += KeyChainAccessTests.allTests() + DiffieHellmanTests.allTests()
XCTMain(tests)
