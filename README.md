# SwiftEaglePly

This Swift package provides a way to load the polygon mesh of the Eagle as an array of points conforming to the `EaglePoint` protocol. The `EaglePoint` protocol defines the following properties:

- `pos`: Position information of type `SIMD3<Float>`
- `normal`: Normal vector of type `SIMD3<Float>`
- `color`: Color information of type `SIMD4<UInt8>`
- `init(pos:normal:color:)`: Initializer to create a `EaglePoint` with the specified `pos`, `normal`, and `color` values.

## Usage

You can use the `SwiftEaglePly` class to load the polygon mesh of the Eagle as an array of points.

```swift
import SwiftEaglePly
// struct of your own code
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
let eagle = SwiftEaglePly<EaglePoint>.instance()
let points = try! eagle.load()
```

The load function returns an array of points that conform to the EaglePoint protocol.

Here is an example that iterates through each element of the array and prints out the point information:

```swift
for point in points {
    print("pos: \(point.pos), normal: \(point.normal), color: \(point.color)")
}
```
