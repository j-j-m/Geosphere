//
//  PrimitiveBlueprint.swift
//  Geosphere
//
//  Created by Jacob Martin on 4/17/17.
//  Copyright © 2017 Jacob Martin. All rights reserved.
//

import Foundation
import Metal
import SceneKit




protocol PrimitiveBlueprint {
    var vertices:[vector_float3] { get }
    var faces:[[Int]] { get }
    mutating func generator()
    mutating func generateVertices()
    func build() -> ([vector_float3],[vector_float3],[CInt])
    mutating func generateFaces()
    
    func meshdata(_ device: MTLDevice) -> MeshData
}

extension PrimitiveBlueprint {
    func meshdata(_ device: MTLDevice) -> MeshData{
        
        
        let buildData = build()
        
        let pointsList: [vector_float3] = buildData.0
        let normalsList: [vector_float3] = buildData.1
        let indexList: [CInt] = buildData.2
        
        
        let vertexFormat = MTLVertexFormat.float3
       
        let vertexBuffer1 = device.makeBuffer(
            bytes: pointsList,
            length: pointsList.count * MemoryLayout<vector_float3>.size,
            options: [.cpuCacheModeWriteCombined]
        )
        let vertexBuffer2 = device.makeBuffer(
            bytes: pointsList,
            length: pointsList.count * MemoryLayout<vector_float3>.size,
            options: [.cpuCacheModeWriteCombined]
        )
        
        
        let vertexSource = SCNGeometrySource(
            buffer: vertexBuffer1,
            vertexFormat: vertexFormat,
            semantic: SCNGeometrySource.Semantic.vertex,
            vertexCount: pointsList.count,
            dataOffset: 0,
            dataStride: MemoryLayout<vector_float3>.size)
        
        let normalFormat = MTLVertexFormat.float3
        let normalBuffer = device.makeBuffer(
            bytes: normalsList,
            length: normalsList.count * MemoryLayout<vector_float3>.size,
            options: [.cpuCacheModeWriteCombined]
        )
        
        let normalSource = SCNGeometrySource(
            buffer: normalBuffer,
            vertexFormat: normalFormat,
            semantic: SCNGeometrySource.Semantic.normal,
            vertexCount: normalsList.count,
            dataOffset: 0,
            dataStride: MemoryLayout<vector_float3>.size)
        
        let indexData  = Data(bytes: indexList, count: MemoryLayout<CInt>.size * indexList.count)
        let indexElement = SCNGeometryElement(
            data: indexData,
            primitiveType: SCNGeometryPrimitiveType.triangles,
            primitiveCount: indexList.count / 3,
            bytesPerIndex: MemoryLayout<CInt>.size
        )
        
        let geo = SCNGeometry(sources: [vertexSource,normalSource], elements: [indexElement])
        geo.firstMaterial?.isLitPerPixel = true
        geo.firstMaterial?.isDoubleSided = true
        
        
        return MeshData(
            geometry: geo,
            vertexCount: pointsList.count,
            vertexBuffer1: vertexBuffer1,
            vertexBuffer2: vertexBuffer2,
            normalBuffer: normalBuffer)
        
    }
}

struct IcosahedralForm: PrimitiveBlueprint {
    
    
    
    var vertices:[vector_float3] = []
    var faces:[[Int]] = []
    var radius: Float
    var subdivisions = 0
    
    
    init(radius: Float, subdivisions: Int = 0){
        self.radius = radius
        self.subdivisions = subdivisions
        generator()
    }
    
    mutating func generator() {
        generateVertices()
        generateFaces()
        if subdivisions > 0 {
            subdivide(subdivisions)
        }
    }
    
