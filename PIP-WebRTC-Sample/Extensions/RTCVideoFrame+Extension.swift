//
//  RTCVideoFrame+Extension.swift
//  PIP-WebRTC-Sample
//
//  Created by Sreekuttan D on 10/09/23.
//

import Foundation
import WebRTC

extension RTCVideoFrame {
    
    func toCMSampleBuffer() -> CMSampleBuffer? {
        guard let pixelBuffer = buffer as? RTCCVPixelBuffer else {
            return nil
        }

        return pixelBuffer.pixelBuffer.toCMSampleBuffer()
    }
}
