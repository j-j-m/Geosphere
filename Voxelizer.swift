//
//  Voxelizer.swift
//  Geosphere
//
//  Created by Jacob Martin on 4/18/17.
//  Copyright © 2017 Jacob Martin. All rights reserved.
//

import Foundation
import SceneKit
import ModelIO
import SceneKit.ModelIO

class Voxelizer {
    
    let asset:MDLAsset
    
    init(_ node: SCNNode){
        let tempScene = SCNScene()
        tempScene.rootNode.addChildNode(node)
        asset = MDLAsset(scnScene: tempScene)
    }
    
    var voxels: MDLVoxelArray {
        return MDLVoxelArray(asset: asset, divisions: 200, interiorShells: 0, exteriorShells: 0, patchRadius: 0.0)
    }
}
