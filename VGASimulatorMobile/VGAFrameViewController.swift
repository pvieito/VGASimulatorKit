//
//  VGAFrameViewController.swift
//  VGASimulatorMobile
//
//  Created by Pedro José Pereira Vieito on 10/6/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import UIKit
import CoreGraphics
import LoggerKit

class VGAFrameViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var frame: CGImage?
    
    convenience init(frame: CGImage) {
        self.init()
        
        self.frame = frame
    }
    
    override func viewDidLoad() {
        
        guard let frame = self.frame else {
            Logger.log(warning: "VGAFrameViewController loaded without frame property set.")
            return
        }
        
        self.imageView.image = UIImage(cgImage: frame)
    }
}
