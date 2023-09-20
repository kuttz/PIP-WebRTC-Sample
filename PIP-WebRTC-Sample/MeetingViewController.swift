//
//  MeetingViewController.swift
//  PIP-WebRTC-Sample
//
//  Created by Sreekuttan D on 10/09/23.
//

import UIKit
import Combine
import AVKit
import WebRTC

class MeetingViewController: UIViewController {
    
    unowned var connectionModel: ConnectionModel
    
    private var cancellableSet: Set<AnyCancellable> = []
    
    fileprivate let remoteRenderer: MTLVideoRendererView = {
        let renderer = MTLVideoRendererView()
        renderer.translatesAutoresizingMaskIntoConstraints = false
        renderer.videoContentMode = .scaleAspectFit
        return renderer
    }()
    
    fileprivate let localRenderer: MTLVideoRendererView = {
        let renderer = MTLVideoRendererView()
        renderer.translatesAutoresizingMaskIntoConstraints = false
        renderer.videoContentMode = .scaleAspectFit
        return renderer
    }()
    
    fileprivate var pipButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "pip.enter"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    fileprivate var micButton: UIBarButtonItem!
    fileprivate var speakerButton: UIBarButtonItem!
    
    fileprivate let sampleBufferView: SampleBufferView = SampleBufferView()
    
    fileprivate var pipViewController: AVPictureInPictureVideoCallViewController?
    
    fileprivate var pipController: AVPictureInPictureController?
    
    init(connectionModel: ConnectionModel) {
        self.connectionModel = connectionModel
        super.init(nibName: nil, bundle: nil)
        
        remoteRenderer.rendererDelegate = self
        
        self.view.addSubview(remoteRenderer)
        self.view.addSubview(localRenderer)
        self.view.addSubview(pipButton)
        
        pipButton.addTarget(self, action: #selector(pipButtonAction), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            remoteRenderer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            remoteRenderer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            remoteRenderer.topAnchor.constraint(equalTo: view.topAnchor),
            remoteRenderer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            localRenderer.widthAnchor.constraint(equalToConstant: 100),
            localRenderer.heightAnchor.constraint(equalToConstant: 100),
            localRenderer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            localRenderer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            pipButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            pipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            pipButton.heightAnchor.constraint(equalTo: pipButton.widthAnchor),
            pipButton.heightAnchor.constraint(equalToConstant: 42)
        ])

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        connectionModel.startCaptureLocalVideo()
        setupPip()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        connectionModel.stopCaptureLocalVideo()
    }
    
    deinit {
        print("did deinit ")
    }
        
    fileprivate func bindViewModel() {
        connectionModel.$localVideoTrack
            .sink { [weak self] track in
                guard let renderer = self?.localRenderer else {
                    return
                }
                track?.add(renderer)
            }
            .store(in: &cancellableSet)
        
        connectionModel.$remoteVideoTrack
            .sink { [weak self] track in
                guard let renderer = self?.remoteRenderer else {
                    return
                }
                track?.add(renderer)
            }
            .store(in: &cancellableSet)
        
        connectionModel.$mute
            .sink { [weak self] mute in
                let micImage = mute ? UIImage(systemName: "mic.slash.fill") : UIImage(systemName: "mic.fill")
                self?.micButton = UIBarButtonItem(image: micImage, style: .plain, target: self, action: #selector(self?.micAction))
                self?.navigationItem.rightBarButtonItems = [self?.micButton, self?.speakerButton].compactMap{ $0 }
            }
            .store(in: &cancellableSet)
        
        connectionModel.$speakerOn
            .sink { [weak self] speakerOn in
                let speakerImage = speakerOn ? UIImage(systemName: "speaker.wave.3.fill") : UIImage(systemName: "speaker.fill")
                self?.speakerButton = UIBarButtonItem(image: speakerImage, style: .plain, target: self, action: #selector(self?.speakerAction))
                self?.navigationItem.rightBarButtonItems = [self?.micButton, self?.speakerButton].compactMap{ $0 }
            }
            .store(in: &cancellableSet)
    }
    
    @objc fileprivate func micAction(){
        connectionModel.toggleAudioMute()
    }
    
    @objc fileprivate func speakerAction(){
        connectionModel.toggleSpeakerOn()
    }
    
    fileprivate func setupPip() {
        
        if !AVPictureInPictureController.isPictureInPictureSupported() {
            print("PIP not supported")
            pipButton.isHidden = true
            return
        }
        
        pipViewController = AVPictureInPictureVideoCallViewController()
        pipViewController?.preferredContentSize = CGSize(width: 1920, height: 1080)
        pipViewController?.view.addSubview(sampleBufferView)
                    
        sampleBufferView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                sampleBufferView.leadingAnchor.constraint(equalTo: pipViewController!.view.leadingAnchor),
                sampleBufferView.trailingAnchor.constraint(equalTo: pipViewController!.view.trailingAnchor),
                sampleBufferView.topAnchor.constraint(equalTo: pipViewController!.view.topAnchor),
                sampleBufferView.bottomAnchor.constraint(equalTo: pipViewController!.view.bottomAnchor)
            ])
        
        let pipContentSource = AVPictureInPictureController.ContentSource(
            activeVideoCallSourceView: view,
            contentViewController: pipViewController!
        )
        
        pipController = AVPictureInPictureController(contentSource: pipContentSource)
        pipController?.canStartPictureInPictureAutomaticallyFromInline = true
        pipController?.delegate = self
    }
    
    @objc fileprivate func pipButtonAction() {
        if pipController?.isPictureInPictureActive ?? true {
            pipController?.stopPictureInPicture()
        } else {
            pipController?.startPictureInPicture()
        }
    }

}

// MARK: - RendererDelegate
extension MeetingViewController: RendererDelegate {
    
    func render(id: String, buffer: CMSampleBuffer, withRotation rotation: RTCVideoRotation) {
        DispatchQueue.main.async {
            
            self.sampleBufferView.sampleBufferDisplayLayer.enqueue(buffer)
            
            var degrees = 90.0
            switch rotation {
            case ._90:
                degrees = 90.0
            case ._180:
                degrees = 180.0
            case ._270:
                degrees = 270.0
            default:
                degrees = 0.0
            }
            let radians = CGFloat(degrees * Double.pi / 180)
            self.sampleBufferView.sampleBufferDisplayLayer.transform = CATransform3DMakeRotation(radians, 0.0, 0.0, 1.0)
        }
    }
}

// MARK: - AVPictureInPictureControllerDelegate
extension MeetingViewController: AVPictureInPictureControllerDelegate {
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        pipButton.setImage(UIImage(systemName: "pip.exit"), for: .normal)
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        pipButton.setImage(UIImage(systemName: "pip.enter"), for: .normal)
    }
}
