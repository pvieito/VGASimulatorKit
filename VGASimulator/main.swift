//
//  main.swift
//  VGASimulator
//  Tool to view VGA output from a VHDL simulation.
//
//  Created by Pedro José Pereira Vieito on 17/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Cocoa
import LoggerKit
import CoreGraphics
import CoreGraphicsKit
import CommandLineKit
import VGASimulatorCore


let inputOption = StringOption(shortFlag: "i", longFlag: "input", required: true, helpMessage: "Input simulation.")
let cOption = BoolOption(shortFlag: "c", longFlag: "cmode", helpMessage: "Use C simulation mode.")
let verboseOption = BoolOption(shortFlag: "v", longFlag: "verbose", helpMessage: "Verbose Mode.")
let helpOption = BoolOption(shortFlag: "h", longFlag: "help", helpMessage: "Prints a help message.")

let cli = CommandLineKit.CommandLine()
cli.addOptions(inputOption, verboseOption, helpOption)

do {
    try cli.parse()
}
catch {
    cli.printUsage(error)
    exit(-1)
}

if helpOption.value {
    cli.printUsage()
    exit(0)
}

Logger.logMode = .commandLine
Logger.logLevel = verboseOption.value ? .debug : .info

guard let inputPath = inputOption.value else {
    Logger.log(error: "No input simulation specified.")
    exit(-1)
}

do {
    let inputURL = URL(fileURLWithPath: inputPath)

    let simulation = try VGASimulation(url: inputURL)

    Logger.log(important: "VGA Simulation Input: \(inputURL.lastPathComponent)")
    Logger.log(info: "VGA Mode: \(simulation.mode)")

    let frames = cOption.value ? simulation.framesC : simulation.frames

    for (frameCount, frame) in frames.enumerated() {

        Logger.log(info: "Frame \(frameCount) decoded")

        do {
            let imageFile = try frame.temporaryFile(format: .png)
            NSWorkspace.shared().open(imageFile)
        }
        catch {
            Logger.log(error: error)
        }
    }

    Logger.log(success: "VGA Simulation complete")
}
catch {
    Logger.log(error: error)
}
