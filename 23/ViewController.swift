//
//  ViewController.swift
//  23
//
//  Created by Paul Chartier on 27/09/2022.
//

import UIKit
import RealityKit
import ARKit
import Combine

class ViewController: UIViewController,ARSCNViewDelegate, ARSessionDelegate  {
    
    @IBOutlet var Checher: UISwitch!
    @IBOutlet var ARSCview: ARSCNView!
    @IBOutlet var Button: UIButton!
    
    var robot: SCNNode!
    var dummyNode: SCNNode!
    var refNode: SCNNode!
    
    private let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        robot = usdzNodeFromFile("biped_robot", exten: "usdz", internalNode: "biped_robot_ace")!
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        self.ARSCview.session.run(config)
        
        setupARView()
        
        ARSCview.delegate = (self as ARSCNViewDelegate)
        addTapGestureToSceneView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.ARSCview.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.ARSCview.session.pause()
    }
    
    func setupARView(){
        // Show statistics such as fps and timing information
        ARSCview.showsStatistics = true
        ARSCview.preferredFramesPerSecond = 20
        ARSCview.rendersContinuously = true
        ARSCview.autoenablesDefaultLighting = true
        ARSCview.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    
    func addTapGestureToSceneView() {
        ARSCview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap(recognizer:))))
      }
    
    @objc func didTap(recognizer: UITapGestureRecognizer) {
        print("JENTRE ICI")
        robot.enumerateChildNodes { (node, stop) in
                print(node.name ?? "??")
            if(node.name == "neck_1_joint")
            {
                let rotation = SCNAction.rotateBy(x: CGFloat(Float.pi / 2), y: 0, z: 0, duration: 1)
                    let repeatRotation = SCNAction.repeatForever(rotation)
                    node.runAction(repeatRotation)
            }
        }
      }
    
    
    private func usdzNodeFromFile(_ file: String, exten: String, internalNode: String) -> SCNNode? {
        let rootNode = SCNNode()
        let scale = 1.0
        
        guard let fileUrl = Bundle.main.url(forResource: file, withExtension: exten) else { fatalError() }
        let scene = try! SCNScene(url: fileUrl, options: [.checkConsistency: true])
        let node = scene.rootNode.childNode(withName: internalNode, recursively: true)!
        node.name = internalNode
        node.position = SCNVector3(0, 0, 0)
        node.scale = SCNVector3(scale, scale, scale)
        rootNode.addChildNode(node)
        
        return rootNode
    }
   
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchorPlane = anchor as? ARPlaneAnchor else { return }
        print("Anchor trouvée : ", anchorPlane.planeExtent)
        if(Checher.isOn)
        {
            node.addChildNode(robot)
            node.castsShadow = true
        }
    }
}
