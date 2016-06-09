//
//  JDViewController.h
//  Boards
//
//  Created by James Dunay on 4/7/16.
//  Copyright © 2016 James Dunay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDViewController : UIViewController

- (void)willDisplayJDViewController;

- (void)showSpinner;
- (void)hideSpinner;

- (void)showSpinnerInNavigationBar;
- (void)hideSpinnerInNavigationBar;

@end
