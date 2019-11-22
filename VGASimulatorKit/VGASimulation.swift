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
    private var canvasFrame: VGAFrame
    
    private let inputSimulation: URL
    private var simulationFile: UnsafeMutablePointer<FILE>?

    public let mode: VGAMode

    public var resolution: VGAResolution {
        return self.mode.resolution
    }

    public init(url: URL, mode: VGAMode = VGAMode.vesa1280x1024_60) throws {
        self.inputSimulation = url
        self.mode = mode
        self.canvasFrame = try VGAFrame(resolution: mode.resolution)
        
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
        guard !self.lastFrame else {
            throw SimulationError.simulationComplete
        }
        
        var frameComplete = false
        
        while VGAGetNextOutput(&self.simulationFile, &self.nextOutput) >= 0 {
            if !self.lastOutput.vSync && self.nextOutput.vSync {
                // Complete frame
                frameComplete = self.frameCounter > 0
                self.frameCounter += 1
                self.hCounter = 0
                self.vCounter = 0

                // Set this to zero so we can count up to the actual
                self.backPorchYCounter = 0
            }
            else if !self.lastOutput.hSync && self.nextOutput.hSync {
                // Complete row
                self.hCounter = 0

                // Move to the next row, if past back porch
                if self.backPorchYCounter >= self.mode.backPorchY {
                    self.vCounter += 1
                }

                // Increment this so we know how far we are after the vsync pulse
                self.backPorchYCounter += 1

                // Set this to zero so we can count up to the actual
                self.backPorchXCounter = 0
            }
            else if self.nextOutput.vSync && self.nextOutput.hSync {
                // Increment this so we know how far we are
                // After the hsync pulse
                self.backPorchXCounter += 1

                // If we are past the back porch
                // Then we can start drawing on the canvas
                if self.backPorchXCounter >= self.mode.backPorchX && self.backPorchYCounter >= self.mode.backPorchY {

                    // Add pixel
                    if self.hCounter < self.resolution.width && self.vCounter < self.resolution.height {
                        let pixelIndex = (self.resolution.width * self.vCounter + self.hCounter) * VGAFrame.channels

                        self.canvasFrame.pixelBuffer[pixelIndex] = self.nextOutput.red
                        self.canvasFrame.pixelBuffer[pixelIndex + 1] = self.nextOutput.green
                        self.canvasFrame.pixelBuffer[pixelIndex + 2] = self.nextOutput.blue
                    }

                    if self.backPorchXCounter >= self.mode.backPorchX {
                        self.hCounter += 1
                    }
                }
            }

            if frameComplete {
                return
            }
        }
        
        self.frameCounter += 1
        VGACloseFile(&self.simulationFile)
        self.lastFrame = true
    }
    
    public var frames: AnyIterator<VGAFrame> {
        return AnyIterator<VGAFrame> {
            do {
                try self.nextFrame()                
                return self.canvasFrame
            }
            catch {
                return nil
            }
        }
    }
}
