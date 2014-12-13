//
//  MinimalBar.m
//  MinimalTabBar
//
//  Created by james.dunay on 11/19/14.
//  Copyright (c) 2014 James.Dunay. All rights reserved.
//

#import "JDMinimalTabBar.h"
#import "JDMinimalTabBarButton.h"
#import <QuartzCore/QuartzCore.h>

#pragma Mark Enums ---

typedef enum : NSUInteger {
    MenuStateDefault = (1 << 0),
    MenuStateDisplayed = (1 << 1),
    MenuStateFullyOpened = (1 << 2),
} MenuState;

@interface JDMinimalTabBar ()

@property (nonatomic) CGFloat firstX;
@property (nonatomic) CGFloat firstY;
@property (nonatomic) CGFloat lastXOffset;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSArray *adjustableButtonConstaints;
@property (nonatomic) BOOL isDisplayingAll;
@end

@implementation JDMinimalTabBar

- (void)layoutSubviews {
    [super layoutSubviews];
    [self addConstraints:[self defaultConstraints]];
}



#pragma Mark Minimal Bar Buttons ---

- (void)createButtonItems:(NSArray *)viewControllers {
    self.buttons = [[NSMutableArray alloc] init];
    
    [viewControllers enumerateObjectsUsingBlock: ^(UIViewController* viewController, NSUInteger idx, BOOL *stop) {
        
        JDMinimalTabBarButton *mbButton = [[JDMinimalTabBarButton alloc] initWithButtonWithTabBarItem:viewController.tabBarItem];
        mbButton.defaultTintColor = _defaultTintColor;
        mbButton.selectedTintColor = _selectedTintColor;
        mbButton.showTitle = _showTitles;
        mbButton.hideTitleWhenSelected = _hidesTitlesWhenSelected;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedButton:)];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panSelectedButton:)];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(touchAndHold:)];
        
        [mbButton addGestureRecognizer:tap];
        [mbButton addGestureRecognizer:pan];
        [mbButton addGestureRecognizer:longPress];
        
        [self.buttons addObject:mbButton];
        [self addSubview:mbButton];
    }];
    
    [self shouldEnablePanGestures:NO];
}



#pragma mark Tint Color ---

-(void)setDefaultTintColor:(UIColor *)defaultTintColor{
    _defaultTintColor = defaultTintColor;
    [self.buttons enumerateObjectsUsingBlock: ^(JDMinimalTabBarButton *mbButton, NSUInteger idx, BOOL *stop) {
        mbButton.tintColor = defaultTintColor;
    }];
}

-(void)setSelectedTintColor:(UIColor *)selectedTintColor{
    _selectedTintColor = selectedTintColor;
    [self.buttons enumerateObjectsUsingBlock: ^(JDMinimalTabBarButton *mbButton, NSUInteger idx, BOOL *stop) {
        mbButton.selectedTintColor = selectedTintColor;
    }];
}



#pragma mark Button Constraints ---

- (NSArray *)defaultConstraints {
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    [self.buttons enumerateObjectsUsingBlock: ^(JDMinimalTabBarButton *mbButton, NSUInteger idx, BOOL *stop) {
        [constraints addObject:[NSLayoutConstraint constraintWithItem:mbButton
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.f
                                                             constant:self.frame.size.width / self.numberOfViews]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:mbButton
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.f
                                                             constant:0]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:mbButton
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.f
                                                             constant:0]];
    }];
    
    if (!self.adjustableButtonConstaints) {
        self.adjustableButtonConstaints = [self defaultAdjustableConstraints];
        [constraints addObjectsFromArray:self.adjustableButtonConstaints];
    }
    return [constraints copy];
}

-(NSArray*)defaultAdjustableConstraints{
    NSMutableArray* constraints = [[NSMutableArray alloc] init];
    [self.buttons enumerateObjectsUsingBlock: ^(JDMinimalTabBarButton *mbButton, NSUInteger idx, BOOL *stop) {
        NSLayoutConstraint *adjustableConstraint = [NSLayoutConstraint constraintWithItem:self.buttons[idx]
                                                                                attribute:NSLayoutAttributeLeft
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeLeft
                                                                               multiplier:1.f
                                                                                 constant:(self.frame.size.width / self.numberOfViews) * idx];
        [constraints addObject:adjustableConstraint];
    }];
    return [constraints copy];
}



#pragma Mark Tap Button ---

- (void)touchedButton:(id)sender {
    JDMinimalTabBarButton *mbButton = (JDMinimalTabBarButton *)[sender view];
    if (!self.isDisplayingAll) {
        switch ([mbButton buttonState]) {
            case ButtonStateDisplayedInactive:
                [mbButton setButtonState:ButtonStateSelected];
                [self collapseAllButtons];
                [self.mMinimalBarDelegate changeToPageIndex:mbButton.tag];
                break;
            case ButtonStateDisplayedActive:
                [mbButton setButtonState:ButtonStateSelected];
                [self collapseAllButtons];
                [self.mMinimalBarDelegate changeToPageIndex:mbButton.tag];
                break;
            case ButtonStateSelected:
                [self displayAllButtons];
                break;
            default:
                break;
        }
    }else{
        [self.mMinimalBarDelegate displayViewAtIndex:mbButton.tag];
    }
}



