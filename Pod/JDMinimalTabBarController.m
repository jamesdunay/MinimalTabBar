//
//  UIMinimalBarController.m
//  MinimalTabBar
//
//  Created by james.dunay on 11/19/14.
//  Copyright (c) 2014 James.Dunay. All rights reserved.
//

#import "BDZNavigationController.h"
#import "JDScrollView.h"
#import "JDMinimalTabBarController.h"
#import "JDViewHitTestOverride.h"
#import "BDZSituationDisplayService.h"
#import <QuartzCore/QuartzCore.h>
#import "JDViewController.h"

@interface JDMinimalTabBarController ()

@property (nonatomic, strong) JDScrollView *scrollView;
@property (nonatomic, strong) JDViewHitTestOverride *coverView;
@property (nonatomic) CGAffineTransform viewControllerTransform;
@property (nonatomic) CGAffineTransform scrollViewTransform;

@property (nonatomic, strong) NSLayoutConstraint *minimalBarBottomConstraint;

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIVisualEffectView *backgroundEffectView;

@end

@implementation JDMinimalTabBarController

+ (JDMinimalTabBarController *)sharedInstance
{
    static JDMinimalTabBarController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[JDMinimalTabBarController alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

- (void)setupViews {
    
    _minimalBar = [JDMinimalTabBar new];
    _viewControllers = [NSArray new];
    _scrollView = [JDScrollView new];
    _backgroundImageView = [UIImageView new];
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    _coverView = [JDViewHitTestOverride new];
    _coverView.scrollView = _scrollView;
    [self.view addSubview:_coverView];
    
    [_scrollView setPagingEnabled:YES];
    [_scrollView setDelegate:self];
    [_scrollView setClipsToBounds:NO];
    [_scrollView setAutoresizesSubviews:NO];
    [_scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    _scrollViewTransform = _scrollView.transform;
    [_coverView addSubview:_scrollView];
    
    _minimalBar.mMinimalBarDelegate = self;
    
    [_scrollView addSubview:_backgroundImageView];
    
    _minimalBar.translatesAutoresizingMaskIntoConstraints = NO;
    _coverView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_minimalBar];
    [self.view addSubview:[[BDZSituationDisplayService sharedInstance] display]];
    
    [[BDZSituationDisplayService sharedInstance] setSuperView:self.view];
    
    [self allowScrollViewUserInteraction:NO];
}

- (NSArray *)defaultConstraints
{
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    UIView *situationDisplay = [[BDZSituationDisplayService sharedInstance] display];
    
    [constraints addObjectsFromArray:[BDZConstraintGenerator horizontalConstraintsForViews:@[_coverView, _minimalBar, _scrollView]]];
    [constraints addObjectsFromArray:[BDZConstraintGenerator verticalConstraintsForViews:@[_coverView, _scrollView]]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_minimalBar
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1
                                                         constant:minimalBarHeight ]];
    
    _minimalBarBottomConstraint = [NSLayoutConstraint constraintWithItem:_minimalBar
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1
                                                         constant:0.f ];
    [constraints addObject:_minimalBarBottomConstraint];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:situationDisplay
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_minimalBar
                                                        attribute:NSLayoutAttributeHeight
                                                       multiplier:1.
                                                         constant:0. ]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:situationDisplay
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_minimalBar
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1.
                                                         constant:0. ]];

    [constraints addObject:[NSLayoutConstraint constraintWithItem:situationDisplay
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeWidth
                                                       multiplier:.5
                                                         constant:0. ]];
    
    NSLayoutConstraint *situationDisplayTopConstraint = [NSLayoutConstraint constraintWithItem:situationDisplay
                                                                                     attribute:NSLayoutAttributeLeft
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self.view
                                                                                     attribute:NSLayoutAttributeRight
                                                                                    multiplier:1
                                                                                      constant:0.f ];
    
    [[BDZSituationDisplayService sharedInstance] setRequiredDisplayConstraint:situationDisplayTopConstraint];
    [constraints addObject:[[BDZSituationDisplayService sharedInstance] requiredDisplayConstraint]];
    
    return [constraints copy];
}

#pragma Mark Delegate Methods
#pragma Mark Tapped Delegates

- (void)selectItemAtIndex:(NSInteger)index
{
    [self.minimalBar hideOptionalButtons];
    [self changeToPageIndex:index];
}

- (void)changeToPageIndex:(NSUInteger)pageIndex {
    CGFloat xPoint = pageIndex * self.view.frame.size.width;
    [self.scrollView setContentOffset:CGPointMake(xPoint, 0)];
    [self readyControllerForDisplay:[self controllerForIndex:pageIndex]];
}



#pragma Mark Pan Delegates

