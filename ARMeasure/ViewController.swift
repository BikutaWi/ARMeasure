//
//  ViewController.swift
//  ARMeasure
//
//  Created by William Bikuta on 05.07.22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types:.featurePoint)
            
            if let hitResult = hitTestResults.first {
                createDot(at: hitResult)
            }
            
        }
    }
    
    // create sphere
    func createDot(at hitResult: ARHitTestResult) {
        let dot = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green
        
        dot.materials = [material]
        
        let node = SCNNode(geometry: dot)
        node.position = SCNVector3(x: hitResult.worldTransform.columns.3.x,
                                   y: hitResult.worldTransform.columns.3.y,
                                   z: hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(node)
        dotNodes.append(node)
        
        if(dotNodes.count >= 2){
            calculateDistance()
        }
    }
    
    func calculateDistance() {
        let firstPoint = dotNodes[0]
        let endPoint = dotNodes[1]
        
        let a = endPoint.position.x - firstPoint.position.x
        let b = endPoint.position.y - endPoint.position.y
        let c = endPoint.position.z - endPoint.position.z
        
        let result = abs(sqrt(pow(a, 2) + pow(b, 2) + pow(c,2)))
        
        showResult(text: "\(result)", atPosition: endPoint.position)
    }
    
    func showResult(text resultText: String, atPosition pos: SCNVector3) {
        textNode.removeFromParentNode()

        let text3D = SCNText(string: resultText, extrusionDepth: 1.0)
        text3D.firstMaterial?.diffuse.contents = UIColor.yellow
        
        textNode = SCNNode(geometry: text3D)
        textNode.position = SCNVector3(x: pos.x, y: pos.y + 0.01, z: pos.z)
        textNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}
