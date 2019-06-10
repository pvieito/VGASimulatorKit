//
//  DocumentBrowserViewController.swift
//  VGASimulatorMobile
//
//  Created by Pedro José Pereira Vieito on 10/6/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import UIKit
import LoggerKit
import VGASimulatorUI

class VGABrowserViewController: UIDocumentBrowserViewController {
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

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
        Logger.log(debug: "Presenting document at “\(documentURL)”...")
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let navigationViewController = storyBoard.instantiateViewController(withIdentifier: "VGANavigationViewController") as! UINavigationController
        let simulationViewController = navigationViewController.children.first as! VGASimulationViewController
        simulationViewController.loadSimulationAsDocument(at: documentURL)
        
        self.presentedViewController?.dismiss(animated: true, completion: nil)        
        present(navigationViewController, animated: true, completion: nil)
    }
}

extension VGABrowserViewController: UIDocumentBrowserViewControllerDelegate {
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        Logger.log(debug: "Document browser did pick documents at: \(documentURLs)")
        guard let sourceURL = documentURLs.first else { return }
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        Logger.log(debug: "Document browser did import document at: \(destinationURL)")
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
        if let error = error {
            Logger.log(error: error)
        }
    }
}
