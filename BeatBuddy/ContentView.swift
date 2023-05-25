//
//  ContentView.swift
//  pc1
//
//  Created by Muhammad Adha Fajri Jonison on 20/05/23.
//

import SwiftUI
import Vision
import AVFoundation

class GameLogic: NSObject, ObservableObject, AVAudioPlayerDelegate, CountdownCircleViewDelegate {
    @Published var score = 0
    @Published var comboCounter = 0
    @Published var isMusicFinished = false
    var audioPlayer: AVAudioPlayer!
    var countdownCircleView: CountdownCircleView!
    var gameTimer: Timer? // Keep a reference to the game timer
    
    var previousRandomX: CGFloat = 0.0
    var previousRandomY: CGFloat = 0.0
    
    
    override init() {
        super.init()
        
        let audioURL = Bundle.main.url(forResource: "song", withExtension: "mp3")! // Replace with your audio file
        
        audioPlayer = try! AVAudioPlayer(contentsOf: audioURL)
        
        audioPlayer.isMeteringEnabled = true
        audioPlayer.delegate = self
        
        countdownCircleView = CountdownCircleView()
        countdownCircleView.delegate = self
    }
    
    func didMissBeat(_ countdownCircleView: CountdownCircleView) {
        print("didMissBeat")
        comboCounter = 0
    }
    
    func startGame() {
        audioPlayer.play()
        
        let screenBounds = UIScreen.main.bounds
        let normalizedCircleRadius = 100 / min(screenBounds.width, screenBounds.height)
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.audioPlayer.updateMeters()
            
            let power = self.audioPlayer.peakPower(forChannel: 0)
            
            if power > -5.0 {
                var randomX: CGFloat = 0.0
                var randomY: CGFloat = 0.0
                
                repeat {
                    randomX = CGFloat.random(in: normalizedCircleRadius...1-normalizedCircleRadius)
                    randomY = CGFloat.random(in: normalizedCircleRadius...1-normalizedCircleRadius)
                } while abs(randomX - self.previousRandomX) < normalizedCircleRadius && abs(randomY - self.previousRandomY) < normalizedCircleRadius
                
                self.countdownCircleView.startCountdown(for: UUID(), at: CGPoint(x: randomX, y: randomY), duration: 2.0)
                
                self.previousRandomX = randomX
                self.previousRandomY = randomY
            }
        }
    }
    
    func stopGame() {
        audioPlayer.stop()
        gameTimer?.invalidate() // Invalidate the timer when the game stops
        gameTimer = nil // Set the timer to nil to avoid any retain cycles
        
        self.countdownCircleView.targetPoints.removeAll()
        self.countdownCircleView = CountdownCircleView()
        countdownCircleView.delegate = self
    }
    
    func resetGame() {
        score = 0 // Reset score
        comboCounter = 0
        audioPlayer.stop() // Stop current playback
        audioPlayer.currentTime = 0 // Reset audio player to start
        gameTimer?.invalidate() // Invalidate the timer
        gameTimer = nil // Set the timer to nil
        self.countdownCircleView.targetPoints.removeAll()
        self.countdownCircleView = CountdownCircleView()
        countdownCircleView.delegate = self
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Handle the music stop event here
        print("Music has stopped")
        isMusicFinished = true
    }
}

protocol CountdownCircleViewDelegate: AnyObject {
    func didMissBeat(_ countdownCircleView: CountdownCircleView)
}

