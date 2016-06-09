//
//  UIMinimalBarController.h
//  MinimalTabBar
//
//  Created by james.dunay on 11/19/14.
//  Copyright (c) 2014 James.Dunay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDMinimalTabBar.h"
#import "JDViewController.h"

@interface JDMinimalTabBarController : UIViewController <MinimalBarDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) JDMinimalTabBar *minimalBar;
@property (nonatomic, weak) UIImage *backgroundImage;

- (void)installOptionalLeftButton:(UIImageView *)leftItem onController:(UIViewController *)controller;
- (void)installOptionalRightButton:(UIImageView *)rightItem onController:(UIViewController *)controller;

- (void)shouldShowBackgroundEffectsView:(BOOL)shouldShow;
- (void)shouldFocusButtons:(BOOL)focus;
- (void)hideBar:(BOOL)hide;

- (void)addCloseBarButtonwithTarget:(nullable id)target action:(nullable SEL)action;

- (void)addTitle:(NSString *)title;

- (void)hideTitle;

- (void)animateHideBar;

- (void)animateShowBar;

- (void)removeRightBarItem;

- (void)selectItemAtIndex:(NSInteger)index;

+ (JDMinimalTabBarController *)sharedInstance;

- (void)showSpinnerOn:(UIViewController *)viewController;
- (void)hideSpinnerOn:(UIViewController *)viewController;

@end
