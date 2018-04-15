//
//  VGASimulation.swift
//  VGASimulator
//
//  Created by Pedro José Pereira Vieito on 25/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import VGASimulatorCore

public class VGASimulation {

    public enum SimulationError: LocalizedError {
        case fileNotAvailable
        case simulationComplete

        public var errorDescription: String? {
            switch self {
            case .fileNotAvailable:
                return "Error opening the file."
            case .simulationComplete:
                return "No more frames in the simulation."
            }
        }
    }

    private var backPorchXCounter = 0
    private var backPorchYCounter = 0

    private var hCounter = 0
    private var vCounter = 0

    private var lastOutput = VGAOutput()
    private var nextOutput = VGAOutput() {
        willSet {
            self.lastOutput = self.nextOutput
        }
    }

    private var frameCounter = 0
    private var lastFrame = false

    public let inputSimulation: URL
    public let mode: VGAMode

    public var resolution: VGAResolution {
        return currentFrame.resolution
    }
    
    public var channels: Int {
        return currentFrame.channels
    }

    private var currentFrame: VGAFrame
    private var simulationFile: UnsafeMutablePointer<FILE>?

    public init(url: URL, mode: VGAMode = VGAMode.vesa1280x1024_60) throws {

        self.inputSimulation = url
        self.mode = mode
        self.currentFrame = try VGAFrame(resolution: mode.resolution)
        
        guard let filePointer = VGAOpenFile(self.inputSimulation.path) else {
            throw SimulationError.fileNotAvailable
        }
        
        self.simulationFile = filePointer
    }
    
    deinit {
        VGACloseFile(&self.simulationFile)
    }
}

extension VGASimulation {

    func nextFrame() throws {
        
        guard !lastFrame else {
            throw SimulationError.simulationComplete
        }
        
        var frameComplete = false
        
        while VGAGetNextOutput(&self.simulationFile, &nextOutput) >= 0 {
                        
            if !lastOutput.vSync && nextOutput.vSync {

                // Complete frame
                frameComplete = frameCounter > 0
                frameCounter += 1
                hCounter = 0
                vCounter = 0

                // Set this to zero so we can count up to the actual
                backPorchYCounter = 0
            }
            else if !lastOutput.hSync && nextOutput.hSync {

                // Complete row
                hCounter = 0

                // Move to the next row, if past back porch
                if backPorchYCounter >= mode.backPorchY {
                    vCounter += 1
                }

                // Increment this so we know how far we are after the vsync pulse
                backPorchYCounter += 1

                // Set this to zero so we can count up to the actual
                backPorchXCounter = 0
            }
            else if nextOutput.vSync && nextOutput.hSync {

                // Increment this so we know how far we are
                // After the hsync pulse
                backPorchXCounter += 1

                // If we are past the back porch
                // Then we can start drawing on the canvas
                if backPorchXCounter >= mode.backPorchX && backPorchYCounter >= mode.backPorchY {

                    // Add pixel
                    if hCounter < resolution.width && vCounter < resolution.height {
                        let pixelIndex = (resolution.width * vCounter + hCounter) * channels

                        self.currentFrame.pixelBuffer[pixelIndex] = nextOutput.red
                        self.currentFrame.pixelBuffer[pixelIndex + 1] = nextOutput.green
                        self.currentFrame.pixelBuffer[pixelIndex + 2] = nextOutput.blue
                    }

                    if backPorchXCounter >= mode.backPorchX {
                        hCounter += 1
                    }
                }
            }

            if frameComplete {
                return
            }
        }
        
        frameCounter += 1
        
        VGACloseFile(&self.simulationFile)
        
        lastFrame = true
    }
    
    public var frames: AnyIterator<VGAFrame> {
        
        return AnyIterator<VGAFrame> {
            
            do {
                try self.nextFrame()                
                return self.currentFrame
            }
            catch {
                return nil
            }
        }
    }
}
