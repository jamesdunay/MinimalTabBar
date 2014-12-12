[![CI Status](http://img.shields.io/travis/jamesdunay@gmail.com/MinimalTabBar.svg?style=flat)](https://travis-ci.org/jamesdunay@gmail.com/MinimalTabBar)
[![Version](https://img.shields.io/cocoapods/v/MinimalTabBar.svg?style=flat)](http://cocoadocs.org/docsets/MinimalTabBar)
[![License](https://img.shields.io/cocoapods/l/MinimalTabBar.svg?style=flat)](http://cocoadocs.org/docsets/MinimalTabBar)
[![Platform](https://img.shields.io/cocoapods/p/MinimalTabBar.svg?style=flat)](http://cocoadocs.org/docsets/MinimalTabBar)


# MinimalTabBar

A new, and elegant, solution to the TabBar on iOS. 
MinimalTabBar gets it's name by hiding once you have selected an item, leaving your UIViewControllers uncluttered. 

![](http://i.imgur.com/of7jv2j.gif)


## Gestures
The MinimalTabBar has a number of gestures to allow unique user-interaction. While minimized the user has three seperate gestures to control navigation.

-- Tap --- Opens the MinimalTabBar

-- Swipe --- Slides the user between adjacent ViewControllers

-- Long Press --- Gives the user a complete look at their app


## Implimentation
MinimalTabBar implimentation mirrors the UITabBar very closely. Assuming your viewcontrollers have UITabBar items it's as simple as this.

```objc
JDMinimalTabBarController *minimalTabBarViewController = [[JDMinimalTabBarController alloc] init];
```


Once you've created your MinimalTabBar assigning it `UIViewControllers` is easy. Just make sure to include a `UITabBar` item with each so you can specify a `name`, `image`, and `selectedImage`
```objc
[minimalTabBarViewController setViewControllers:@[sectionOneVC, sectionTwoVC, sectionThreeVC, sectionFourVC, sectionFiveVC]];
```

Additionally you can do set the following attributes:
**Default tint color** `minimalTabBarViewController.minimalBar.defaultTintColor = [UIColor whiteColor];`

**Selected item tint color** `minimalTabBarViewController.minimalBar.selectedTintColor = [UIColor redColor];`

**Toggle to show/hide item titles** `minimalTabBarViewController.minimalBar.showTitles = YES;`

**Toggle only selected item to hide title** `minimalTabBarViewController.minimalBar.hidesTitlesWhenSelected = YES;`

**Set background color** `minimalTabBarViewController.minimalBar.backgroundColor = [UIColor clearColor];`

    




## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

MinimalTabBar is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "MinimalTabBar"

## Author

jamesdunay at gmail 

## License

MinimalTabBar is available under the MIT license. See the LICENSE file for more info.

