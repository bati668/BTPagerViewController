//
//  BTPagerViewController.swift
//  BTPagerViewController
//
//  Created by Hiroshi Chiba on 2016/04/12.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Foundation
import UIKit

import UIKit
import Foundation

extension Array {
    func indexOfObject<T: Equatable>(obj: T) -> Int? {
        if self.count > 0 {
            for (i, objectToCompare) in enumerate().self {
                let to = objectToCompare as! T
                if obj == to {
                    return i
                }
            }
        }
        return nil
    }
}

let NKJPagerViewControllerTabViewTag: Int = 1800
let NKJPagerViewControllerContentViewTag: Int = 2400

let kTabsViewBackgroundColor = UIColor(colorLiteralRed: 234.0 / 255.0, green: 234.0 / 255.0, blue: 234.0 / 255.0, alpha: 0.75)
let kContentViewBackgroundColor = UIColor(colorLiteralRed: 248.0 / 255.0, green: 248.0 / 255.0, blue: 248.0 / 255.0, alpha: 0.75)

public protocol BTPagerViewControllerDataSource {
    func numberOfTabView() ->Int
    func widthOfTabViewWithIndex(index: Int) ->CGFloat
    func viewForTabAtIndex(viewPager: BTPagerViewController, tabIndex: Int) ->UIView
    func contentViewControllerForTabAtIndex(viewPager: BTPagerViewController, index: Int) ->UIViewController
}

@objc public protocol BTPagerViewControllerDelegate : NSObjectProtocol{
    optional func viewPagerDidTapMenuTabAtIndex(viewPager: BTPagerViewController, index: Int)
    optional func viewPagerWillTransition(viewPager: BTPagerViewController)
    optional func viewPagerWillSwitchAtIndex(viewPager: BTPagerViewController, index: Int, tabs: Array<AnyObject>)
    optional func viewPagerdidSwitchAtIndex(viewPager: BTPagerViewController, index: Int, tabs: Array<AnyObject>)
    optional func viewPagerDidAddContentView()
}

public class BTPagerViewController: UIViewController,UIPageViewControllerDataSource,UIPageViewControllerDelegate,UIScrollViewDelegate
{
    // ================================================================================
    // MARK: - private property
    //private defaultValue
    private var leftTabIndex: Int? = 2
    private var tabCount: Int?
    private var pageViewController: UIPageViewController?
    
    // ================================================================================
    // MARK: - public property
    public var heightOfTabView: CGFloat?
    public var yPositionOfTabView: CGFloat?
    public var tabsViewBackgroundColor: UIColor?
    public var infiniteSwipe: Bool?
    public var activeContentIndex: Int? = 0
    
    public var tabs: Array<UIView>? //views
    public var contents: Array<UIViewController>? // ViewControllers
    public var tabsView: UIScrollView?
    public var contentView: UIView?
    
    public var delegate: BTPagerViewControllerDelegate?
    public var dataSource: BTPagerViewControllerDataSource?
    
    // ================================================================================
    // MARK: - public setting Medhod
    
    // ================================================================================
    // MARK: -init
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.defaultSettings()
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.defaultSettings()
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    // ================================================================================
    // MARK: - default setting
    
    func defaultSettings() {
        pageViewController = UIPageViewController.init(transitionStyle: UIPageViewControllerTransitionStyle.Scroll,
                                                       navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal,
                                                       options: nil)
        self.addChildViewController(pageViewController!)
        
        let scrollView: UIScrollView = pageViewController!.view.subviews[0] as!UIScrollView
        scrollView.delegate = self
        
        self.pageViewController!.dataSource = self;
        self.pageViewController!.delegate = self;
        self.heightOfTabView = 44
        self.yPositionOfTabView = 64
        self.tabsViewBackgroundColor = kTabsViewBackgroundColor
        self.infiniteSwipe = true
    }
    
