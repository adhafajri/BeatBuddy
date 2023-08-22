//
//  CameraView.swift
//  BeatBuddy
//
//  Created by Muhammad Adha Fajri Jonison on 21/08/23.
//

import Foundation
import Vision
import AVFoundation
import SwiftUI

protocol CameraViewControllerDelegate : AnyObject {
    func cameraViewController(_ controller : CameraViewController)
    func cameraViewControllerDidCancel(_ controller : CameraViewController)
    func cameraViewController(_ controller : CameraViewController, didFailWithError error : Error)
}

struct CameraView: UIViewControllerRepresentable {
    var countdownCircleView: CountdownCircleView
    var gameLogic: GameService
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraViewController = CameraViewController()
        cameraViewController.delegate = context.coordinator
        cameraViewController.gameLogic = gameLogic
        cameraViewController.countdownCircleView = countdownCircleView
        return cameraViewController
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, CameraViewControllerDelegate {
        
        func cameraViewController(_ controller: CameraViewController) {
        }
        
        func cameraViewControllerDidCancel(_ controller: CameraViewController) {
            controller.dismiss(animated: true)
        }
        
        func cameraViewController(_ controller: CameraViewController, didFailWithError error: Error) {
            print(error.localizedDescription)
            controller.dismiss(animated: true)
        }
    }
}

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    weak var delegate: CameraViewControllerDelegate?
    var gameLogic: GameService!
    var countdownCircleView: CountdownCircleView!
    
    private let session = AVCaptureSession()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    let bodyPointView = BodyPointView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("[CameraViewController]")
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            print("[CameraViewController][input]", input)
            
            if session.canAddInput(input) {
                session.addInput(input)
                
                videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
                
                if session.canAddOutput(videoDataOutput) {
                    session.addOutput(videoDataOutput)
                    
                    guard let connection = videoDataOutput.connection(with: .video) else { return }
                    
                    connection.videoOrientation = .portrait
                    
                    DispatchQueue.global(qos: .userInitiated).async { // 1
                        self.session.startRunning()
                    }
                    
                    let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                    previewLayer.frame = view.bounds
                    view.layer.addSublayer(previewLayer)
                    
                    // Configure the body point view and add it as a subview
                    bodyPointView.frame = view.bounds
                    bodyPointView.backgroundColor = .clear
                    view.addSubview(bodyPointView)
                    
                    // Add countdownCircleView as a subview
                    view.addSubview(countdownCircleView)
                    
                }
            }
        } catch {
            
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.stopRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try requestHandler.perform([poseRequest])
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    lazy var poseRequest = VNDetectHumanBodyPoseRequest(completionHandler: { request, error in
        if let results = request.results as? [VNHumanBodyPoseObservation] {
            guard let observation = results.first else {
                return
            }
            
            // Get specific body points
            let leftWristPoint = try? observation.recognizedPoint(.leftWrist)
            let rightWristPoint = try? observation.recognizedPoint(.rightWrist)
            let leftAnklePoint = try? observation.recognizedPoint(.leftAnkle)
            let rightAnklePoint = try? observation.recognizedPoint(.rightAnkle)
            
            guard leftWristPoint?.confidence ?? 0 > 0.3
                    && rightWristPoint?.confidence ?? 0 > 0.3
                    && leftAnklePoint?.confidence ?? 0 > 0.3
                    && rightAnklePoint?.confidence ?? 0 > 0.3
            else {
                DispatchQueue.main.async {
                    self.bodyPointView.bodyPoints.removeAll()
                    self.bodyPointView.setNeedsDisplay()
                }
                return
            }
            
            // Convert points from Vision coordinates to AVFoundation coordinates.
            let bodyPoints = [
                "leftWrist": CGPoint(x: 1 - (leftWristPoint?.location.x ?? 0), y: 1 - (leftWristPoint?.location.y ?? 0)),
                "rightWrist": CGPoint(x: 1 - (rightWristPoint?.location.x ?? 0), y: 1 - (rightWristPoint?.location.y ?? 0)),
                "leftAnkle": CGPoint(x: 1 - (leftAnklePoint?.location.x ?? 0), y: 0.95 - (leftAnklePoint?.location.y ?? 0)),
                "rightAnkle": CGPoint(x: 1 - (rightAnklePoint?.location.x ?? 0), y: 0.95 - (rightAnklePoint?.location.y ?? 0)),
            ]
            
            // Update the body points on the custom view
            DispatchQueue.main.async {
                self.bodyPointView.bodyPoints = bodyPoints
                self.bodyPointView.setNeedsDisplay()
                
                // Check collision with circles
                for (uuid, data) in self.countdownCircleView.targetPoints {
                    let now = DispatchTime.now().uptimeNanoseconds
                    let endTime = data.endTime.uptimeNanoseconds
                    
                    if now > endTime {
                        return
                    }
                    
                    let diff = endTime - now
                    let diffSeconds = Double(diff) / 1_000_000_000.0  // Convert nanoseconds to seconds
                    
                    if diffSeconds > 1.5 {
                        return
                    }
                    
                    let circleCenter = CGPoint(x: data.point.x, y: data.point.y)
                    let circleRadius: CGFloat = 0.1 // Modify this based on your circle size
                    
                    // Check collision with left wrist
                    if let leftWristPoint = bodyPoints["leftWrist"] {
                        if self.distanceBetweenPoints(leftWristPoint, circleCenter) <= circleRadius {
                            self.countdownCircleView.targetPoints.removeValue(forKey: uuid)
                            self.countdownCircleView.shrinkingCircles.removeValue(forKey: uuid)
                            self.gameLogic.score += 1
                            self.gameLogic.comboCounter += 1
                            self.countdownCircleView.setNeedsDisplay()
                            return
                        }
                    }
                    
                    // Check collision with right wrist
                    if let rightWristPoint = bodyPoints["rightWrist"] {
                        if self.distanceBetweenPoints(rightWristPoint, circleCenter) <= circleRadius {
                            self.countdownCircleView.targetPoints.removeValue(forKey: uuid)
                            self.countdownCircleView.shrinkingCircles.removeValue(forKey: uuid)
                            self.gameLogic.score += 1
                            self.gameLogic.comboCounter += 1
                            self.countdownCircleView.setNeedsDisplay()
                            return
                        }
                    }
                    
                    // Check collision with left ankle
                    if let leftAnklePoint = bodyPoints["leftAnkle"] {
                        if self.distanceBetweenPoints(leftAnklePoint, circleCenter) <= circleRadius {
                            self.countdownCircleView.targetPoints.removeValue(forKey: uuid)
                            self.countdownCircleView.shrinkingCircles.removeValue(forKey: uuid)
                            self.gameLogic.score += 1
                            self.gameLogic.comboCounter += 1
                            self.countdownCircleView.setNeedsDisplay()
                            return
                        }
                    }
                    
                    // Check collision with right ankle
                    if let rightAnklePoint = bodyPoints["rightAnkle"] {
                        if self.distanceBetweenPoints(rightAnklePoint, circleCenter) <= circleRadius {
                            self.countdownCircleView.targetPoints.removeValue(forKey: uuid)
                            self.countdownCircleView.shrinkingCircles.removeValue(forKey: uuid)
                            self.gameLogic.score += 1
                            self.gameLogic.comboCounter += 1
                            self.countdownCircleView.setNeedsDisplay()
                            return
                        }
                    }
                }
                
                
            }
            
            
            
        } else if let error = error {
            print(error.localizedDescription)
            self.delegate?.cameraViewController(self, didFailWithError: error)
        }
    })
    
    func distanceBetweenPoints(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {
        let xDist = point2.x - point1.x
        let yDist = point2.y - point1.y
        return sqrt((xDist * xDist) + (yDist * yDist))
    }
    
}

class BodyPointView: UIView {
    var bodyPoints: [String: CGPoint] = [:]
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setFillColor(UIColor.red.cgColor)
        
        for (_, point) in bodyPoints {
            let circle = CGRect(x: point.x * rect.width, y: point.y * rect.height, width: 30, height: 30)
            context.addEllipse(in: circle)
            context.fillPath()
        }
    }
}
