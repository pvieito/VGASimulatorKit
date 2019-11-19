//
//  AppDelegate.swift
//  VGASimulatorMobile
//
//  Created by Pedro José Pereira Vieito on 10/6/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import UIKit
import LoggerKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let supportedContentTypes = ["com.pvieito.vgasimulation"]
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func application(_ app: UIApplication, open inputURL: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Reveal / import the document at the URL
        Logger.log(debug: "Open URL request: “\(inputURL.path)”")
        
        guard let documentBrowserViewController = window?.rootViewController as? VGABrowserViewController else { return false }

        documentBrowserViewController.revealDocument(at: inputURL, importIfNeeded: true) { (revealedDocumentURL, error) in
            var revealedDocumentURL = revealedDocumentURL
            
            if let error = error {
                // Handle the error appropriately
                Logger.log(error: "Failed to reveal the document at URL \(inputURL) with error. \(error)")
                return
            }
            
            // Present the Document View Controller for the revealed URL
            if revealedDocumentURL == nil {
                revealedDocumentURL = inputURL
            }
            
            documentBrowserViewController.presentDocument(at: revealedDocumentURL!)
        }

        return true
    }
}
