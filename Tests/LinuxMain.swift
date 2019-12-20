import XCTest

import BSONTests

var tests = [XCTestCaseEntry]()
tests += BSONTests.__allTests()

XCTMain(tests)
