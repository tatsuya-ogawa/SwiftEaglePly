import Foundation
import simd
import Foundation
import simd
public protocol EaglePointProtocol{
    var pos:SIMD3<Float> { get set }
    var normal:SIMD3<Float>{ get set }
    var color: SIMD4<UInt8>{ get set }
    init(pos: SIMD3<Float>, normal: SIMD3<Float>, color: SIMD4<UInt8>)
}
public struct SwiftEaglePly<T:EaglePointProtocol>{
    public static func instance() -> SwiftEaglePly<T> {
        return SwiftEaglePly<T>()
    }
    private init(){
        
    }
    public func load() throws->[T] {
        guard let fileURL = Bundle.module.url(forResource: "EaglePointCloud", withExtension: "ply") else {
            throw NSError(domain: "resource not found", code: 0)
        }
        let fileData = try! Data(contentsOf: fileURL)
        let ply = Ply()
        let points = try! ply.parse(data: fileData)
        return points
    }
    class Ply{
        struct PlyHeader {
            var vertexCount: Int
        }
        func readPlyHeader(_ data: Data) -> PlyHeader? {
            guard let string = String(data: data, encoding: .ascii) else {
                return nil
            }
            
            var vertexCount: Int? = nil
            
            string.enumerateLines { line, stop in
                if line == "end_header"{
                    stop = true
                    return
                }
                let components = line.components(separatedBy: " ")
                
                if components.count >= 3 && components[0] == "element" && components[1] == "vertex" {
                    vertexCount = Int(components[2])
                }
                
                if let count = vertexCount, count > 0 {
                    stop = true
                }
            }
            
            guard let count = vertexCount else {
                return nil
            }
            
            return PlyHeader(vertexCount: count)
        }
        func loadFloat(ptr:UnsafeRawBufferPointer,offset:Int,count:Int) -> [Float]{
            return (0..<count).map{i in
                return ptr.load(fromByteOffset:  offset + Int(i)*MemoryLayout<Float>.size, as: Float.self)
            }
        }
        func loadByte(ptr:UnsafeRawBufferPointer,offset:Int,count:Int) -> [UInt8]{
            return (0..<count).map{i in
                return ptr.load(fromByteOffset:  offset + Int(i)*MemoryLayout<UInt8>.size, as: UInt8.self)
            }
        }
        
        func scan(data:Data,vertexCount:Int)->[T]{
            return data.withUnsafeBytes{ptr in
                return (0..<vertexCount).map{index in
                    var byteOffset = index * (6 * MemoryLayout<Float>.size+4 * MemoryLayout<UInt8>.size)
                    let pn =  self.loadFloat(ptr: ptr,offset: byteOffset, count: 6)
                    byteOffset += 6 * MemoryLayout<Float>.size
                    let c =  self.loadByte(ptr: ptr,offset: byteOffset, count: 4)
                    byteOffset += 4 * MemoryLayout<UInt8>.size
                    return T(pos: SIMD3<Float>(pn[0..<3]), normal: SIMD3<Float>(pn[3..<6]), color: simd_uchar4(c))
                }
            }
        }
        
        func parse(data:Data)throws->[T]{
            guard let endHeaderRange = data.range(of: "end_header\n".data(using: .utf8)!) else {
                throw NSError(domain: "", code: 0)
            }
            let headerSize = endHeaderRange.upperBound
            let dataSize = data.count - headerSize
            let headerSlice = data[0..<headerSize]
            let header = readPlyHeader(headerSlice)
            let dataCopy = data.advanced(by:headerSize).withUnsafeBytes{ptr in
                return Data(bytes: ptr.baseAddress!, count: dataSize)
            }
            return scan(data: dataCopy, vertexCount: header!.vertexCount)
        }
    }
}

