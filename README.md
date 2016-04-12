# BTPagerViewController


BTPagerViewController is a PagerTabStrip ViewController.
It contains an endlessly scrollable UIScrollView.

<img src="./swipe.gif" width="300" />

This viewController inspired [NKJPagerViewController](https://github.com/nakajijapan/NKJPagerViewController). The biggest of difference is written in pure swift.

## Requirements

BTPagerViewController higher requires Xcode 7, targeting either iOS 8.0 and above
## Installation

### CocoaPods

```
pod "BTPagerViewController"
```

## Usage

Implement as subclass of BTPagerViewController and imprement dataSource and delegate methods in the subclass.

```
required init?(coder aDecoder: NSCoder) 
{
  super.init(coder: aDecoder)
   self.delegate = self
   self.dataSource = self
}

```

### BTPagerViewDataSource

Decide number of tabs.

```objc
func numberOfTabView() -> Int
{
  return 10
}
```

Decide width for each tab.

```
func widthOfTabViewWithIndex(index: Int) -> CGFloat
{
  return 160
}
```

Setting a view design for each tab.

```objc
func viewForTabAtIndex(viewPager: BTPagerViewController, tabIndex: Int) -> UIView {
   let label = UILabel(frame: CGRect(x: 0, y: 0, width: 160, height: 44))
   label.backgroundColor = UIColor.grayColor()
   label.font = UIFont.systemFontOfSize(12)
   label.text = "Tab: \(tabIndex)"
   label.textAlignment = .Center
   label.textColor = UIColor.blackColor()
   return label
}
```

Setting a view controller for each tab.

```objc
func contentViewControllerForTabAtIndex(viewPager: BTPagerViewController, index: Int) -> UIViewController
{
    var viewControllerArray: Array<UIViewController> = []
    for _ in 0 ..< 10 {
    let controller = UIViewController()
    viewControllerArray.append(controller)
    }
    return viewControllerArray[index]
}


```

### BTPagerViewDelegate

This method is option.

```objc
func viewPagerdidSwitchAtIndex(viewPager: BTPagerViewController, index: Int, tabs: Array<AnyObject>)
{
// do something did Switch tab
}
```

```objc
func viewPagerWillTransition(viewPager: BTPagerViewController)
{
// do something when willTransition
}
```

```objc
func viewPagerWillSwitchAtIndex(viewPager: BTPagerViewController, index: Int, tabs: Array<AnyObject>)
{
// do something when will switch tab index
}
```

```objc
func viewPagerDidTapMenuTabAtIndex(viewPager: BTPagerViewController, index: Int)
{
// do something when tapped tab 
}
```

## Author

[bati](https://www.facebook.com/hiroshi.chiba.54)


## License

BTPagerViewController is available under the MIT license. See the LICENSE file for more info.

