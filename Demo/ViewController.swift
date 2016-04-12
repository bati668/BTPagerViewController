//
//  ViewController.swift
//  Demo
//
//  Created by Hiroshi Chiba on 2016/04/12.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import UIKit
import BTPagerViewController

class ViewController: BTPagerViewController,BTPagerViewControllerDataSource, BTPagerViewControllerDelegate {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        self.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func numberOfTabView() -> Int {
        return 10
    }
    
    func widthOfTabViewWithIndex(index: Int) -> CGFloat {
        return 160
    }
    
    func viewForTabAtIndex(viewPager: BTPagerViewController, tabIndex: Int) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 160, height: 44))
        label.backgroundColor = UIColor.grayColor()
        label.font = UIFont.systemFontOfSize(12)
        label.text = "Tab: \(tabIndex)"
        label.textAlignment = .Center
        label.textColor = UIColor.blackColor()
        return label
    }
    
    func contentViewControllerForTabAtIndex(viewPager: BTPagerViewController, index: Int) -> UIViewController {
        var viewControllerArray: Array<UIViewController> = []
        for _ in 0 ..< 10 {
            let controller = UIViewController()
            viewControllerArray.append(controller)
        }
        return viewControllerArray[index]
    }
}

