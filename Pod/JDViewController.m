//
//  JDViewController.m
//  Boards
//
//  Created by James Dunay on 4/7/16.
//  Copyright © 2016 James Dunay. All rights reserved.
//

#import "JDViewController.h"
#import "BDZSpinner.h"

@interface JDViewController()

@property (nonatomic, strong) BDZSpinner *spinner;

@end

@implementation JDViewController


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeObservers];
}

- (void)willDisplayJDViewController
{
    
}

- (void)showSpinner
{
    [[JDMinimalTabBarController sharedInstance] showSpinnerOn:self.navigationController];
}

- (void)hideSpinner
{
    [[JDMinimalTabBarController sharedInstance] hideSpinnerOn:self.navigationController];
}

- (void)showSpinnerInNavigationBar
{
    self.spinner = [BDZSpinner new];
    self.spinner.bounds = CGRectMake(0, 0, 26, 27);
    UIBarButtonItem *spinnerButton = [[UIBarButtonItem alloc] initWithCustomView:self.spinner];
    [self.navigationItem setRightBarButtonItem:spinnerButton];
    [self.spinner startAnimating];
}

- (void)hideSpinnerInNavigationBar
{
    [self.spinner stopAnimating];
}

- (void)addKeyboardObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if (self.keyboardWillShow) self.keyboardWillShow(notification);
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (self.keyboardWillHide) self.keyboardWillHide(notification);
}

@end