    func defaultSetUp() {
        // Empty tabs and contents
        if self.tabsView != nil {
            for tabView: UIView? in self.tabs! {
                tabView?.removeFromSuperview()
            }
            self.tabsView!.contentSize = CGSizeZero
            
            self.tabs?.removeAll()
            self.contents?.removeAll()
        }
        
        // Initializes
        self.tabCount = dataSource?.numberOfTabView()
        self.leftTabIndex = 2
        self.tabs = []
        self.contents = []
        
        // Add tabsView in Superview
        if self.tabsView == nil {
            self.tabsView =  UIScrollView.init(frame: CGRectMake(0, self.yPositionOfTabView!, self.view.frame.size.width, self.heightOfTabView!))
            self.tabsView!.userInteractionEnabled = true
            self.tabsView!.autoresizingMask = UIViewAutoresizing.FlexibleWidth
            self.tabsView!.backgroundColor = self.tabsViewBackgroundColor
            self.tabsView!.scrollsToTop = false
            self.tabsView!.showsHorizontalScrollIndicator = false
            self.tabsView!.showsVerticalScrollIndicator = false
            self.tabsView!.tag = NKJPagerViewControllerTabViewTag
            self.tabsView!.delegate = self
            self.tabsView!.backgroundColor = UIColor.clearColor()
            self.view.insertSubview(self.tabsView!, atIndex: 0)
            
            if infiniteSwipe == true {
                
                self.tabsView!.bounces = false
                self.tabsView!.scrollEnabled = true
                
            } else {
                
                self.tabsView!.bounces = true
                self.tabsView!.scrollEnabled = true
                
            }
        }
        
        var contentSizeWidth: CGFloat = 0
        
        for i in 0 ..< self.tabCount! {
            if self.tabs!.count >= self.tabCount {
                continue
            }
            
            let tabView: UIView = self.dataSource!.viewForTabAtIndex(self, tabIndex: i)
            tabView.tag = i
            var frame: CGRect = tabView.frame
            frame.origin.x = contentSizeWidth
            frame.size.width = self.dataSource!.widthOfTabViewWithIndex(i)
            tabView.frame = frame
            tabView.userInteractionEnabled = true
            
            self.tabsView?.addSubview(tabView)
            self.tabs?.append(tabView)
            
            contentSizeWidth += CGRectGetWidth(tabView.frame)
            
            // To capture tap events
            
            let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(BTPagerViewController.handleTapGesture(_:)))
            tabView.addGestureRecognizer(tapGestureRecognizer)
            
            // view controller
            self.contents?.append(self.dataSource!.contentViewControllerForTabAtIndex(self, index: i))
            
        }
        self.tabsView!.contentSize = CGSizeMake(contentSizeWidth, self.heightOfTabView!)
        
        // Positioning
        
        if infiniteSwipe == true {
            let contentOffsetWidth: CGFloat = self.dataSource!.widthOfTabViewWithIndex(0)
                + self.dataSource!.widthOfTabViewWithIndex(1)
                + self.dataSource!.widthOfTabViewWithIndex(2)
                - (UIScreen.mainScreen().bounds.size.width - self.dataSource!.widthOfTabViewWithIndex(0)) / 2
            self.tabsView!.contentOffset = CGPointMake (contentOffsetWidth, 0)
        }
        
        // Add contentView in Superview
        self.contentView = self.view.viewWithTag(NKJPagerViewControllerContentViewTag)
        
