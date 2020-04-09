//
//  VGASimulationTests.swift
//  VGASimulatorKitTests
//
//  Created by Pedro José Pereira Vieito on 08/04/2019.
//  Copyright © 2019 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import FoundationKit
import XCTest
@testable import VGASimulatorKit

class VGASimulationTests: XCTestCase {
    static let testBundle = Bundle.currentModuleBundle()
    static let testSimulationURL = testBundle.url(forResource: "TestSimulation", withExtension: "vga")!
    
    func testVGASimulation() throws {
        let simulation = try VGASimulation(url: VGASimulationTests.testSimulationURL)
        XCTAssertEqual(simulation.mode, VGAMode.vesa1280x1024_60)
        XCTAssertEqual(simulation.resolution.height, 1024)
        XCTAssertEqual(simulation.resolution.width, 1280)
        XCTAssertEqual(simulation.mode.refreshRate, 60)
        XCTAssertEqual(simulation.mode.pixelClockFrequency, 78643200.0)
        
        let frames = Array(simulation.frames)
        XCTAssertEqual(frames.count, 2)
        let frame0 = frames[0]
        let frame1 = frames[1]
        
        XCTAssertEqual(frame0.resolution, simulation.resolution)
        XCTAssertEqual(frame0.pixelBuffer[123], 255)
        XCTAssertEqual(frame0.pixelBuffer[5702], 0)
        XCTAssertEqual(frame0.pixelBuffer.map(Int.init).reduce(0, +), 334574880)
        XCTAssertEqual(frame0.pixelBuffer.count, 5242880)
        
        XCTAssertEqual(frame1.resolution, simulation.resolution)
        XCTAssertEqual(frame1.pixelBuffer[123], 255)
        XCTAssertEqual(frame1.pixelBuffer[571002], 0)
        XCTAssertEqual(frame1.pixelBuffer.map(Int.init).reduce(0, +), 334624080)
        XCTAssertEqual(frame1.pixelBuffer.count, 5242880)

        let frame0_URL = FileManager.default.temporaryRandomFileURL(pathExtension: "png")
        try frame0.write(to: frame0_URL)
        let frame1_URL = FileManager.default.temporaryRandomFileURL(pathExtension: "png")
        try frame1.write(to: frame1_URL)
    }
    
    func _testVGASimulationPerformance() throws {
        self.measure {
            let simulation = try! VGASimulation(url: VGASimulationTests.testSimulationURL)
            let frames = Array(simulation.frames)
            XCTAssertEqual(frames.count, 3)
        }
    }
}