#pragma Mark Visual Button Adjustments ---

- (void)collapseAllButtons {

    [self shouldEnablePanGestures:YES];
    CGFloat mbButtonWidth = self.frame.size.width / self.buttons.count;
    
    void (^alphaAnimation)() = ^{ [self hideNonSelectedMenuItems]; };
    
    void (^animations)(void) = ^{
        [self.adjustableButtonConstaints enumerateObjectsUsingBlock: ^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
            constraint.constant = mbButtonWidth * (self.adjustableButtonConstaints.count / 2);
        }];
        [self layoutIfNeeded];
    };
    
    [UIView animateWithDuration:.65f
                          delay:0.f
         usingSpringWithDamping:85
          initialSpringVelocity:12
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                     animations:animations
                     completion:nil];
    
    [UIView animateWithDuration:0.10
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:alphaAnimation
                     completion:nil];
}

- (void)displayAllButtons {
    [self shouldEnablePanGestures:NO];
    
    [self.buttons enumerateObjectsUsingBlock: ^(JDMinimalTabBarButton *mbButton, NSUInteger idx, BOOL *stop) {
        if (mbButton.buttonState == ButtonStateSelected)    mbButton.buttonState = ButtonStateDisplayedActive;
        else                                                mbButton.buttonState = ButtonStateDisplayedInactive;
    }];
    
    void (^alphaAnimations)(void) = ^{ [self showAllButtons]; };
    void (^movementAnimations)(void) = ^{
        [self.adjustableButtonConstaints enumerateObjectsUsingBlock: ^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
            constraint.constant = self.frame.size.width / self.adjustableButtonConstaints.count * idx;
        }];
        [self layoutIfNeeded];
    };
    
    [UIView animateWithDuration:.8f
                          delay:0.f
         usingSpringWithDamping:150
          initialSpringVelocity:16
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut
                     animations:movementAnimations
                     completion:nil];
    
    [UIView animateWithDuration:.4f
                          delay:0.025f
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                     animations:alphaAnimations
                     completion:nil];
}

- (void)showAllButtons {
    [self.buttons enumerateObjectsUsingBlock: ^(JDMinimalTabBarButton *mbButton, NSUInteger idx, BOOL *stop) {
        mbButton.alpha = 1.f;
    }];
}

- (void)hideNonSelectedMenuItems {
    [self.buttons enumerateObjectsUsingBlock: ^(JDMinimalTabBarButton *mbButton, NSUInteger idx, BOOL *stop) {
        if (mbButton.buttonState != ButtonStateSelected) {
            mbButton.alpha = 0.f;
        }
    }];
}

- (void)setShowTitles:(BOOL)showTitles{
    _showTitles = showTitles;
    [self.buttons enumerateObjectsUsingBlock: ^(JDMinimalTabBarButton *mbButton, NSUInteger idx, BOOL *stop) {
        mbButton.showTitle = showTitles;
    }];
}

-(void)setHidesTitlesWhenSelected:(BOOL)hidesTitlesWhenSelected{
    _hidesTitlesWhenSelected = hidesTitlesWhenSelected;
    [self.buttons enumerateObjectsUsingBlock: ^(JDMinimalTabBarButton *mbButton, NSUInteger idx, BOOL *stop) {
        mbButton.hideTitleWhenSelected = hidesTitlesWhenSelected;
    }];
}

#pragma Mark Pan Methods ---

- (void)panSelectedButton:(UIPanGestureRecognizer *)gesture {
    CGPoint translatedPoint = [gesture translationInView:self];
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        self.firstX = [[gesture view] center].x;
        self.firstY = [[gesture view] center].y;
    }
    
    //Matching swipe with scrollview
    [self.mMinimalBarDelegate manualOffsetScrollview:(self.lastXOffset - translatedPoint.x)];
    self.lastXOffset = translatedPoint.x;
    
    //Reset View center to match finger swiping
    translatedPoint = CGPointMake(self.firstX + translatedPoint.x, self.firstY);
    [[gesture view] setCenter:translatedPoint];
    
    if ([gesture state] == UIGestureRecognizerStateEnded) {
        CGPoint endingLocation = [gesture translationInView:self];
        CGFloat velocityX = (0.2 *[gesture velocityInView:self].x);
        CGFloat animationDuration = (ABS(velocityX) * .0002) + .2;
        
        if (endingLocation.x <= -50)        [self switchToPageNext:YES];
        else if (endingLocation.x >= 50)    [self switchToPageNext:NO];
        else                                [self returnScrollViewToSelectedTab];
        
        void (^animations)(void) = ^{ [[gesture view] setCenter:CGPointMake(self.firstX, self.firstY)]; };
        
        [UIView animateWithDuration:animationDuration animations:animations completion:nil];
        self.lastXOffset = 0;
    }
}

