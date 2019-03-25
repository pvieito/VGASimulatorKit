//
//  DocumentBrowserViewController.swift
//  VGASimulatorMobile
//
//  Created by Pedro José Pereira Vieito on 10/6/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import UIKit
import VGASimulatorUI

class VGABrowserViewController: UIDocumentBrowserViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        self.allowsDocumentCreation = false
        self.allowsPickingMultipleItems = false
                
        // Update the style of the UIDocumentBrowserViewController
        self.browserUserInterfaceStyle = .dark
        self.view.tintColor = .orange
    }
    
    func presentDocument(at documentURL: URL) {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let navigationViewController = storyBoard.instantiateViewController(withIdentifier: "VGANavigationViewController") as! UINavigationController
        let simulationViewController = navigationViewController.children.first as! VGASimulationViewController
        simulationViewController.loadSimulationAsDocument(at: documentURL)
        
        present(navigationViewController, animated: true, completion: nil)
    }
}

extension VGABrowserViewController: UIDocumentBrowserViewControllerDelegate {
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
}
