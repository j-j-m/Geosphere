//
//  Icosahedral.swift
//  Geosphere
//
//  Created by Jacob Martin on 4/17/17.
//  Copyright © 2017 Jacob Martin. All rights reserved.
//

import Foundation
import Metal
import SceneKit



extension Mesh {
    
    class func buildIcosahedron(_ device:MTLDevice, radius: Float) -> MeshData {
        
        let ico = IcosahedralForm(radius: radius)
        
        return ico.meshdata(device)
        
    }
    
    
    class func buildGeosphere(_ device:MTLDevice, radius: Float, subdivisions: Int) -> MeshData {
        let ico = IcosahedralForm(radius: radius, subdivisions: subdivisions)
        return ico.meshdata(device)
    }
    
    
    
    
}
