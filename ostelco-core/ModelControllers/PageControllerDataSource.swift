//
//  PageControllerDataSource.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 4/26/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

public protocol PageControllerDataSourceDelegate: class {
    func pageChanged(to index: Int)
}

public class PageControllerDataSource: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private let viewControllers: [UIViewController]
    private weak var pageController: UIPageViewController?
    private weak var delegate: PageControllerDataSourceDelegate?
    
    /// The index of the currently showing view controller
    public var currentIndex: Int {
        guard let currentVC = self.pageController?.viewControllers?.first else {
            return -1
        }
        return self.indexOf(viewController: currentVC)
    }
    
    /// Designated initializer
    ///
    /// - Parameters:
    ///   - pageController: The UIPageViewController you're using to display your vc's
    ///   - viewControllers: The actual VCs you wish to display
    ///   - delegate: The delegate to notify of relevant changes.
    public init(pageController: UIPageViewController,
                viewControllers: [UIViewController],
                delegate: PageControllerDataSourceDelegate) {
        self.pageController = pageController
        self.viewControllers = viewControllers
        self.delegate = delegate
        
        super.init()
        
        pageController.delegate = self
        pageController.dataSource = self
        
        if let firstVC = viewControllers.first {
            pageController.setViewControllers([firstVC], direction: .forward, animated: false)
        }
    }
    
    private func indexOf(viewController: UIViewController) -> Int {
        guard let currentIndex = self.viewControllers.firstIndex(of: viewController) else {
            fatalError("Trying to find a view controller ")
        }
        
        return currentIndex
    }
    
    private func viewController(at targetIndex: Int) -> UIViewController? {
        guard self.viewControllers.indices.contains(targetIndex) else {
            return nil
        }
        
        return self.viewControllers[targetIndex]
    }
    
    public func goToNextPage(animated: Bool = true) {
        let nextIndex = self.currentIndex + 1
        guard let nextVC = self.viewController(at: nextIndex) else {
            // There is no next VC
            return
        }
        
        self.pageController?.setViewControllers([nextVC], direction: .forward, animated: true)
    }
    
    public func goToPreviousPage(animated: Bool = true) {
        let previousIndex = self.currentIndex - 1
        guard let previousVC = self.viewController(at: previousIndex) else {
            // there is no previous VC
            return
        }
        
        self.pageController?.setViewControllers([previousVC], direction: .reverse, animated: animated)
        
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.viewControllers.count
    }
    
    public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return self.currentIndex
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = self.indexOf(viewController: viewController)
        let targetIndex = index - 1
        return self.viewController(at: targetIndex)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = self.indexOf(viewController: viewController)
        let targetIndex = index + 1
        return self.viewController(at: targetIndex)
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            self.delegate?.pageChanged(to: self.currentIndex)
        }
    }
}
