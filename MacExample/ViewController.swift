//
//  ViewController.swift
//  MacExample
//
//  Created by Jacob Martin on 4/17/17.
//  Copyright © 2017 Jacob Martin. All rights reserved.
//

import Cocoa
import Metal
import QuartzCore
import SceneKit

class ViewController: NSViewController, SCNSceneRendererDelegate {
    
    @IBOutlet weak var scnView:SCNView!
    
    var shaderData:ShaderData? = nil
    var planeNode:SCNNode? = nil
    var meshDataA:MeshData!
    var meshDataB:MeshData!
    
    
    var device:MTLDevice!
    
    var processor:MeshProcessor!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        device = MTLCreateSystemDefaultDevice()
        processor = MeshProcessor(device: device)
        
        let scene = SCNScene()
        scene.background.contents = NSColor.black
        scnView.scene = scene
        
        scnView.debugOptions = .showWireframe
        
        let spotLight = SCNLight()
        spotLight.type = SCNLight.LightType.omni
        spotLight.color = NSColor.cyan
    
        spotLight.castsShadow = true
        spotLight.shadowBias = 5
        
        let spotLightNode = SCNNode()
        spotLightNode.light = spotLight
        
        var spotLightTransform = SCNMatrix4Identity
        spotLightTransform = SCNMatrix4Translate(spotLightTransform, 20,20,20)
        spotLightTransform = SCNMatrix4Rotate(spotLightTransform, CGFloat(60 * Float.pi/180), 0, 1, 0)
        spotLightNode.transform = spotLightTransform
        
        scene.rootNode.addChildNode(spotLightNode)
        
        
        let ambientLight = SCNLight()
        ambientLight.color = NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        ambientLight.type = SCNLight.LightType.ambient
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        scene.rootNode.addChildNode(ambientLightNode)
        
        
        
        scnView.delegate = self
        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
        //       / scnView.debugOptions.insert(SCNDebugOptions.showWireframe)
        // scnView.debugOptions.insert(SCNDebugOptions.showBoundingBoxes)
        // scnView.debugOptions.insert(SCNDebugOptions.showLightExtents)
        // scnView.backgroundColor = UIColor.lightGray
        scnView.autoenablesDefaultLighting = true
        scnView.isPlaying = true
        
        //scnView.debugOptions = SCNDebugOptions.ShowWireframe
        
        //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(GameViewController.newMesh))
        //        tapGesture.numberOfTapsRequired = 2
        //        scnView.addGestureRecognizer(tapGesture)
        let loc = SCNVector3ToFloat3(SCNVector3(0,0,0))
        
        self.shaderData = ShaderData(location:loc)
        buildGeospheres()
    }
    
//    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
//        
//        if shaderData != nil {
//            shaderData!.location.x += 0.001
//            processor.compute(meshDataA, data: shaderData!)
//        }
//        
//        
//    }
    
    func cameraZaxis(_ view:SCNView) -> SCNVector3 {
        let cameraMat = view.pointOfView!.transform
        return SCNVector3Make(cameraMat.m31*(-1), cameraMat.m32*(-1), cameraMat.m33*(-1))
    }
    
    
    
    func buildGeospheres() {
        
        
//        meshDataA = Mesh.buildGeosphere(device, radius: 9, subdivisions: 2)
//        meshDataB = Mesh.buildGeosphere(device, radius: 11, subdivisions: 0)
      
        let geoNodeA = MSHGeosphere(device, radius: 11, subdivisions: 0)
        geoNodeA.castsShadow = true
        
        let geoNodeB = MSHGeosphere(device, radius: 10, subdivisions: 2)
        geoNodeA.castsShadow = true
        
//        let boole = MSHBoole(geoNodeB, geoNodeA)
        
//        if let existingNode = planeNode {
//            scnView.scene?.rootNode.replaceChildNode(existingNode, with: geoNodeA)
//        } else {
//            scnView.scene?.rootNode.addChildNode(geoNodeA)
//        }
        
        scnView.scene?.rootNode.addChildNode(geoNodeA)
        scnView.scene?.rootNode.addChildNode(geoNodeB)
        
        
    }
    
}
