//
//  MeshNode.swift
//  Geosphere
//
//  Created by Jacob Martin on 4/18/17.
//  Copyright © 2017 Jacob Martin. All rights reserved.
//

import Foundation
import SceneKit
import Metal

protocol MeshNode {
    var voxelizer: Voxelizer? { get }
    var voxels: MDLVoxelArray? { get }
    
    
    
}

extension MeshNode where Self: SCNNode {
    var voxelizer: Voxelizer? {
        return Voxelizer(self)
    }
    
    var voxels: MDLVoxelArray? {
        return voxelizer?.voxels
    }
}

class MSHGeosphere: SCNNode, MeshNode {
    convenience init(_ device:MTLDevice, radius: Float, subdivisions: Int) {
        self.init()
        let mesh = Mesh.buildGeosphere(device, radius: radius, subdivisions: subdivisions)
        self.geometry = mesh.geometry
    }
}


class MSHBoole: SCNNode, MeshNode {
    convenience init(_ a: MeshNode, _ b: MeshNode) {
        self.init()
        guard let v_a = a.voxels, let v_b = b.voxels
        else {
            self.geometry = nil
            return
        }
        let rep:MDLVoxelArray = v_a
        rep.difference(with: v_b)
        let d = rep.voxelIndices()
        let da = MDLMeshBufferDataAllocator()
        let buffer:MDLMeshBuffer  = da.newBuffer(with: d!, type: .index)
        
//        let allocator =  MDLMeshBufferZone.allocator
        //let msh = rep.mesh(using: buffer.allocator)
        let msh = rep.coarseMesh()
        self.geometry = SCNGeometry(mdlMesh: msh!)
        
        
        
    }
}

