//
//  VGASimulator.swift
//  VGASimulator
//  Tool to view VGA output from a VHDL simulation.
//
//  Created by Pedro José Pereira Vieito on 17/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import FoundationKit
import LoggerKit
import CoreGraphicsKit
import VGASimulatorKit
import ArgumentParser

@main
struct VGASimulator: ParsableCommand {
    static var configuration: CommandConfiguration {
        return CommandConfiguration(commandName: String(describing: Self.self))
    }
    
    @Option(name: .shortAndLong, help: "Input simulation.")
    var input: String
    
    @Option(name: .shortAndLong, help: "Output directory.")
    var output: String?

    @Option(name: .shortAndLong, help: "Number of frames to process.")
    var frameLimit: Int?

    @Flag(name: .long, inversion: .prefixedNo, help: "Render and show frames.")
    var render: Bool = false

    @Flag(name: .shortAndLong, help: "Verbose mode.")
    var verbose: Bool = false

    @Flag(name: .shortAndLong, help: "Debug mode.")
    var debug: Bool = false

    func run() throws {
        do {
            Logger.logMode = .commandLine
            Logger.logLevel = self.verbose ? .verbose : .info
            Logger.logLevel = self.debug ? .debug : Logger.logLevel

            let inputURL = self.input.pathURL
            let simulation = try VGASimulation(url: inputURL)
            let simulationName = inputURL.deletingPathExtension().lastPathComponent
            
            Logger.log(important: "VGA Simulation Input: \(inputURL.lastPathComponent)")
            Logger.log(info: "VGA Mode: \(simulation.mode)")
            
            for (frameCount, frame) in simulation.frames.enumerated() {
                if let frameLimit = self.frameLimit, frameLimit <= frameCount {
                    break
                }
                
                Logger.log(success: "Frame \(frameCount) decoded")
                
                guard self.render else {
                    continue
                }
                
                do {
                    let outputDirectoryPath = output ?? FileManager.default.autocleanedTemporaryDirectory.path
                    let outputDirectoryURL = URL(fileURLWithPath: outputDirectoryPath)
                    
                    let outputURL = outputDirectoryURL
                        .appendingPathComponent("\(simulationName)_\(frameCount)")
                        .appendingPathExtension("png")
                    
                    Logger.log(debug: "Writing rendered image for frame \(frameCount) at “\(outputURL.path)”...")
                    
                    try frame.write(to: outputURL)

                    if self.output == nil {
                        try outputURL.open()
                    }
                }
                catch {
                    Logger.log(error: error)
                }
            }
        }
        catch {
            Logger.log(fatalError: error)
        }
    }
}

