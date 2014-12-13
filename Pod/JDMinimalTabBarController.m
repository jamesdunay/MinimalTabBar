//
//  UIMinimalBarController.m
//  MinimalTabBar
//
//  Created by james.dunay on 11/19/14.
//  Copyright (c) 2014 James.Dunay. All rights reserved.
//

#import "JDMinimalTabBarController.h"
#import "JDViewHitTestOverride.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat minimalBarHeight = 70.f;

@interface JDMinimalTabBarController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) JDViewHitTestOverride *coverView;
@property (nonatomic) CGAffineTransform viewControllerTransform;
@property (nonatomic) CGAffineTransform scrollViewTransform;
@end

@implementation JDMinimalTabBarController

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
}

- (void)setupViews {
    _minimalBar = [[JDMinimalTabBar alloc] init];
    _viewControllers = [[NSArray alloc] init];
    _scrollView = [[UIScrollView alloc] init];
    
    _coverView = [[JDViewHitTestOverride alloc] init];
    _coverView.translatesAutoresizingMaskIntoConstraints = NO;
    _coverView.scrollView = _scrollView;
    [self.view addSubview:_coverView];
    
    [_scrollView setPagingEnabled:YES];
    [_scrollView setDelegate:self];
    [_scrollView setClipsToBounds:NO];
    [_scrollView setAutoresizesSubviews:NO];
    [_scrollView setFrame:self.view.frame];
    _scrollViewTransform = _scrollView.transform;
    [_coverView addSubview:_scrollView];
    
    _minimalBar.mMinimalBarDelegate = self;
    _minimalBar.screenHeight = self.view.frame.size.height;
    _minimalBar.translatesAutoresizingMaskIntoConstraints = NO;

    
    [self.view addSubview:_minimalBar];
    
    [self.view addConstraints:[self defaultConstraints]];
    [self allowScrollViewUserInteraction:NO];
}

- (NSArray *)defaultConstraints {
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_coverView]|"
                                             options:0
                                             metrics:0
                                               views:NSDictionaryOfVariableBindings(_coverView)]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_coverView]|"
                                             options:0
                                             metrics:0
                                               views:NSDictionaryOfVariableBindings(_coverView)]];
    
    [constraints addObjectsFromArray:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_minimalBar]|"
                                             options:0
                                             metrics:0
                                               views:NSDictionaryOfVariableBindings(_minimalBar)
      ]];
    
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_minimalBar
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1
                                                         constant:minimalBarHeight
                            ]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_minimalBar
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1
                                                         constant:0.f
                            ]];
    
    return [constraints copy];
}

#pragma Mark Delegate Methods
#pragma Mark Tapped Delegates

- (void)changeToPageIndex:(NSUInteger)pageIndex {
    CGFloat xPoint = pageIndex * self.view.frame.size.width;
    [self.scrollView setContentOffset:CGPointMake(xPoint, 0)];
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
    [UIView animateWithDuration:.2f animations: ^{
        [self.scrollView setContentOffset:CGPointMake(xPoint, 0)];
    }];
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
}



#pragma Interface Usability

- (void)allowScrollViewUserInteraction:(BOOL)allowInteraction {
    [_scrollView setScrollEnabled:allowInteraction];
}



#pragma Mark Setters

- (void)setViewControllers:(NSArray *)viewControllers {
    _viewControllers = viewControllers;
    
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width * _viewControllers.count, self.view.frame.size.height)];
    
    if (self.scrollView.subviews) {
        [self.scrollView.subviews enumerateObjectsUsingBlock: ^(UIView *view, NSUInteger idx, BOOL *stop) {
            [view removeFromSuperview];
        }];
    }
    
    [_viewControllers enumerateObjectsUsingBlock: ^(UIViewController* viewController, NSUInteger idx, BOOL *stop) {
        viewController.view.frame = CGRectMake(self.view.frame.size.width * idx, 0, self.view.frame.size.width, self.view.frame.size.height);
        viewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        viewController.view.tag = idx;
        viewController.tabBarItem.tag = idx;
        
        _viewControllerTransform = viewController.view.transform;
        [self.scrollView addSubview:viewController.view];
    }];
    
    [self.view addConstraints:[self defaultConstraints]];
    [_minimalBar createButtonItems:_viewControllers];
}

@end
