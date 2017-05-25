//
//  VGASimulatorCore.swift
//  VGASimulator
//
//  Created by Pedro José Pereira Vieito on 24/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

let backPorchX = 318
let backPorchY = 38

var backPorchXCounter = 0
var backPorchYCounter = 0

var hCounter = 0
var vCounter = 0

var lastHSync = false
var lastVSync = false

var frameCounter = 0

do {
    let inputString = try String(contentsOf: inputURL)

    inputString.enumerateLines(invoking: { (line, _) in

        let lineComponents = line.components(separatedBy: " ")

        let hSync = lineComponents[2] == "1"
        let vSync = lineComponents[3] == "1"
        let red = (UInt32(lineComponents[4], radix: 2) ?? 0) << 4
        let green = (UInt32(lineComponents[5], radix: 2) ?? 0) << 4
        let blue = (UInt32(lineComponents[6], radix: 2) ?? 0) << 4

        if !lastHSync && hSync {
            //Logger.log(debug: "Drawing horizontal line \(vCounter)...")

            hCounter = 0

            // Move to the next row, if past back porch
            if backPorchYCounter >= backPorchY {
                vCounter += 1
            }

            // Increment this so we know how far we are after the vsync pulse
            backPorchYCounter += 1

            // Set this to zero so we can count up to the actual
            backPorchXCounter = 0
        }

        if !lastVSync && vSync {

            if frameCounter > 0 {
                do {
                    Logger.log(success: "Frame \(frameCounter) decoded")
                    Logger.log(info: frameBuffer[325120])
                    let imageFile = try context.temporaryImageFile(format: .png)
                    NSWorkspace.shared().open(imageFile)
                }
                catch {
                    Logger.log(error: error)
                }
            }

            frameCounter += 1
            hCounter = 0
            vCounter = 0

            //Logger.log(debug: "Decoding frame \(frameCounter)...")

            // Set this to zero so we can count up to the actual
            backPorchYCounter = 0
        }

        if vSync && hSync {
            // Increment this so we know how far we are
            // After the hsync pulse
            backPorchXCounter += 1

            // If we are past the back porch
            // Then we can start drawing on the canvas
            if backPorchXCounter >= backPorchX && backPorchYCounter >= backPorchY {

                // Add pixel
                if hCounter < resolution.width && vCounter < resolution.height {
                    frameBuffer[resolution.width * vCounter + hCounter] = blue << 24 + green << 16 + red << 8
                }

                if backPorchXCounter >= backPorchX {
                    hCounter += 1
                }
            }
        }

        lastHSync = hSync
        lastVSync = vSync
    })
}
catch {
    Logger.log(error: error)
}