    mutating func generateVertices(){
        // create 12 vertices of a icosahedron
        
        // shout out to all you sacred geometry hippies
        let t:Float = (1.0 + sqrt(5.0)) / 2.0
        
        
        vertices.append(vector_float3(-1,  t,  0))
        vertices.append(vector_float3( 1,  t,  0))
        vertices.append(vector_float3(-1, -t,  0))
        vertices.append(vector_float3( 1, -t,  0))
        
        vertices.append(vector_float3( 0, -1,  t))
        vertices.append(vector_float3( 0,  1,  t))
        vertices.append(vector_float3( 0, -1, -t))
        vertices.append(vector_float3( 0,  1, -t))
        
        vertices.append(vector_float3( t,  0, -1))
        vertices.append(vector_float3( t,  0,  1))
        vertices.append(vector_float3(-t,  0, -1))
        vertices.append(vector_float3(-t,  0,  1))
        
        vertices = vertices.map { normalize($0) }
    }
    
    mutating func generateFaces() {
        faces.append([0, 11, 5]);
        faces.append([0, 5, 1]);
        faces.append([0, 1, 7]);
        faces.append([0, 7, 10]);
        faces.append([0, 10, 11]);
        
        // 5 adjacent faces
        faces.append([1, 5, 9]);
        faces.append([5, 11, 4]);
        faces.append([11, 10, 2]);
        faces.append([10, 7, 6]);
        faces.append([7, 1, 8]);
        
        // 5 faces around point 3
        faces.append([3, 9, 4]);
        faces.append([3, 4, 2]);
        faces.append([3, 2, 6]);
        faces.append([3, 6, 8]);
        faces.append([3, 8, 9]);
        
        // 5 adjacent faces
        faces.append([4, 9, 5]);
        faces.append([2, 4, 11]);
        faces.append([6, 2, 10]);
        faces.append([8, 6, 7]);
        faces.append([9, 8, 1]);
    }
    
    func build() -> ([vector_float3], [vector_float3], [CInt]) {
        var pointsList: [vector_float3] = []
        var normalsList: [vector_float3] = []
        var indexList: [CInt] = []
        
        
        for f in self.faces {
            
            for i in f {
                pointsList.append(self.vertices[i] * radius)
                normalsList.append(normalize(self.vertices[i]))
                indexList.append(CInt(indexList.count))
            }
            
        }
        
        return (pointsList, normalsList, indexList)
    }
    
    
    mutating func subdivide(_ level: Int) {
        var v:[vector_float3] = vertices
        var f:[[Int]] = faces
        
        subdiv_e(&v, &f, level)
        
        vertices = v
        faces = f
    }
    
    // subdivide by edges
    func subdiv_e(_ v: inout [vector_float3], _ f: inout [[Int]], _ level: Int) {
        var nv:[vector_float3] = []
        var nf:[[Int]] = []
        var vcount = 0
        for face in f {
            var vmap = face.map { v[$0] }
            var midpoints = [vmap[0]+vmap[1], vmap[1]+vmap[2], vmap[2]+vmap[0]].map{ normalize($0) }
            let newPoints = vmap + midpoints
            let newFaces = [[5,0,3],[2,5,4],[4,5,3],[1,4,3]].map { $0.map{ $0+vcount } }
            
            nv.append(contentsOf: newPoints)
            nf.append(contentsOf: newFaces)
            vcount += 6
            
        }
        
        if(level>0){
            subdiv_e(&nv,&nf,level-1)
        }
        
        v = nv
        f = nf
    }
    
    
    
    // subdivide by face center
    func subdiv_f(_ v: inout [vector_float3], _ f: inout [[Int]], _ level: Int) {
        var nv:[vector_float3] = []
        var nf:[[Int]] = []
        var vcount = 0
        for face in f {
            var vmap = face.map { v[$0] }
            
            let c:vector_float3 = vmap.reduce(vector_float3()){ $0 + $1 } / vector_float3(3.0)
            let normalC = normalize(c)
            
            vmap.append(normalC)
            
            var iComb = [Int](0...2).combinations(2)
            iComb = iComb.map{ i in
                var _i = i
                _i.append(3)
                return _i
            }
            
            let vComb = iComb.map { $0.map{ vmap[$0] } }
            iComb = iComb.map{ $0.map{ $0 + vcount } }
            nf.append(contentsOf: iComb)
            for vec in vmap {
                nv.append(vec)
                vcount += 1
            }
            
        }
        
        if(level>0){
            subdiv_f(&nv,&nf,level-1)
        }
        
        v = nv
        f = nf
    }
    
}
