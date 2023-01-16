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
import MultipeerConnectivity




class ViewController: UIViewController,ARSCNViewDelegate, ARSessionDelegate,MCSessionDelegate, MCBrowserViewControllerDelegate  {
    
    @IBOutlet var Checher: UISwitch!
    @IBOutlet var ARSCview: ARSCNView!
    @IBOutlet var Button: UIButton!
    
    var peerID:MCPeerID!
    var mcSession:MCSession!
    var mcAdvertiserAssistant:MCAdvertiserAssistant!
    
    var robot: SCNNode!
    var dummyNode: SCNNode!
    var refNode: SCNNode!
    
    private let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConnection()
        robot = usdzNodeFromFile("biped_robot", exten: "usdz", internalNode: "biped_robot_ace")!
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        self.ARSCview.session.run(config)
        setupARView()
        Button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        
        ARSCview.delegate = (self as ARSCNViewDelegate)
        addTapGestureToSceneView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.ARSCview.session.pause()
    }
    
    func setupARView(){
        // Show statistics such as fps and timing information
        ARSCview.showsStatistics = true
        ARSCview.preferredFramesPerSecond = 60
        ARSCview.rendersContinuously = true
        ARSCview.autoenablesDefaultLighting = true
        //ARSCview.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showSkeletons]
        
    }
    
    func addTapGestureToSceneView() {
        ARSCview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap(recognizer:))))
    }
    
    @objc func didTap(recognizer: UITapGestureRecognizer) {
        print("JENTRE ICI")
        /*
         for obj in objects {
         robot.enumerateChildNodes { (node, stop) in
         if(obj.name == node.name)
         {
         print(node.position)
         print(obj.name)
         let vect = SCNVector3(obj.x, obj.y, obj.z)
         let action = SCNAction.moveBy(x: obj.x, y: obj.y, z: obj.z, duration: 0)
         node.runAction(action)
         }
         }
         }*/
    }
    
    @objc func buttonPressed(_ sender: UIButton!)  {
        let actionSheet = UIAlertController(title: "Réunion 3.0", message: "Do you want to Host or Join a session?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Host Session", style: .default, handler: { (action:UIAlertAction) in
            
            self.mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "bodytrack", discoveryInfo: nil, session: self.mcSession)
            self.mcAdvertiserAssistant.start()
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Join Session", style: .default, handler: { (action:UIAlertAction) in
            let mcBrowser = MCBrowserViewController(serviceType: "bodytrack", session: self.mcSession)
            mcBrowser.delegate = self
            self.present(mcBrowser, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func usdzNodeFromFile(_ file: String, exten: String, internalNode: String) -> SCNNode? {
        let rootNode = SCNNode()
        let scale = 0.3
        
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
        
        node.addChildNode(robot)
        node.castsShadow = true
        
    }
    
    // MARK: Setup Connection
    func setupConnection(){
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        mcSession.delegate = self
        let mcBrowser = MCBrowserViewController(serviceType: "bodytrack", session: self.mcSession)
        self.present(mcBrowser, animated: true, completion: nil)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        @unknown default:
            fatalError("Unknow State")
        }
    }
    
    // MARK: Receive the data

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let decoder = JSONDecoder()
            
            let matrix = try decoder.decode(CustomStruct.self, from: data)
            print(matrix.name,matrix.matrix)
        } catch {
            print(error)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true,completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true,completion: nil)
    }
    
}