class CountdownCircleView: UIView {
    var targetPoints: [UUID: (point: CGPoint, endTime: DispatchTime, originalDuration: Double)] = [:]
    var shrinkingCircles: [UUID: CGFloat] = [:]
    var expiredPoints: [UUID: CGPoint] = [:]
    var expiredLayers: [UUID: CAShapeLayer] = [:]
    var displayLink: CADisplayLink?
    weak var delegate: CountdownCircleViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDisplayLink()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDisplayLink()
    }
    
    func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateShrinkingCircles))
        displayLink?.add(to: .current, forMode: .default)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setStrokeColor(UIColor.green.cgColor)
        context.setFillColor(UIColor.green.withAlphaComponent(0.5).cgColor) // add this
        context.setLineWidth(5.0)
        
        for (_, data) in targetPoints {
            let circle = CGRect(x: data.point.x * rect.width, y: data.point.y * rect.height, width: 100, height: 100)
            context.addEllipse(in: circle)
            context.drawPath(using: .fillStroke) // change this line
            context.strokePath()
        }
        
        context.setStrokeColor(UIColor.red.cgColor)
        context.setFillColor(UIColor.clear.cgColor) // add this
        for (id, scale) in shrinkingCircles {
            if let point = targetPoints[id]?.point {
                let diameter = CGFloat(100) // this should be the initial diameter of your circle
                let originX = point.x * rect.width - scale / 2 + diameter / 2
                let originY = point.y * rect.height - scale / 2 + diameter / 2
                let circle = CGRect(x: originX, y: originY, width: scale, height: scale)
                context.addEllipse(in: circle)
                context.strokePath()
            }
        }
    }
    
    
    
    func startCountdown(for uuid: UUID, at point: CGPoint, duration: TimeInterval) {
        targetPoints[uuid] = (point: point, endTime: DispatchTime.now() + duration, originalDuration: duration)
        shrinkingCircles[uuid] = 150 // Start size of shrinking circle
        setNeedsDisplay()
    }
    
    @objc func updateShrinkingCircles() {
        let now = DispatchTime.now().uptimeNanoseconds
        let greenCircleSize: CGFloat = 100.0
        let initialCircleSize: CGFloat = 150.0
        for (id, data) in targetPoints {
            let endTime = data.endTime.uptimeNanoseconds
            if now >= endTime {
                // Instead of removing, save to expiredPoints
                expiredPoints[id] = data.point
                targetPoints.removeValue(forKey: id)
                shrinkingCircles.removeValue(forKey: id)
                drawAndAnimateX(for: id, at: data.point)
                delegate?.didMissBeat(self)
            } else {
                if shrinkingCircles[id] != nil {
                    let remainingTime = Double(endTime - now) / 1_000_000_000.0 // converting nanoseconds to seconds
                    
                    let scalePercentage = CGFloat(remainingTime / data.originalDuration)
                    let newScale = greenCircleSize + ((initialCircleSize - greenCircleSize) * scalePercentage)
                    
                    shrinkingCircles[id] = newScale
                }
            }
        }
        setNeedsDisplay()
    }
    
    private func drawAndAnimateX(for id: UUID, at point: CGPoint) {
        let center = CGPoint(x: point.x * bounds.width + 50, y: point.y * bounds.height + 50)
        let lineLength: CGFloat = 50
        let color = UIColor.red.cgColor
        let lineWidth: CGFloat = 5.0
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: center.x - lineLength / 2, y: center.y - lineLength / 2))
        path.addLine(to: CGPoint(x: center.x + lineLength / 2, y: center.y + lineLength / 2))
        
        path.move(to: CGPoint(x: center.x + lineLength / 2, y: center.y - lineLength / 2))
        path.addLine(to: CGPoint(x: center.x - lineLength / 2, y: center.y + lineLength / 2))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = lineWidth
        layer.addSublayer(shapeLayer)
        
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = 1
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        shapeLayer.add(animation, forKey: nil)
        
        expiredLayers[id] = shapeLayer
    }
    
}

struct ContentView: View {
    enum PlayState {
        case Menu
        case Play
        case Pause
        case Finish
    }
    
    @AppStorage("highScore") private var highScore = 0
    @StateObject private var gameLogic = GameLogic()
    @State private var score: Int = 0
    @State private var animateScoreChange = false
    @State private var comboCounter: Int = 0
    @State private var animateComboChange = false
    @State private var playState: PlayState = .Menu
    
