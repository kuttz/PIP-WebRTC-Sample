//
//  CVPixelBuffer+Extension.swift
//  PIP-WebRTC-Sample
//
//  Created by Sreekuttan D on 10/09/23.
//

import Foundation
import AVFoundation

extension CVPixelBuffer {
    
    func toCMSampleBuffer() -> CMSampleBuffer? {
        var sampleBuffer: CMSampleBuffer?
        let nowTime = CMTime(seconds: CACurrentMediaTime(), preferredTimescale: 60)
        let _1_60_s = CMTime(value: 1, timescale: 60) //CMTime(seconds: 1.0, preferredTimescale: 30)
        var timingInfo: CMSampleTimingInfo = CMSampleTimingInfo(duration: _1_60_s, presentationTimeStamp: nowTime, decodeTimeStamp: .invalid)
         
        var videoInfo: CMVideoFormatDescription?
         CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                      imageBuffer: self,
                                                      formatDescriptionOut: &videoInfo)
         CMSampleBufferCreateReadyWithImageBuffer(allocator: kCFAllocatorDefault,
                                                  imageBuffer: self,
                                                  formatDescription: videoInfo!,
                                                  sampleTiming: &timingInfo,
                                                  sampleBufferOut: &sampleBuffer)
        
         return sampleBuffer
    }
}

