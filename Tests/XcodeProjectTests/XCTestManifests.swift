import XCTest

extension PBXGlobalIDTests {
    static let __allTests = [
        ("testIDGeneration", testIDGeneration),
    ]
}

extension XcodeProjectTests {
    static let __allTests = [
        ("testAggregateTarget", testAggregateTarget),
        ("testPrivateProjectFolder", testPrivateProjectFolder),
        ("testSelfArchive", testSelfArchive),
        ("testSelfSave", testSelfSave),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(PBXGlobalIDTests.__allTests),
        testCase(XcodeProjectTests.__allTests),
    ]
}
#endif
