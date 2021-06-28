//
//  ViewController.swift
//  AR Image Finder
//
//  Created by Evgeniy Goncharov on 28.06.2021.
//

import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    
    // MARK: - IBOutlets
    @IBOutlet var sceneView: ARSCNView!
    
    // MARK: Private Properties
    private let videoPlayer: AVPlayer = {
        let url = Bundle.main.url(forResource: "rub",
                                  withExtension: "mp4",
                                  subdirectory: "art.scnassets")!
        return AVPlayer(url: url)
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    }
    
    // MARK: - Override Method
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        //Detect images
        configuration.maximumNumberOfTrackedImages = 2
        configuration.trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)!

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // Check that we have go an image anchor
        switch anchor {
        case let imageAnchor as ARImageAnchor:
            nodeAdded(node, for: imageAnchor)
        case let planeAnchor as ARPlaneAnchor:
            nodeAdded(node, for: planeAnchor)
        default:
            print(#line, #function, "Unknown anchor has been discovered")
        }
        
    }
    
    func nodeAdded(_ node: SCNNode, for imageAnchor: ARImageAnchor) {
        
        // Get image size
        let image = imageAnchor.referenceImage
        let size = image.physicalSize
        
        // Create plane of the same size
        let height = 69 / 65 * size.height
        let weight = image.name == "horses" ?
           157 / 150 * 15 / 8.4475 * size.width :
            157 / 150 * 15 / 5.5587 * size.width
        
        let plane = SCNPlane(width: weight, height: height)
        plane.firstMaterial?.diffuse.contents = image.name == "horses" ?
            UIImage(named: "monument") :
            videoPlayer
        
        
        if image.name == "horses" {
            videoPlayer.play()
        }
        
        
        
        // Create plane node
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi / 2
        
        // Move plane
        planeNode.position.x += image.name == "theatre" ? 0.01 : 0
        
        //Run animation
        planeNode.runAction(
            .sequence([
                .wait(duration: 10),
                .fadeOut(duration: 3),
                .removeFromParentNode()
        ]))
        
        // Add plane node to the given node
        node.addChildNode(planeNode)
        
        print(#line, #function, image.name , image.physicalSize)
    }
    
    func nodeAdded(_ node: SCNNode, for planeAnchor: ARPlaneAnchor) {
        print(#line, #function, "Plane \(planeAnchor) added")
    }

}
