import XCTest
@testable import SwiftEaglePly
struct EaglePoint:EaglePointProtocol{
    var pos: SIMD3<Float>
    var normal: SIMD3<Float>
    var color: SIMD4<UInt8>
    init(pos: SIMD3<Float>, normal: SIMD3<Float>, color: SIMD4<UInt8>) {
        self.pos = pos
        self.normal = normal
        self.color = color
    }
}
final class SwiftEaglePlyTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let eagle = SwiftEaglePly<EaglePoint>.instance()
        let points = try! eagle.load()
        XCTAssertEqual(points.count, 796825)
    }
}
