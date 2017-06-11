//
//  VGADocumentDelegate.swift
//  VGASimulatorMobile
//
//  Created by Pedro José Pereira Vieito on 10/6/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import CoreGraphics

protocol VGADocumentDelegate: class {
    func documentDidStartProcessing()
    func document(_ document: VGADocument, didLoad frame: CGImage, at index: Int)
    func documentDidEndProcessing()
}
