//
//  Document.swift
//  VGASimulator
//
//  Created by Pedro José Pereira Vieito on 6/6/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Cocoa
import FoundationKit
import VGASimulatorKit

class VGADocument: NSDocument {

    var vgaSimulation: VGASimulation?

    var documentViewController: VGAViewController? {
        return self.windowControllers.first?.contentViewController as? VGAViewController
    }

    enum InputError: LocalizedError {
        case typeError

        var errorDescription: String? {
            switch self {
            case .typeError:
                return "File not supported."
            }
        }
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("VGADocumentWindowController")) as! NSWindowController
        self.addWindowController(windowController)

        self.documentViewController?.representedObject = vgaSimulation
    }

    override func read(from url: URL, ofType typeName: String) throws {

        switch typeName {
        case "com.pvieito.vgasimulation":
            do {
                self.vgaSimulation = try VGASimulation(url: url)
            }
            catch {
                throw error.cocoaError
            }
        default:
            throw InputError.typeError.cocoaError
        }
    }
}

