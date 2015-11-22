//
//  UIMinimalBarController.h
//  MinimalTabBar
//
//  Created by james.dunay on 11/19/14.
//  Copyright (c) 2014 James.Dunay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDMinimalTabBar.h"

@interface JDMinimalTabBarController : UIViewController <MinimalBarDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) JDMinimalTabBar *minimalBar;
@property (nonatomic, weak) UIImage *backgroundImage;

- (void)installOptionalLeftButton:(UIImageView *)leftItem onController:(UIViewController *)controller;
- (void)installOptionalRightButton:(UIImageView *)rightItem onController:(UIViewController *)controller;

- (void)shouldShowBackgroundEffectsView:(BOOL)shouldShow;

+ (JDMinimalTabBarController *)sharedInstance;

@end
