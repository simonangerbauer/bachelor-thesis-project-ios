import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Offline_CapabilityTests.allTests),
    ]
}
#endif