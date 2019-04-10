import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    fatalError("This test suite should not be run on linux!")
}
#endif