- (void)switchToPageNext:(BOOL)next {
    NSInteger indextAdjustment = next ? next : -1;
    NSInteger activeIndex = [self indexOfActiveButton];
    NSInteger targetedIndex = activeIndex + indextAdjustment;
    
    if (targetedIndex >= 0 && targetedIndex < self.buttons.count) {
        JDMinimalTabBarButton *activeButton = self.buttons[activeIndex];
        JDMinimalTabBarButton *nextButton = self.buttons[activeIndex + indextAdjustment];
        
        [activeButton setButtonState:ButtonStateDisplayedInactive];
        [nextButton setButtonState:ButtonStateSelected];
        
        [self bringSubviewToFront:nextButton];
        void (^animations)(void) = ^{
            [self.adjustableButtonConstaints enumerateObjectsUsingBlock: ^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
                if ([(JDMinimalTabBarButton *)constraint.firstItem isEqual : self.buttons[[self indexOfActiveButton]]]) {
                    constraint.constant = self.frame.size.width / 5 * 2;
                }
            }];
            activeButton.alpha = 0;
            nextButton.alpha = 1;
        };
        
        [UIView animateWithDuration:.2 animations:animations completion:nil];
        [self.mMinimalBarDelegate didSwitchToIndex:nextButton.tag];
    }
}

- (void)returnScrollViewToSelectedTab {
    NSInteger activeIndex = [self indexOfActiveButton];
    [self.mMinimalBarDelegate sendScrollViewToPoint:CGPointMake(activeIndex * self.frame.size.width, 0)];
}



#pragma Mark Touch And Hold

- (void)positionAllButtonsForOverView {
    [self shouldEnablePanGestures:NO];
    
    void (^animations)(void) = animations = ^{

        [self.adjustableButtonConstaints enumerateObjectsUsingBlock: ^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
            constraint.constant = (self.frame.size.width / self.adjustableButtonConstaints.count * idx) + (idx * 10);
        }];
        [self layoutIfNeeded];
        
        CGFloat spacingMultiplyer = ([self indexOfActiveButton] * 10);
        CGFloat defaultPosition = (self.frame.size.width - (self.frame.size.width/self.buttons.count))/2;
        CGFloat buttonOffset = [self indexOfActiveButton] * (self.frame.size.width/self.buttons.count);
        CGFloat xPosToScrollButtonsTo = defaultPosition - spacingMultiplyer - buttonOffset;
        
        self.frame = CGRectMake(xPosToScrollButtonsTo, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        
        [self showAllButtonsInOverviewMode];
    };
    
    [UIView animateWithDuration:.6f
                          delay:0.f
         usingSpringWithDamping:150
          initialSpringVelocity:15
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut
                     animations:animations
                     completion:nil];
}

- (void)showAllButtonsInOverviewMode {
    [self.buttons enumerateObjectsUsingBlock: ^(JDMinimalTabBarButton *mbButton, NSUInteger idx, BOOL *stop) {
        mbButton.buttonState = ButtonStateDisplayedInactive;
        mbButton.alpha = 1.f;
    }];
}

- (void)scrollOverviewButtonsWithPercentage:(CGFloat)offsetPercentage {
    if (self.isDisplayingAll) {
        CGFloat squareButtonDimension = self.frame.size.width / self.buttons.count;
        CGFloat defaultPosition = (self.frame.size.width - squareButtonDimension) / 2;
        CGFloat offsetAmount = offsetPercentage * (squareButtonDimension + 10);
        self.frame = CGRectMake(defaultPosition - offsetAmount, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    }
}

- (void)touchAndHold:(UIGestureRecognizer *)longPressGesture {
    if (!self.isDisplayingAll) {
        self.isDisplayingAll = YES;
        [self.mMinimalBarDelegate displayAllScreensWithStartingDisplayOn:longPressGesture.view.tag];
        [self positionAllButtonsForOverView];
    }
}



#pragma Mark Helper Methods ---

- (void)shouldEnablePanGestures:(BOOL)enable {
    [self.buttons enumerateObjectsUsingBlock: ^(JDMinimalTabBarButton *mbButton, NSUInteger idx, BOOL *stop) {
        [mbButton.gestureRecognizers enumerateObjectsUsingBlock: ^(UIGestureRecognizer *gesture, NSUInteger idx, BOOL *stop) {
            if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
                gesture.enabled = enable;
            }
        }];
    }];
}

- (NSUInteger)indexOfActiveButton {
    __block NSUInteger index = 0;
    [self.buttons enumerateObjectsUsingBlock: ^(JDMinimalTabBarButton *mbButton, NSUInteger idx, BOOL *stop) {
        if (mbButton.buttonState == ButtonStateSelected) {
            index = idx;
        }
    }];
    NSLog(@"index %ld", index);
    return index;
}

- (void)selectedButtonAtIndex:(NSInteger)index {
    [self.buttons[index] setButtonState:ButtonStateSelected];
    [self bringSubviewToFront:self.buttons[index]];
}

- (NSUInteger)numberOfViews {
    return [self.buttons count];
}

- (void)returnMenuToSelected:(NSUInteger)index {
    _isDisplayingAll = NO;
    [self selectedButtonAtIndex:index];
    [self collapseAllButtons];
}

@end
