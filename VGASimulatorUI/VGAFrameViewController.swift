//
//  VGAFrameViewController.swift
//  VGASimulatorUI
//
//  Created by Pedro José Pereira Vieito on 10/6/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import UIKit
import CoreGraphics

internal class VGAFrameViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    var frame: CGImage!
    
    override var nibBundle: Bundle? {
        return Bundle(for: VGAFrameViewController.self)
    }
    
    convenience init(frame: CGImage) {
        self.init()
        self.frame = frame
    }
    
    override func viewDidLoad() {
        self.imageView.image = UIImage(cgImage: frame)
    }
}