- (void)manualOffsetScrollview:(CGFloat)offset {
    CGPoint newOffset = CGPointMake(self.scrollView.contentOffset.x + offset, 0);
    if (newOffset.x >= 0 && newOffset.x <= (self.scrollView.contentSize.width - self.view.frame.size.width)) {
        self.scrollView.contentOffset = newOffset;
    }
}

- (void)sendScrollViewToPoint:(CGPoint)point {
    [self.scrollView setContentOffset:point animated:YES];
}

- (void)didSwitchToIndex:(NSUInteger)pageIndex {
    CGFloat xPoint = pageIndex * self.scrollView.frame.size.width;
    [UIView animateWithDuration:.6f
                          delay:0.
         usingSpringWithDamping:.92
          initialSpringVelocity:3.
                        options:UIViewAnimationOptionCurveLinear
                     animations: ^{
                         [self.scrollView setContentOffset:CGPointMake(xPoint, 0)];
                     }completion:nil];
    
    [self readyControllerForDisplay:[self controllerForIndex:pageIndex]];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImageView.image = backgroundImage;
}

#pragma Display/Overview Methods

#pragma Mark Touch-n-Hold Delegate

- (void)displayAllScreensWithStartingDisplayOn:(CGFloat)startingPosition {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self sendViewsToBackPosition:YES];
    [self allowScrollViewUserInteraction:YES];
    
    [self.scrollView.subviews enumerateObjectsUsingBlock: ^(UIView *view, NSUInteger idx, BOOL *stop) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedView:)];
        [view addGestureRecognizer:tap];
        
        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
    }];
}

#pragma Mark End Delegate

- (void)selectedView:(UITapGestureRecognizer *)tap {
    NSInteger selectedTag = [tap view].tag;
    [self displayViewAtIndex:selectedTag];
}

- (void)displayViewAtIndex:(NSInteger)index{

    [self sendViewsToBackPosition:NO];
    [self.minimalBar returnMenuToSelected:index];
    [UIView animateWithDuration:.25f
                          delay:0.f
         usingSpringWithDamping:.98
          initialSpringVelocity:11
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                     animations: ^{
                         [self allowScrollViewUserInteraction:NO];
                         self.scrollView.contentOffset = CGPointMake(self.view.frame.size.width * index, 0);
                     }
     
                     completion:nil];
}

#pragma Mark ScrollView Depth Toggle
- (void)sendViewsToBackPosition:(BOOL)sendBack {
    void (^scrollViewAnimation)(void) = ^{
        if (sendBack) {
            CATransform3D transform = CATransform3DIdentity;
            transform.m34 = 1.0f / -750.f;
            transform = CATransform3DTranslate(transform, 0.f, 30.f, -100.f);
            transform = CATransform3DRotate(transform, 20.f * M_PI/180, -1, 0, 0);
            _scrollView.layer.transform = transform;
        }else{
            _scrollView.transform =  _scrollViewTransform;
        }
    };
    
    void (^viewControllerAnimation)(void) = ^{
        [_scrollView.subviews enumerateObjectsUsingBlock: ^(UIView *view, NSUInteger idx, BOOL *stop) {
            CGFloat scaleAmount = sendBack ? .9f : 1.f;
            view.transform = CGAffineTransformScale(_viewControllerTransform, scaleAmount, scaleAmount);
        }];
    };
    
    [UIView animateWithDuration:.6f
                          delay:0.f
         usingSpringWithDamping:150
          initialSpringVelocity:15
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         scrollViewAnimation();
                         viewControllerAnimation();
                     } completion:^(BOOL finished) {
                         
                     }];
}

#pragma ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentOffSet = scrollView.contentOffset.x;
    [_minimalBar scrollOverviewButtonsWithPercentage:contentOffSet / _coverView.frame.size.width];
    _backgroundImageView.frame = CGRectMake(0, 0, CGRectGetWidth(_backgroundImageView.frame), CGRectGetHeight(_backgroundImageView.frame));
}



#pragma Interface Usability

- (void)allowScrollViewUserInteraction:(BOOL)allowInteraction {
    [_scrollView setScrollEnabled:allowInteraction];
}


#pragma Optional Accessory Methods

- (void)installOptionalLeftButton:(UIImageView *)leftItem onController:(UIViewController *)controller
{
    NSInteger indexOfController = [_viewControllers indexOfObject:controller];
    [_minimalBar installOptionalLeftButton:leftItem forControllerIndex:indexOfController];
}

- (void)installOptionalRightButton:(UIImageView *)rightItem onController:(UIViewController *)controller
{
    NSInteger indexOfController = [_viewControllers indexOfObject:controller];
    [_minimalBar installOptionalRightButton:rightItem forControllerIndex:indexOfController];
}

