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


class ViewController: UIViewController,ARSCNViewDelegate, ARSessionDelegate,MCSessionDelegate, MCBrowserViewControllerDelegate, StreamDelegate  {
    
    
    
    @IBOutlet var Checher: UISwitch!
    @IBOutlet var ARSCview: ARSCNView!
    @IBOutlet var Button: UIButton!
    
    @IBOutlet var connectColor: UIView!
    @IBOutlet var connectLabel: UILabel!
    var peerID:MCPeerID!
    var mcSession:MCSession!
    var mcAdvertiserAssistant:MCAdvertiserAssistant!
    
    var robot: SCNNode!
    var dummyNode: SCNNode!
    var refNode: SCNNode!
    
    var inputStream : InputStream!
    var outputStream : OutputStream!
    var audioSession : AVAudioSession = AVAudioSession.sharedInstance()
    var audioPlayer : AVAudioPlayerNode = AVAudioPlayerNode()
    var engine : AVAudioEngine = AVAudioEngine()
    var mainMixer : AVAudioMixerNode!
    var audioFormat : AVAudioFormat!
    
    var isConnected : Bool = false
    
    
    
    private let config = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        dummyNode = SCNNode()
        refNode = SCNNode()
        super.viewDidLoad()
        setupConnection()
        
        robot = usdzNodeFromFile("biped_robot", exten: "usdz", internalNode: "biped_robot_ace")!
        
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
        mcSession.disconnect()
        //self.ARSCview.session.pause()
    }
    
    func setConnectionStatus(_ isConnected: Bool) {
        connectColor.backgroundColor = isConnected ? .green : .red
        connectLabel.text = isConnected ? "Connected" : "Disconnected"
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
        let location = recognizer.location(in: ARSCview)
        let query = ARSCview.raycastQuery(from: location, allowing: .existingPlaneInfinite, alignment: .horizontal)
        let result = ARSCview.session.raycast(query!)
        if let fres = result.first {
            let anchor = ARAnchor(name: "robota", transform: fres.worldTransform)
            ARSCview.session.add(anchor: anchor)
            
        }
        else{
            print("Failed to place the robot")
        }
        
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
        let scale = 1
        
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
        let anchorPlane = anchor
        print("Anchor trouvée : ", anchorPlane.name as Any)
        if anchor.name == "robota"{
            let node = self.ARSCview.node(for: anchor)
            node?.addChildNode(robot)
        }
        //node.addChildNode(robot)
        dummyNode.addChildNode(refNode)
        self.ARSCview.scene.rootNode.addChildNode(dummyNode)
    }
    
    // MARK: Setup Connection
    func setupConnection(){
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        mcSession.delegate = self
        let mcBrowser = MCBrowserViewController(serviceType: "bodytrack", session: self.mcSession)
        //self.present(mcBrowser, animated: true, completion: nil)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            DispatchQueue.main.async {
                self.setConnectionStatus(true)
            }
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            DispatchQueue.main.async {
                self.setConnectionStatus(true)
            }

        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
            DispatchQueue.main.async {
                self.setConnectionStatus(false)
            }

        @unknown default:
            fatalError("Unknow State")
        }
    }
    
    // MARK: Receive the data
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("jentre dans le receive")
        do {
            print("puis le do")
            let decoder = JSONDecoder()
            let joints = try decoder.decode([CustomStruct].self, from: data)
            for joint in joints {
                let scnMatrix = SCNMatrix4(joint.matrix)
                if let tracked = robot.childNode(withName: joint.name, recursively: true) {
                    tracked.transform = scnMatrix
                } else {
                    print("Could not find child node with name: \(joint.name)")
                }
            }
        } catch {
            print(error)
        }
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true,completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true,completion: nil)
    }
};
