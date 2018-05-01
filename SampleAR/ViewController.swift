//
//  ViewController.swift
//  SampleAR
//
//  Created by Tsukasa Seto on 2018/05/01.
//  Copyright © 2018年 Tsukasa Seto. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var planes = [GridPlane]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

        let boxGeometory = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0) // 単位は1m, chamferRadiusは角をどれぐらい丸くするか?
        let boxMaterial = SCNMaterial()
        // boxMaterial.diffuse.contents = UIColor.blue
        boxMaterial.diffuse.contents = UIImage(named: "brick.jpg")
        boxGeometory.materials = [boxMaterial]
        let boxNode = SCNNode(geometry: boxGeometory)
        boxNode.position = SCNVector3(0, 0.2, -0.5) // 座標 SCNVector3は3次元空間での座標を指定する

        let textGeometory = SCNText(string: "Hello Swift", extrusionDepth: 1.0) // extrusionDepthは奥行き
        textGeometory.firstMaterial?.diffuse.contents = UIColor.orange
        textGeometory.firstMaterial?.name = "Color"
        let textNode = SCNNode(geometry: textGeometory)
        textNode.position = SCNVector3(0, 0.1, -1)
        textNode.scale = SCNVector3(0.02, 0.02, 0.02)

        let sphereGeometory = SCNSphere(radius: 0.2)
        let sphereMaterial = SCNMaterial()
        // sphereMaterial.diffuse.contents = UIColor.green
        sphereMaterial.diffuse.contents = UIImage(named: "earthmap.jpeg")
        sphereGeometory.materials = [sphereMaterial]
        let sphereNode = SCNNode(geometry: sphereGeometory)
        sphereNode.position = SCNVector3(0.4, 0.1, -2)

        let scene = SCNScene()
        scene.rootNode.addChildNode(boxNode)
        scene.rootNode.addChildNode(textNode)
        scene.rootNode.addChildNode(sphereNode)

        // Sceneにタップレゴグナイザーを追加
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tapRecognizer)

        sceneView.scene = scene

        // 平面検知用
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
    }

    @objc func tapped(recognizer: UIGestureRecognizer) {
        // タッチ位置に存在するNodeを抽出
        let sceneView = recognizer.view as! SCNView
        let touchLocation = recognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(touchLocation, options: [:])

        if !hitResults.isEmpty {
            let node = hitResults[0].node
            let material = node.geometry?.material(named: "Color")
            material?.diffuse.contents = UIColor.blue
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnhor = anchor as? ARPlaneAnchor else { return }

        let gridPlane = GridPlane(anchor: planeAnhor)
        planes.append(gridPlane)
        node.addChildNode(gridPlane)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // 平面検知のためのdetectionを指定
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
