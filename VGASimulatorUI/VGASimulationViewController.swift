//
//  DocumentViewController.swift
//  VGASimulatorUI
//
//  Created by Pedro José Pereira Vieito on 10/6/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import UIKit
import VGASimulatorKit

open class VGASimulationViewController: UIViewController {
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    private var pageViewController: UIPageViewController!
    private var frameViewControllers: [VGAFrameViewController] = []
    
    private var document: VGADocument? {
        didSet {
            if self.isViewLoaded {
                document?.delegate = self
            }
        }
    }
    
    open override var nibName: String? {
        return "VGASimulationViewController"
    }
    
    open override var nibBundle: Bundle? {
        return Bundle(for: VGASimulationViewController.self)
    }

    open override func viewDidLoad() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self

        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        pageViewController.view.frame = self.view.bounds
        
        self.pageViewController.didMove(toParentViewController: self)
        
        self.document?.delegate = self
    }
    
    @available(iOSApplicationExtension, unavailable)
    public func loadSimulationAsDocument(at url: URL) {
        
        self.document = VGADocument(fileURL: url)
        self.document?.open(completionHandler: { (success) in
            
            guard success else {
                return
            }
            
            self.navigationItem.title = FileManager.default.displayName(atPath: url.path)
        })
    }
    
    public func loadSimulation(at url: URL, frameLimit: Int) throws {
        
        guard self.extensionContext != nil else {
            fatalError("Use loadSimulationAsDocument(at:) instead.")
        }
        
        self.document = VGADocument(fileURL: url)
        try self.document?.openVGADocument(at: url, frameLimit: frameLimit)
    }
    
    @IBAction func dismiss() {
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }
}

extension VGASimulationViewController: VGADocumentDelegate {
    
    public func documentDidStartProcessing() {
        self.activityIndicatorView.startAnimating()
    }
    
    public func document(_ document: VGADocument, didLoad frame: CGImage, at index: Int) {
        
        let frameViewController = VGAFrameViewController(frame: frame)
        self.frameViewControllers.append(frameViewController)
        
        if index == 0 {
            self.activityIndicatorView.stopAnimating()
            self.pageViewController.setViewControllers(frameViewControllers, direction: .forward, animated: true, completion: nil)
        }
        
        self.pageViewController.dataSource = nil
        self.pageViewController.dataSource = self
    }
    
    public func documentDidEndProcessing() {
        self.activityIndicatorView.stopAnimating()
    }
}

extension VGASimulationViewController: UIPageViewControllerDataSource {
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewController = viewController as? VGAFrameViewController else {
            return nil
        }
        
        guard let index = self.frameViewControllers.index(of: viewController) else {
            return nil
        }
        
        let newIndex = index - 1
        
        guard newIndex >= 0 && newIndex < self.frameViewControllers.count else {
            return nil
        }
        
        return self.frameViewControllers[index - 1]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewController = viewController as? VGAFrameViewController else {
            return nil
        }
        
        guard let index = self.frameViewControllers.index(of: viewController) else {
            return nil
        }
        
        let newIndex = index + 1
        
        guard newIndex >= 0 && newIndex < self.frameViewControllers.count else {
            return nil
        }
        
        return self.frameViewControllers[newIndex]
    }
}

extension VGASimulationViewController: UIPageViewControllerDelegate {
    
}
