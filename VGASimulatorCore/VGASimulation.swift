//
//  VGASimulatorCore.swift
//  VGASimulator
//
//  Created by Pedro José Pereira Vieito on 25/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import CoreGraphics
import VGASimulatorCore

public class VGASimulation {

    public enum SimulationError: LocalizedError {
        case contextNotAvailable
        case fileNotAvailable
        case simulationComplete

        public var errorDescription: String? {
            switch self {
            case .contextNotAvailable:
                return "Error creating Core Graphics context."
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

    private var lastHSync = false
    private var lastVSync = false

    private var frameCounter = 0
    private var lastFrame = false

    public let inputSimulation: URL
    public let mode: VGAMode

    public var resolution: VGAResolution {
        return mode.resolution
    }

    private var frameBuffer: [UInt32]
    let context: CGContext

    public init(url: URL, mode: VGAMode = VGAMode.vesa1280x1024_60) throws {
        self.inputSimulation = url
        self.mode = mode

        self.frameBuffer = [UInt32](repeating: 0, count: mode.resolution.width * mode.resolution.height)

        guard let context = CGContext(data: &frameBuffer, width: mode.resolution.width, height: mode.resolution.height, bitsPerComponent: 8, bytesPerRow: mode.resolution.width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
            throw SimulationError.contextNotAvailable
        }

        self.context = context

        guard VGAOpenFile(self.inputSimulation.path) >= 0 else {
            throw SimulationError.fileNotAvailable
        }
    }

    func nextFrameC() throws {

        guard !lastFrame else {
            throw SimulationError.simulationComplete
        }

        let result = VGAGetNextFrame(&frameBuffer)

        if result == 0 {
            lastFrame = true
        }
        else if result < 0 {
            throw SimulationError.simulationComplete
        }
    }

    func nextFrame() throws {

        guard !lastFrame else {
            throw SimulationError.simulationComplete
        }

        var frameComplete = false

        var hSync = false
        var vSync = false
        var red: UInt32 = 0
        var green: UInt32 = 0
        var blue: UInt32 = 0

        while VGAGetNextLineComponents(&hSync, &vSync, &red, &green, &blue) >= 0 {

            if !lastVSync && vSync {

                // Complete frame
                frameComplete = frameCounter > 0
                frameCounter += 1
                hCounter = 0
                vCounter = 0

                // Set this to zero so we can count up to the actual
                backPorchYCounter = 0
            }
            else if !lastHSync && hSync {

                // Complete row
                hCounter = 0

                // Move to the next row, if past back porch
                if backPorchYCounter >= self.mode.backPorchY {
                    vCounter += 1
                }

                // Increment this so we know how far we are after the vsync pulse
                backPorchYCounter += 1

                // Set this to zero so we can count up to the actual
                backPorchXCounter = 0
            }
            else if vSync && hSync {

                // Increment this so we know how far we are
                // After the hsync pulse
                backPorchXCounter += 1

                // If we are past the back porch
                // Then we can start drawing on the canvas
                if backPorchXCounter >= self.mode.backPorchX && backPorchYCounter >= self.mode.backPorchY {

                    // Add pixel
                    if hCounter < resolution.width && vCounter < resolution.height {
                        frameBuffer[resolution.width * vCounter + hCounter] = blue << 24 + green << 16 + red << 8
                    }

                    if backPorchXCounter >= self.mode.backPorchX {
                        hCounter += 1
                    }
                }
            }

            lastHSync = hSync
            lastVSync = vSync

            if frameComplete {
                return
            }
        }

        lastFrame = true

        self.inputSimulationHandle.closeFile()
    }
}

extension VGASimulation {

    public var framesC: AnyIterator<CGImage> {

        return AnyIterator<CGImage> {

            do {
                try self.nextFrameC()
                return self.context.makeImage()
            }
            catch {
                return nil
            }
        }
    }

    public var frames: AnyIterator<CGImage> {

        return AnyIterator<CGImage> {

            do {
                try self.nextFrame()
                return self.context.makeImage()
            }
            catch {
                return nil
            }
        }
    }
}
