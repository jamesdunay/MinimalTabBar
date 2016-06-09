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


@end
