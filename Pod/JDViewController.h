//
//  JDViewController.h
//  Boards
//
//  Created by James Dunay on 4/7/16.
//  Copyright © 2016 James Dunay. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^KeyboardWillShow)(NSNotification *);
typedef void(^KeyboardWillHide)(NSNotification *);

@interface JDViewController : UIViewController

@property (nonatomic, copy) KeyboardWillShow keyboardWillShow;
@property (nonatomic, copy) KeyboardWillHide keyboardWillHide;

- (void)willDisplayJDViewController;

- (void)showSpinner;
- (void)hideSpinner;

- (void)showSpinnerInNavigationBar;
- (void)hideSpinnerInNavigationBar;

- (void)addKeyboardObservers;
- (void)removeObservers;

@end
