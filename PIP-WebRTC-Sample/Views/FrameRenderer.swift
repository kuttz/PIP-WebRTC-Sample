//
//  FrameRenderer.swift
//  PIP-WebRTC-Sample
//
//  Created by Sreekuttan D on 10/09/23.
//

import Foundation
import UIKit
import WebRTC

protocol RendererDelegate: AnyObject {
    func render(id: String, buffer: CMSampleBuffer, withRotation rotation: RTCVideoRotation)
}

class EAGLVideoRendererView: RTCEAGLVideoView {
    
    var rendererId: String = ""
    
    weak var rendererDelegate: RendererDelegate?
    
    override func renderFrame(_ frame: RTCVideoFrame?) {
        super.renderFrame(frame)
        
        guard let frame,
              let cmSampleBuffer = frame.toCMSampleBuffer() else {
            return
        }
                
        rendererDelegate?.render(id: rendererId, buffer: cmSampleBuffer, withRotation: frame.rotation)
    }
    
}

class MTLVideoRendererView: RTCMTLVideoView {
    
    var rendererId: String = ""
    
    weak var rendererDelegate: RendererDelegate?
    
    override func renderFrame(_ frame: RTCVideoFrame?) {
        super.renderFrame(frame)
        
        guard let frame,
              let cmSampleBuffer = frame.toCMSampleBuffer() else {
            return
        }
                
        rendererDelegate?.render(id: rendererId, buffer: cmSampleBuffer, withRotation: frame.rotation)
    }
}

