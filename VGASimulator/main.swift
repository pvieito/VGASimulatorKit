//
//  main.swift
//  VGASimulator
//  Tool to view VGA output from a VHDL simulation.
//
//  Created by Pedro José Pereira Vieito on 17/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import FoundationKit
import LoggerKit
import CommandLineKit
import CoreGraphicsKit
import VGASimulatorKit

let inputOption = StringOption(shortFlag: "i", longFlag: "input", required: true, helpMessage: "Input simulation.")
let outputOption = StringOption(shortFlag: "o", longFlag: "output", helpMessage: "Output directory.")
let framesOption = IntOption(shortFlag: "f", longFlag: "frames", helpMessage: "Number of frames.")
let noRenderOption = BoolOption(longFlag: "norender", helpMessage: "Disable rendering of frames.")
let verboseOption = BoolOption(shortFlag: "v", longFlag: "verbose", helpMessage: "Verbose mode.")
let debugOption = BoolOption(shortFlag: "d", longFlag: "debug", helpMessage: "Debug mode.")
let helpOption = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Prints a help message.")

let cli = CommandLineKit.CommandLine()
cli.addOptions(inputOption, outputOption, framesOption, noRenderOption, verboseOption, debugOption, helpOption)

do {
    try cli.parse(strict: true)
}
catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

if helpOption.value {
    cli.printUsage()
    exit(0)
}

Logger.logMode = .commandLine
Logger.logLevel = verboseOption.value ? .verbose : .info
Logger.logLevel = debugOption.value ? .debug : Logger.logLevel

guard let inputPath = inputOption.value else {
    Logger.log(fatalError: "No input simulation specified.")
}

do {
    let inputURL = URL(fileURLWithPath: inputPath)
    let simulation = try VGASimulation(url: inputURL)
    let simulationName = inputURL.deletingPathExtension().lastPathComponent
    
    Logger.log(important: "VGA Simulation Input: \(inputURL.lastPathComponent)")
    Logger.log(info: "VGA Mode: \(simulation.mode)")
    
    for (frameCount, frame) in simulation.frames.enumerated() {
        if let frameLimit = framesOption.value, frameLimit <= frameCount {
            break
        }
        
        Logger.log(success: "Frame \(frameCount) decoded")
        
        guard !noRenderOption.value else {
            continue
        }
        
        #if canImport(CoreGraphics)
        do {
            let outputDirectoryPath = outputOption.value ?? FileManager.default.autocleanedTemporaryDirectory.path
            let outputDirectoryURL = URL(fileURLWithPath: outputDirectoryPath)
            
            let outputURL = outputDirectoryURL
                .appendingPathComponent("\(simulationName)_\(frameCount)")
                .appendingPathExtension("png")
            
            Logger.log(debug: "Writing rendered image for frame \(frameCount) at “\(outputURL.path)”...")
            
            try frame.cgImage().write(to: outputURL, format: .png)

            if outputOption.value == nil {
                try outputURL.open()
            }
        }
        catch {
            Logger.log(error: error)
        }
        #endif
    }
}
catch {
    Logger.log(fatalError: error)
}
