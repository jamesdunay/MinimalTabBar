//
//  UIMinimalBarController.m
//  MinimalTabBar
//
//  Created by james.dunay on 11/19/14.
//  Copyright (c) 2014 James.Dunay. All rights reserved.
//

#import "JDMinimalTabBarController.h"
#import "JDViewHitTestOverride.h"
#import "BDZSituationDisplayService.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat minimalBarHeight = 70.f;

static NSString *kLeftButtonID = @"leftButton";
static NSString *kRightButtonID = @"rightButton";

@interface JDMinimalTabBarController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) JDViewHitTestOverride *coverView;
@property (nonatomic) CGAffineTransform viewControllerTransform;
@property (nonatomic) CGAffineTransform scrollViewTransform;

@property (nonatomic, strong) NSMutableDictionary *optionalControllerButtons;

@property (nonatomic, strong) UIView *optionalLeftControllerAccessory;
@property (nonatomic, strong) UIView *optionalRightControllerAccessory;

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
    
    _optionalControllerButtons = [NSMutableDictionary new];
    
    _minimalBar = [JDMinimalTabBar new];
    _viewControllers = [NSArray new];
    _scrollView = [UIScrollView new];
    
    _optionalLeftControllerAccessory = [UIView new];
    _optionalRightControllerAccessory = [UIView new];
    
    _coverView = [JDViewHitTestOverride new];
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

    _optionalLeftControllerAccessory.translatesAutoresizingMaskIntoConstraints = NO;
    _optionalRightControllerAccessory.translatesAutoresizingMaskIntoConstraints = NO;
    
    _minimalBar.translatesAutoresizingMaskIntoConstraints = NO;
    _coverView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_minimalBar];
    [self.view addSubview:_optionalLeftControllerAccessory];
    [self.view addSubview:_optionalRightControllerAccessory];
    
    [self.view addSubview:[[BDZSituationDisplayService sharedInstance] display]];
    [[BDZSituationDisplayService sharedInstance] setSuperView:self.view];
    
    [self.view addConstraints:[self defaultConstraints]];
    [self allowScrollViewUserInteraction:NO];
}

//- (void)viewWillLayoutSubviews
//{
//    [super viewWillLayoutSubviews];
//    [_minimalBar layoutSubviews];
//}

- (NSArray *)defaultConstraints {
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    UIView *situationDisplay = [[BDZSituationDisplayService sharedInstance] display];
    
    [constraints addObjectsFromArray:[BDZConstraintGenerator horizontalConstraintsForViews:@[_coverView, _minimalBar, situationDisplay]]];
    [constraints addObjectsFromArray:[BDZConstraintGenerator verticalConstraintsForViews:@[_coverView]]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_minimalBar
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1
                                                         constant:minimalBarHeight ]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_minimalBar
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:situationDisplay
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1
                                                         constant:0.f ]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:situationDisplay
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1
                                                         constant:30. ]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_optionalLeftControllerAccessory(==_optionalRightControllerAccessory)]-60-[_optionalRightControllerAccessory]-15-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_optionalLeftControllerAccessory, _optionalRightControllerAccessory)
                                      ]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_optionalRightControllerAccessory
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_minimalBar
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1
                                                         constant:0.f ]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_optionalRightControllerAccessory
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_minimalBar
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1
                                                         constant:0.f ]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_optionalLeftControllerAccessory
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_minimalBar
                                                        attribute:NSLayoutAttributeTop
                                                       multiplier:1
                                                         constant:0.f ]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_optionalLeftControllerAccessory
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:_minimalBar
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1
                                                         constant:0.f ]];

    NSLayoutConstraint *situationDisplayTopConstraint = [NSLayoutConstraint constraintWithItem:situationDisplay
                                                                                     attribute:NSLayoutAttributeTop
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self.view
                                                                                     attribute:NSLayoutAttributeBottom
                                                                                    multiplier:1
                                                                                      constant:0.f ];
    
    [[BDZSituationDisplayService sharedInstance] setRequiredDisplayConstraint:situationDisplayTopConstraint];
    [constraints addObject:situationDisplayTopConstraint];
    
    return [constraints copy];
}

#pragma Mark Delegate Methods
#pragma Mark Tapped Delegates

- (void)changeToPageIndex:(NSUInteger)pageIndex {
    CGFloat xPoint = pageIndex * self.view.frame.size.width;
    [self.scrollView setContentOffset:CGPointMake(xPoint, 0)];
    [self showButtonForControllerIndex:pageIndex];
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


#pragma Optional Accessory Methods

- (void)showButtonForControllerIndex:(NSInteger)controllerIndex
{
    _optionalLeftControllerAccessory.userInteractionEnabled = NO;
    _optionalRightControllerAccessory.userInteractionEnabled = NO;
    
    [_optionalLeftControllerAccessory.subviews each:^(UIButton *leftButton) {
        leftButton.alpha = 0;
    }];
    
    [_optionalRightControllerAccessory.subviews each:^(UIButton *rightButton) {
        rightButton.alpha = 0;
    }];
    
    UIButton *leftButtonToShow = _optionalControllerButtons[@(controllerIndex)][kLeftButtonID];
    UIButton *rightButtonToShow = _optionalControllerButtons[@(controllerIndex)][kRightButtonID];
    
    if (leftButtonToShow) {
        _optionalLeftControllerAccessory.userInteractionEnabled = YES;
        leftButtonToShow.alpha = 1;
    }
    
    if (rightButtonToShow) {
        _optionalRightControllerAccessory.userInteractionEnabled = YES;
        rightButtonToShow.alpha = 1;
    }
}

- (void)installOptionalLeftButton:(UIButton *)leftButton onController:(UIViewController *)controller
{
    leftButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSInteger indexOfView = [_viewControllers indexOfObject:controller];
    
    [_optionalLeftControllerAccessory addSubview:leftButton];
    _optionalControllerButtons[@(indexOfView)][kLeftButtonID] = leftButton;
    
    [_optionalLeftControllerAccessory addConstraints:[BDZConstraintGenerator verticalConstraintsForViews:@[leftButton]]];
    [_optionalLeftControllerAccessory addConstraints:[BDZConstraintGenerator horizontalConstraintsForViews:@[leftButton]]];
    
    [_optionalLeftControllerAccessory layoutSubviews];
}

- (void)installOptionalRightButton:(UIButton *)rightButton onController:(UIViewController *)controller
{
    rightButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_optionalRightControllerAccessory addSubview:rightButton];
    _optionalControllerButtons[@(controller.view.tag)][kRightButtonID] = rightButton;
    
    [_optionalRightControllerAccessory addConstraints:[BDZConstraintGenerator verticalConstraintsForViews:@[rightButton]]];
    [_optionalRightControllerAccessory addConstraints:[BDZConstraintGenerator horizontalConstraintsForViews:@[rightButton]]];
    
    [_optionalRightControllerAccessory layoutSubviews];
}



// need to layoutSubviews for each.


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
        
        _optionalControllerButtons[@(idx)] = [@{} mutableCopy];
        
        viewController.view.frame = CGRectMake(self.view.frame.size.width * idx, 0, self.view.frame.size.width, self.view.frame.size.height);
        viewController.view.tag = idx;
        viewController.tabBarItem.tag = idx;
        
        _viewControllerTransform = viewController.view.transform;
        [self.scrollView addSubview:viewController.view];
    }];
    
    [self.view addConstraints:[self defaultConstraints]];
    [_minimalBar createButtonItems:_viewControllers];
}

@end