    var body: some View {
        switch playState {
        case .Menu:
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal)
                
                Text("BEATBUDDY")
                    .font(.system(size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize, weight: .light))
                    .padding(.horizontal)
                
                Spacer().fixedSize().padding()
                
                if highScore > 0 {
                    Text("HIGH SCORE: \(highScore)")
                }
                
                Button {
                    withAnimation {
                        playState = .Play
                        gameLogic.startGame()
                    }
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("PLAY")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                
                Button {
                    withAnimation {
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "xmark")
                        Text("EXIT")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            }
        case .Play:
            ZStack {
                CameraView(countdownCircleView: gameLogic.countdownCircleView, gameLogic: gameLogic)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer().fixedSize().padding(4)
                    
                    HStack {
                        Spacer().fixedSize()
                        
                        Text("SCORE: \(score)")
                            .font(.largeTitle)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .scaleEffect(self.animateScoreChange ? 1.5 : 1.0)
                            .foregroundColor(self.animateScoreChange ? .red : .black)
                            .animation(.easeInOut(duration: 0.5))
                            .padding(.top)
                        
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                playState = .Pause
                                gameLogic.stopGame()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "pause.fill")
                                Text("PAUSE")
                            }
                            
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Spacer().fixedSize()
                    }
                    
                    Spacer()
                    
                    if comboCounter > 1 {
                        Text("\(comboCounter)X COMBO")
                            .font(.largeTitle)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .scaleEffect(self.animateComboChange ? 1.5 : 1.0)
                            .foregroundColor(self.animateComboChange ? .red : .black)
                            .animation(.easeInOut(duration: 0.5))
                    }
                }
            }
            .onReceive(gameLogic.$score, perform: { newScore in
                withAnimation {
                    if (newScore == 0) {
                        return
                    }
                    
                    if newScore > self.score {
                        self.animateScoreChange = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.animateScoreChange = false
                        }
                    }
                    
                    self.score = newScore
                }
            })
            .onReceive(gameLogic.$comboCounter, perform: { newCombo in
                withAnimation {
                    self.animateComboChange = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.animateComboChange = false
                    }
                    
                    
                    self.comboCounter = newCombo
                }
            })
            .onReceive(gameLogic.$isMusicFinished) { isFinished in
                withAnimation {
                    if isFinished {
                        print("[isFinished]", isFinished)
                        if score > highScore {
                            highScore = score
                        }
                        
                        self.playState = .Finish
                        gameLogic.isMusicFinished = false
                    }
                }
            }
        case .Pause:
            VStack {
                Button {
                    withAnimation {
                        playState = .Play
                        gameLogic.startGame()
                        
    //                    if score > highScore {
    //                        highScore = score
    //                    }
    //
    //                    self.playState = .Finish
    //                    gameLogic.isMusicFinished = false
    //                    gameLogic.resetGame()
                    }
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("RESUME")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                
                Button {
                    withAnimation {
                        playState = .Play
                        gameLogic.resetGame()
                        gameLogic.startGame()
                        score = 0
                    }
                } label: {
                    HStack {
                        Image(systemName: "repeat")
                        Text("RESET")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                
                Button {
                    withAnimation {
                        playState = .Menu
                        gameLogic.resetGame()
                    }
                } label: {
                    HStack {
                        Image(systemName: "house.fill")
                        Text("BACK TO HOME")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            }
        case .Finish:
            VStack {
                if score > highScore {
                    Text("NEW HIGH SCORE!")
                }
                
                Text("SCORE: \(score)")
                
                Button {
                    withAnimation {
                        playState = .Play
                        gameLogic.isMusicFinished = false
                        gameLogic.resetGame()
                        gameLogic.startGame()
                        score = 0
                    }
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("PLAY AGAIN")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                
                Button {
                    withAnimation {
                        playState = .Menu
                        gameLogic.resetGame()
                        score = 0
                    }
                } label: {
                    HStack {
                        Image(systemName: "house.fill")
                        Text("BACK TO HOME")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            }
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    var countdownCircleView: CountdownCircleView
    var gameLogic: GameLogic
    
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
    var gameLogic: GameLogic!
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
                    countdownCircleView.frame = view.bounds
                    countdownCircleView.backgroundColor = .clear
                    view.addSubview(countdownCircleView)
                    
                }
            }
        } catch let error {
            print("[CameraViewController][catch][error]", error.localizedDescription)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        countdownCircleView.displayLink?.invalidate()
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
                    print("[circleCenter]", circleCenter)
                    let circleRadius: CGFloat = 0.1 // Modify this based on your circle size
                    
                    // Check collision with left wrist
                    if let leftWristPoint = bodyPoints["leftWrist"] {
                        print("[leftWristPoint]", leftWristPoint)
                        print("[leftWristPoint][distanceBetweenPoints]", self.distanceBetweenPoints(leftWristPoint, circleCenter))
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
                        print("[rightWristPoint]", rightWristPoint)
                        print("[rightWristPoint][distanceBetweenPoints]", self.distanceBetweenPoints(rightWristPoint, circleCenter))
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
                        print("[leftAnklePoint]", leftAnklePoint)
                        print("[leftAnklePoint][distanceBetweenPoints]", self.distanceBetweenPoints(leftAnklePoint, circleCenter))
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
                        print("[rightAnklePoint]", rightAnklePoint)
                        print("[rightAnklePoint][distanceBetweenPoints]", self.distanceBetweenPoints(rightAnklePoint, circleCenter))
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

protocol CameraViewControllerDelegate : AnyObject {
    func cameraViewController(_ controller : CameraViewController)
    func cameraViewControllerDidCancel(_ controller : CameraViewController)
    func cameraViewController(_ controller : CameraViewController, didFailWithError error : Error)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
