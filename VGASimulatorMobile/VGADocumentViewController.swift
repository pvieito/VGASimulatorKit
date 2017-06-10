//
//  DocumentViewController.swift
//  VGASimulatorMobile
//
//  Created by Pedro José Pereira Vieito on 10/6/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import UIKit
import LoggerKit
import VGASimulatorKit

class VGADocumentViewController: UIViewController {
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var pageViewController: UIPageViewController!
    var document: VGADocument?
    var frameViewControllers: [VGAFrameViewController] = []
    
    override func viewDidLoad() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        pageViewController.view.frame = self.view.bounds
        
        self.pageViewController.didMove(toParentViewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Access the document
        guard let document = self.document else {
            return
        }
        
        document.delegate = self
        document.open(completionHandler: { (success) in
            
            guard success else {
                return
            }
            
            self.navigationItem.title = FileManager.default.displayName(atPath: document.fileURL.path)
        })
    }
    
    @IBAction func dismissDocumentViewController() {
        dismiss(animated: true) {
            self.document?.close(completionHandler: nil)
        }
    }
}

extension VGADocumentViewController: VGADocumentDelegate {
    
    func documentDidStartProcessing() {
        self.activityIndicatorView.startAnimating()
    }
    
    func document(_ document: VGADocument, didLoad frame: CGImage, at index: Int) {
        
        let frameViewController = VGAFrameViewController(frame: frame)
        self.frameViewControllers.append(frameViewController)
        
        if index == 0 {
            self.activityIndicatorView.stopAnimating()
            self.pageViewController.setViewControllers(frameViewControllers, direction: .forward, animated: true, completion: nil)
        }
        
        self.pageViewController.dataSource = nil
        self.pageViewController.dataSource = self
    }
    
    func documentDidEndProcessing() {
        self.activityIndicatorView.stopAnimating()
    }
}

extension VGADocumentViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
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
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
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

extension VGADocumentViewController: UIPageViewControllerDelegate {
    
}