#pragma Mark Setters

- (void)setViewControllers:(NSArray *)viewControllers {
    _viewControllers = viewControllers;
    
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width * _viewControllers.count, self.view.frame.size.height)];
    _backgroundImageView.frame = CGRectMake(0, 0, _scrollView.contentSize.width, _scrollView.contentSize.height);
    
    [self createBackgroundEffectView];
    
    if (self.scrollView.subviews) {
        [self.scrollView.subviews each:^(UIView *view) {
            if (![view isKindOfClass:[UIImageView class]]) [view removeFromSuperview];
        }];
    }
    
    [_viewControllers enumerateObjectsUsingBlock: ^(JDViewController* viewController, NSUInteger idx, BOOL *stop) {

        _minimalBar.optionalControllerButtons[@(idx)] = [@{} mutableCopy];
        
        viewController.view.frame = CGRectMake(self.view.frame.size.width * idx, 0, self.view.frame.size.width, self.view.frame.size.height);
    
        viewController.view.tag = idx;
        viewController.tabBarItem.tag = idx;
        
        _viewControllerTransform = viewController.view.transform;
        [self.scrollView addSubview:viewController.view];
    }];

    [self.view addConstraints:[self defaultConstraints]];
    [self.view layoutSubviews];
    [_minimalBar createButtonItems:_viewControllers];
}

- (JDViewController *)controllerForIndex:(NSInteger)index
{
    return _viewControllers[index];
}

- (void)readyControllerForDisplay:(UIViewController *)controller
{
    if ([controller isKindOfClass:[UINavigationController class]] && [controller respondsToSelector:@selector(willDisplayJDViewController)]) {
        [(JDViewController *)[(UINavigationController *)controller topViewController] willDisplayJDViewController];
    }
    
    if ([controller isKindOfClass:[JDViewController class]]) {
        [(JDViewController *)controller willDisplayJDViewController];
    }
}

- (void)shouldFocusButtons:(BOOL)focus
{
    if (focus)  [_minimalBar focusButtons];
    else        [_minimalBar unfocusButtons];
}

# pragma Mark Background Image

- (void)shouldShowBackgroundEffectsView:(BOOL)shouldShow
{
    [UIView transitionWithView:_backgroundImageView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        if (shouldShow) {
            [_backgroundImageView addSubview:_backgroundEffectView];
        } else {
            [_backgroundEffectView removeFromSuperview];
        }

    } completion:nil];
}

- (void)createBackgroundEffectView
{
    UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    _backgroundEffectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    _backgroundEffectView.frame = _backgroundImageView.bounds;
}

- (void)animateHideBar
{
    _minimalBarBottomConstraint.constant = minimalBarHeight;
    [self.view layoutSubviews];
}

- (void)animateShowBar
{
    _minimalBarBottomConstraint.constant = 0;
    [self.view layoutSubviews];
}

- (void)hideBar:(BOOL)hide
{
    _minimalBar.alpha = !hide;
}

# pragma Mark Custom Additions

- (void)removeRightBarItem
{
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)addTitle:(NSString *)title
{
    [self.navigationItem setTitleView:((BDZNavigationController *)self.navigationController).titleLabel];
    
    ((BDZNavigationController *)self.navigationController).titleLabel.text = title;
    ((BDZNavigationController *)self.navigationController).titleLabel.alpha = 0;

    [UIView animateWithDuration:.5 animations:^{
        ((BDZNavigationController *)self.navigationController).titleLabel.alpha = 1;
    }];
}

- (void)hideTitle
{
    [UIView animateWithDuration:.3 animations:^{
        ((BDZNavigationController *)self.navigationController).titleLabel.alpha = 0;
    }];
}

- (void)addCloseBarButtonwithTarget:(nullable id)target action:(nullable SEL)action
{
    UIImage *closeImage = [[UIImage imageNamed:@"Close_Icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem * closeButton = [[UIBarButtonItem alloc]
                                     initWithImage:closeImage
                                     style:UIBarButtonItemStylePlain
                                     target:target
                                     action:action];
    
    self.navigationItem.rightBarButtonItem = closeButton;
}

- (void)showSpinnerOn:(UIViewController *)viewController
{
    NSInteger buttonIndex = [self.viewControllers indexOfObject:viewController];
    [self.minimalBar showSpinnerAtIndex:buttonIndex];
}

- (void)hideSpinnerOn:(UIViewController *)viewController
{
    NSInteger buttonIndex = [self.viewControllers indexOfObject:viewController];
    [self.minimalBar hideSpinnerAtIndex:buttonIndex];
}

@end