        if self.contentView == nil {
            // Populate pageViewController.view in contentView
            self.contentView = self.pageViewController!.view
            
            self.contentView!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            self.contentView!.backgroundColor = kContentViewBackgroundColor
            self.contentView!.backgroundColor = UIColor.clearColor()
            self.contentView!.bounds = self.view.bounds
            self.contentView!.tag = NKJPagerViewControllerContentViewTag
            self.view.insertSubview(self.contentView!, atIndex: 0)
            
            // constraints
            
            if self.delegate!.respondsToSelector(#selector(BTPagerViewControllerDelegate.viewPagerDidAddContentView)) {
                self.delegate!.viewPagerDidAddContentView?()
            } else {
                self.contentView!.translatesAutoresizingMaskIntoConstraints = false
                
                let views = ["contentView": self.contentView!,
                             "topLayoutGuide": self.topLayoutGuide,
                             "bottomLayoutGuide": self.bottomLayoutGuide]
                
                let castViews = views as! [String: AnyObject]
                
                self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-0-[contentView]-0-|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: castViews))
                self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[topLayoutGuide]-0-[contentView]-0-[bottomLayoutGuide]", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views:castViews))
            }
        }
        // Setting Active Index
        if self.infiniteSwipe == true {
            self.selectTabAtIndex(3)
        }else {
            self.selectTabAtIndex(0)
        }
        
        // Default Design
        if self.delegate!.respondsToSelector(#selector(BTPagerViewControllerDelegate.viewPagerdidSwitchAtIndex(_:index:tabs:))) {
            self.delegate!.viewPagerdidSwitchAtIndex!(self, index: self.activeContentIndex!, tabs: self.tabs!)
            
        }
    }
    
    // ================================================================================
    // MARK: - Life Cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.defaultSetUp()
    }
    
    // ================================================================================
    // MARK: - Gesture
    
    func handleTapGesture(sender: UITapGestureRecognizer) {
        if self.delegate!.respondsToSelector(#selector(BTPagerViewControllerDelegate.viewPagerDidTapMenuTabAtIndex(_:index:))) {
            self.delegate!.viewPagerDidTapMenuTabAtIndex!(self, index: sender.view!.tag)
        }
        
        self.transitionTabViewWithView(sender.view!)
        self.selectTabAtIndex(sender.view!.tag)
    }
    
    func transitionTabViewWithView(view: UIView) {
        let buttonSize: CGFloat = self.dataSource!.widthOfTabViewWithIndex(view.tag)
        
        let sizeSpace: CGFloat = (UIScreen.mainScreen().bounds.size.width - buttonSize) / 2
        
        if infiniteSwipe == true {
            self.tabsView!.setContentOffset(CGPointMake(view.frame.origin.x - sizeSpace, 0), animated: true)
            
        } else {
            let rightEnd: CGFloat = self.tabsView!.contentSize.width - UIScreen.mainScreen().bounds.size.width
            
            if view.frame.origin.x <= sizeSpace {
                self.tabsView?.setContentOffset(CGPointMake(0, 0), animated: true)
            } else if view.frame.origin.x >= rightEnd + sizeSpace {
                self.tabsView?.setContentOffset(CGPointMake(rightEnd, 0), animated: true)
                
            } else {
                self.tabsView?.setContentOffset(CGPointMake(view.frame.origin.x - sizeSpace, 0), animated: true)
            }
        }
    }
    
    func handleSwipeGesture(sender: UISwipeGestureRecognizer) {
        if sender.direction == .Left {
            let activeTabView : UIView = self.tabViewAtIndex(4)
            self.transitionTabViewWithView(activeTabView)
            self.selectTabAtIndex(activeTabView.tag)
        } else if sender.direction == .Right {
            let activeTabView : UIView = self.tabViewAtIndex(2)
            self.transitionTabViewWithView(activeTabView)
            self.scrollWithDirection(1)
        }
    }
    
    // ================================================================================
    // MARK: - UIPageViewControllerDataSource
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var index: Int = self.indexForViewController(viewController)
        index += 1
        
        if index == self.contents!.count {
            index = 0
        }
        return self.viewControllerAtIndex(index)
    }
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index: Int = self.indexForViewController(viewController)
        
        if index == 0 {
            index = self.contents!.count - 1
        } else {
            index -= 1
        }
        
        return self.viewControllerAtIndex(index)
    }
    
    // ================================================================================
    // MARK: - UIPageViewControllerDelegate
    
    public func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        if self.delegate!.respondsToSelector(#selector(BTPagerViewControllerDelegate.viewPagerWillTransition(_:))) {
            self.delegate!.viewPagerWillTransition!(self)
        }
    }
    
    public func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        let viewController: UIViewController = self.pageViewController!.viewControllers![0]
        let index: Int = self.indexForViewController(viewController)
        
        self.activeContentIndex = index
        
        for view in (self.tabsView?.subviews)! {
            if view.tag == index {
                self.transitionTabViewWithView(view)
                break
            }
        }
        
        if completed == true {
            if self.delegate!.respondsToSelector(#selector(BTPagerViewControllerDelegate.viewPagerWillSwitchAtIndex(_:index:tabs:))) {
                self.delegate!.viewPagerWillSwitchAtIndex!(self, index: index, tabs: self.tabs!)
            }
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(0.3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(),{
            self.pageAnimationDidFinish()
        })
        
    }
    
    // ================================================================================
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if infiniteSwipe == true {
            
            // To scroll
            if scrollView.tag == NKJPagerViewControllerTabViewTag {
                let buttonSize: CGFloat! = self.dataSource!.widthOfTabViewWithIndex(self.activeContentIndex!)
                let position: CGFloat! = self.tabsView!.contentOffset.x / buttonSize
                let delta: CGFloat! =  position - CGFloat(self.leftTabIndex!)
                
                if fabs(delta) >= 1.0 {
                    if delta > 0 {
                        self.scrollWithDirection(0)
                    } else {
                        self.scrollWithDirection(1)
                    }
                }
            }
        }
    }
    // ================================================================================
    // MARK: - public Meshod
    private var pagerDirection: UIPageViewControllerNavigationDirection = UIPageViewControllerNavigationDirection(rawValue: 0)!
    
    public func setActiveContentIndex(activeContentIndex: Int) {
        let viewController: UIViewController = self.viewControllerAtIndex(activeContentIndex)
        
        weak var weakSelf = self
        
        if activeContentIndex == self.activeContentIndex {
            if self.delegate!.respondsToSelector(#selector(BTPagerViewControllerDelegate.viewPagerWillSwitchAtIndex(_:index:tabs:))) {
                self.delegate!.viewPagerWillSwitchAtIndex!(self, index: activeContentIndex, tabs: self.tabs!)
            }
            
            self.pageViewController?.setViewControllers([viewController], direction: .Forward, animated: false, completion: { (completed) -> Void in
                weakSelf?.activeContentIndex = activeContentIndex
                weakSelf?.pageAnimationDidFinish()
            })
        } else {
            
            if activeContentIndex == self.contents!.count - 1 && self.activeContentIndex == 0 {
                
                if infiniteSwipe == true {
                    pagerDirection = .Reverse
                } else {
                    pagerDirection = .Forward
                }
            } else if activeContentIndex == 0 && self.activeContentIndex == self.contents!.count - 1 {
                if infiniteSwipe == true {
                    pagerDirection = .Forward
                } else {
                    pagerDirection = .Reverse
                }
            } else if activeContentIndex < self.activeContentIndex {
                pagerDirection = .Reverse
            } else {
                pagerDirection = .Forward
            }
            
            if self.delegate!.respondsToSelector(#selector(BTPagerViewControllerDelegate.viewPagerWillSwitchAtIndex(_:index:tabs:))) {
                self.delegate!.viewPagerWillSwitchAtIndex!(self, index: activeContentIndex, tabs: self.tabs!)
            }
            
            self.pageViewController?.setViewControllers([viewController], direction: pagerDirection, animated: true, completion: { (completed) -> Void in
                weakSelf?.activeContentIndex = activeContentIndex
                weakSelf?.pageAnimationDidFinish()
            })
        }
    }
    
    public func switchViewControllerWithIndex(index: Int) {
        let view: UIView = self.tabs![index]
        self.transitionTabViewWithView(view)
        self.selectTabAtIndex(index)
    }
    
    // ================================================================================
    // MARK: - private Meshod
    
    func pageAnimationDidFinish() {
        if self.delegate!.respondsToSelector(#selector(BTPagerViewControllerDelegate.viewPagerdidSwitchAtIndex(_:index:tabs:))) {
            self.delegate!.viewPagerdidSwitchAtIndex!(self, index: self.activeContentIndex!, tabs: self.tabs!)
        }
    }
    
    func selectTabAtIndex(index: Int) {
        if index >= self.tabCount {
            return
        }
        self.setActiveContentIndex(index)
    }
    
    func tabViewAtIndex(index: Int) ->UIView{
        return self.tabs![index]
    }
    
    public  func viewControllerAtIndex(index: Int) ->UIViewController {
        if index >= self.tabCount {
            return UIViewController()
        }
        
        return self.contents![index]
    }
    
    func indexForViewController(viewController: UIViewController) ->Int {
        return (self.contents?.indexOfObject(viewController))!
    }
    
    func scrollWithDirection(direction: Int) {
        let buttonSize: CGFloat = self.dataSource!.widthOfTabViewWithIndex(self.activeContentIndex!)
        
        if direction == 0 {
            let firstView: UIView = self.tabs!.first!
            self.tabs?.removeAtIndex(0)
            self.tabs?.append(firstView)
        } else {
            let lastView: UIView = self.tabs!.last!
            self.tabs?.removeLast()
            self.tabs?.insert(lastView, atIndex: 0)
        }
        
        var index: Int = 0
        var contentSizeWidth: CGFloat = 0
        
        for pageView in self.tabs! {
            
            var frame: CGRect = pageView.frame
            frame.origin.x = contentSizeWidth
            frame.size.width = buttonSize
            pageView.frame = frame
            contentSizeWidth += buttonSize
            
            index += 1
            
        }
        
        if direction == 0 {
            self.tabsView!.contentOffset = CGPointMake(self.tabsView!.contentOffset.x - buttonSize, 0)
        } else {
            self.tabsView!.contentOffset = CGPointMake(self.tabsView!.contentOffset.x + buttonSize, 0)
        }
    }
}
