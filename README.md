[![CI Status](http://img.shields.io/travis/jamesdunay@gmail.com/MinimalTabBar.svg?style=flat)](https://travis-ci.org/jamesdunay@gmail.com/MinimalTabBar)
[![Version](https://img.shields.io/cocoapods/v/MinimalTabBar.svg?style=flat)](http://cocoadocs.org/docsets/MinimalTabBar)
[![License](https://img.shields.io/cocoapods/l/MinimalTabBar.svg?style=flat)](http://cocoadocs.org/docsets/MinimalTabBar)
[![Platform](https://img.shields.io/cocoapods/p/MinimalTabBar.svg?style=flat)](http://cocoadocs.org/docsets/MinimalTabBar)


# MinimalTabBar

An elegant revision to the TabBar on iOS. 
MinimalTabBar gets it's name by hiding once you have selected an item, leaving your `UIViewControllers` uncluttered. 

![](http://i.imgur.com/of7jv2j.gif)


## Gestures
The MinimalTabBar has a number of gestures to allow unique user-interaction. While minimized the user has three seperate gestures to control navigation.

  * **Tap** Opens the MinimalTabBar
  * **Swipe** Slides the user between adjacent `UIViewControllers`
  * **Long** Press Gives the user a complete look at the app




## Implementation
Implementation mirrors Apple's `UITabBar` very closely. Assuming your `UIViewControllers` have `UITabBar` items it's only two steps.
```objc
JDMinimalTabBarController *minimalTabBarViewController = [[JDMinimalTabBarController alloc] init];
```

Once you've created your MinimalTabBar assigning it `UIViewControllers` is easy. Use the `UITabBar` item's `name`, `image`, and `selectedImage` to control the look of each tab.
```objc
[minimalTabBarViewController setViewControllers:@[sectionOneVC, sectionTwoVC, sectionThreeVC, sectionFourVC, sectionFiveVC]];
```

*MinimalTabBarController's MinimalBar you can set the following attributes:*

  * `@property (nonatomic, strong) UIColor* defaultTintColor;`
  * `@property (nonatomic, strong) UIColor* selectedTintColor;`
  * `@property (nonatomic) BOOL showTitles;`
  * `@property (nonatomic) BOOL hidesTitlesWhenSelected;`

*You can also provide the MinimalBar with a background color if you so wish*

## Notes

If you have any comments or run into any errors, please let me know as I am making changes frequently. 

    

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

MinimalTabBar is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "MinimalTabBar"

## Author

jamesdunay [at] gmail 


## License

MinimalTabBar is available under the MIT license. See the LICENSE file for more info.

