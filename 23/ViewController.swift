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

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    @IBOutlet var Checher: UISwitch!
    @IBOutlet var Button: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        arView.session.delegate=self
        setupARView()
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
        
     
    }
    func setupARView(){
        arView.automaticallyConfigureSession = false
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        arView.session.run(config)
    }
    
    @objc
    func handleTap(recognizer: UITapGestureRecognizer){
        let location = recognizer.location(in: arView)
        let result = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        if let fres = result.first {
            let anchor = ARAnchor(name: "robota", transform: fres.worldTransform)
            arView.session.add(anchor: anchor)
        }
        else{
            print("Failed to place the robot")
        
        }
        
        /*if (Checher .isOn)
        {
            if let fres = result.first {
                
            }
            else{
                print("Failed to place the robot")
                
            }
        }
        else{
            
            
            
        }*/
        
    }
    
    func placeObject(named entityName: String, for anchor: ARAnchor){
        var cancellable: AnyCancellable? = nil
        cancellable = ModelEntity.loadModelAsync(named: "biped_robot")
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Unable to load a model due to error \(error)")
                }
            },  receiveValue: { [self] (model: Entity) in
                if let model = model as? ModelEntity {
                    
                    model.physicsBody = PhysicsBodyComponent(mode: .kinematic)
                    model.generateCollisionShapes(recursive: true)
                    
                    cancellable?.cancel()
                    print("Congrats! Model is successfully loaded!")
                    arView.installGestures([.rotation, .translation], for: model as HasCollision)
                    let anchorEntity = AnchorEntity(anchor: anchor)
                    anchorEntity.addChild(model)
                    anchorEntity.scale = [50 , 50, 50]
                    print("ici")
                    arView.scene.addAnchor(anchorEntity)
                    //transform(SIMD4<Float>(-0.13516279, -0.14392062, -1.7932674, 0.9999998))
                    //model.move(to: Transform(translation: [0,0,20]), relativeTo: model, duration: 40, timingFunction: .easeInOut)
                    let radians = 90.0 * Float.pi / 180.0
                    let t = Transform(rotation: simd_quatf(angle: radians, axis: SIMD3<Float>(1,0,0)))
                    //model.findEntity(named: "neck_4_joint")?.move(to: t, relativeTo: model)
                    
                    
                    
                    print(model.jointNames)
                    
                    
                    
                    //left_forearm_joint
                   
                    
                    
                   
                  
                        
                        
                        
                }
            })
    }
}

extension ViewController: ARSessionDelegate{
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName=="robota"{
                placeObject(named: anchorName, for: anchor)
            }
        }
    }
}
