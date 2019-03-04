import XCTest

import PerfectServerTests

var tests = [XCTestCaseEntry]()
tests += PerfectServerTests.allTests()
XCTMain(tests)