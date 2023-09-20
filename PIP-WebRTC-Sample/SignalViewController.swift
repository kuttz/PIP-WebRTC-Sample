//
//  SignalViewController.swift
//  PIP-WebRTC-Sample
//
//  Created by Sreekuttan D on 10/09/23.
//

import UIKit
import Combine

class SignalViewController: UIViewController {
    
    fileprivate var connectionModel: ConnectionModel
    
    private var cancellableSet: Set<AnyCancellable> = []
    
    fileprivate let signalLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    fileprivate let statusLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    fileprivate var offerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send Offer", for: .normal)
        button.setTitleColor(.tintColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    fileprivate var answerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send Answer", for: .normal)
        button.setTitleColor(.tintColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    fileprivate var meetingButton: UIButton = {
        let button = UIButton()
        button.setTitle("Go to Meeting", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .tintColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()
    
    init(connectionModel: ConnectionModel) {
        self.connectionModel = connectionModel
        super.init(nibName: nil, bundle: nil)
        
        let stack = UIStackView(arrangedSubviews: [signalLabel, statusLabel, offerButton, answerButton, meetingButton])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(stack)
        self.view.backgroundColor = .systemBackground
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        offerButton.addTarget(self, action: #selector(sendOffer), for: .touchUpInside)
        answerButton.addTarget(self, action: #selector(sendAnswer), for: .touchUpInside)
        meetingButton.addTarget(self, action: #selector(startMeeting), for: .touchUpInside)
        
        bindViewModel()
        connectionModel.connect()
        
    }
    
    fileprivate func updateSignaling(connected: Bool) {
        let status = connected ? "Connected ✅" : "Not connected ❌"
        signalLabel.text = "Signaling status: " + status
    }
    
    fileprivate func updateStatics() {
                
        let localSDP = connectionModel.hasLocalSdp ? "✅" : "❌"
        let localCandidate = connectionModel.localCandidateCount
        let remoteSDP = connectionModel.hasRemoteSdp ? "✅" : "❌"
        let remoteCandidate = connectionModel.remoteCandidateCount
        let rtcStatus = connectionModel.connectionState.description.capitalized
        let statusText = ["Local SDP: " + localSDP,
                          "Local Candidates: " + String(localCandidate),
                          "Remote SDP: " + remoteSDP,
                          "Local Candidates: " + String(remoteCandidate),
                          "WebRTC Status: " + rtcStatus].joined(separator: "\n\n")
        statusLabel.text = statusText
    }
    
    fileprivate func bindViewModel() {
        connectionModel.$signalingConnected
            .sink { [weak self] connected in
                self?.updateSignaling(connected: connected)
            }
            .store(in: &cancellableSet)
        
        connectionModel.$hasLocalSdp
            .sink { [weak self] _ in self?.updateStatics() }
            .store(in: &cancellableSet)
        
        connectionModel.$localCandidateCount
            .sink { [weak self] _ in self?.updateStatics() }
            .store(in: &cancellableSet)
        
        connectionModel.$hasRemoteSdp
            .sink { [weak self] _ in self?.updateStatics() }
            .store(in: &cancellableSet)
        
        connectionModel.$remoteCandidateCount
            .sink { [weak self] _ in self?.updateStatics() }
            .store(in: &cancellableSet)
        
        connectionModel.$connectionState
            .sink { [weak self] state in
                print("WebRTC State : ", state)
                self?.meetingButton.isEnabled = (state == .connected)
                self?.meetingButton.alpha = (state == .connected) ? 1.0 : 0.5
                self?.updateStatics()
                
            }
            .store(in: &cancellableSet)
    }
    
    @objc fileprivate func sendOffer() {
        connectionModel.sendOffer()
    }

    @objc fileprivate func sendAnswer() {
        connectionModel.sendAnswer()
    }
    
    @objc fileprivate func startMeeting() {
        let meetingVC = MeetingViewController(connectionModel: connectionModel)
        navigationController?.pushViewController(meetingVC, animated: true)
    }

}
