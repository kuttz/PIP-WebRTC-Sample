//
//  SampleBufferView.swift
//  PIP-WebRTC-Sample
//
//  Created by Sreekuttan D on 10/09/23.
//

import UIKit
import AVFoundation

class SampleBufferView: UIView {

    override class var layerClass: AnyClass {
        get { return AVSampleBufferDisplayLayer.self }
    }
    
    var sampleBufferDisplayLayer: AVSampleBufferDisplayLayer {
        return layer as! AVSampleBufferDisplayLayer
    }

}
