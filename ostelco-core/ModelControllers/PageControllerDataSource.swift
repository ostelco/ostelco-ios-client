//
//  PageControllerDataSource.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 4/26/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

public protocol PageControllerDataSourceDelegate: class {
    
    /// Called when the current page has changed to a given index.
    ///
    /// - Parameter index: The updated index of the page.
    func pageChanged(to index: Int)
}

/// A data source to allow navigating back and forth with some dots between a bunch of view controllers.
open class PageControllerDataSource: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    let viewControllers: [UIViewController]
    private(set) weak var pageController: UIPageViewController?
    private(set) weak var delegate: PageControllerDataSourceDelegate?
    
    /// The index of the currently showing view controller
    open var currentIndex: Int {
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
    ///   - pageIndicatorTintColor: The tint color for unselected pages. Defaults to `UIColor.lightGray`.
    ///   - currentPageIndicatorTintColor: The tint color for selected pages. Defaults to `UIColor.black`.
    ///   - delegate: The delegate to notify of relevant changes.
    public init(pageController: UIPageViewController,
                viewControllers: [UIViewController],
                pageIndicatorTintColor: UIColor = .lightGray,
                currentPageIndicatorTintColor: UIColor = .black,
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
        
        let appearance = UIPageControl.appearance(whenContainedInInstancesOf: [UIPageViewController.self])
        appearance.pageIndicatorTintColor = pageIndicatorTintColor
        appearance.currentPageIndicatorTintColor = currentPageIndicatorTintColor
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
    
    /// Navigates to the next view controller, if it exists. No-ops if it doesn't.
    ///
    /// - Parameter animated: Should this navigation be animated? Defaults to true.
    open func goToNextPage(animated: Bool = true) {
        let nextIndex = self.currentIndex + 1
        guard let nextVC = self.viewController(at: nextIndex) else {
            // There is no next VC
            return
        }
        
        self.goToPage(nextVC,
                      direction: .forward,
                      animated: animated)
    }
    
    /// Navigates to the previous view controller, if it exists. No-ops if it doesn't.
    ///
    /// - Parameter animated: Should this navigation be animated? Defaults to true.
    open func goToPreviousPage(animated: Bool = true) {
        let previousIndex = self.currentIndex - 1
        guard let previousVC = self.viewController(at: previousIndex) else {
            // there is no previous VC
            return
        }
        
        self.goToPage(previousVC,
                      direction: .reverse,
                      animated: animated)
    }
    
    private func goToPage(_ viewController: UIViewController,
                          direction: UIPageViewController.NavigationDirection,
                          animated: Bool) {
        self.pageController?.setViewControllers(
            [viewController],
            direction: direction,
            animated: animated,
            completion: { _ in
                self.delegate?.pageChanged(to: self.currentIndex)
        })
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    open func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.viewControllers.count
    }
    
    open func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return self.currentIndex
    }
    
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = self.indexOf(viewController: viewController)
        let targetIndex = index - 1
        return self.viewController(at: targetIndex)
    }
    
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = self.indexOf(viewController: viewController)
        let targetIndex = index + 1
        return self.viewController(at: targetIndex)
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    open func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            self.delegate?.pageChanged(to: self.currentIndex)
        }
    }
}
