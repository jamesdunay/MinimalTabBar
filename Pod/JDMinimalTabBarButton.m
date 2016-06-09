//
//  MinimalButton.m
//  MinimalTabBar
//
//  Created by james.dunay on 12/7/14.
//  Copyright (c) 2014 James.Dunay. All rights reserved.
//

#import "JDMinimalTabBarButton.h"
#import "BDZSpinner.h"

@interface JDMinimalTabBarButton()
@property (nonatomic, strong) BDZSpinner *spinner;
@property (nonatomic, strong) UIImage *defaultImage;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic) BOOL isAnimating;
@end

@implementation JDMinimalTabBarButton

- (instancetype)initWithButtonWithTabBarItem:(UITabBarItem*)tabBarItem{
    self = [super init];
    if (self) {
        
        self.tag = tabBarItem.tag;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _buttonState = ButtonStateDisplayedInactive;
        
        self.spinner = [BDZSpinner new];
        [[self imageView] setContentMode:UIViewContentModeScaleAspectFit];
        
        self.defaultImage = tabBarItem.image;
        self.selectedImage = tabBarItem.selectedImage;
        
        [self setImage:self.defaultImage forState:UIControlStateNormal];
        [self setImage:self.selectedImage forState:UIControlStateSelected];
        
        _title = [[UILabel alloc] init];
        _title.text = tabBarItem.title;
        _title.font = [UIFont fontWithName:@"Avenir-Heavy" size:10.f];
        _title.textColor = [UIColor whiteColor];
        [_title sizeToFit];

        _spinner.translatesAutoresizingMaskIntoConstraints = NO;
        _title.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_title];
        [self addSubview:_spinner];
        
        [self addConstraints:[self defaultConstraints]];
    }
    return self;
}


- (NSArray*)defaultConstraints{
    
    NSMutableArray* constraints = [[NSMutableArray alloc] init];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_title
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.f
                                                          constant:-5]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_title
                                                        attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self
                                                        attribute:NSLayoutAttributeCenterX
                                                       multiplier:1.f
                                                         constant:0]];
    
    [self.spinner autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self withOffset:-6];
    [self.spinner autoAlignAxis:ALAxisVertical toSameAxisOfView:self withOffset:1];
    return [constraints copy];
}

- (void)setButtonState:(ButtonState)buttonState{
    _buttonState = buttonState;
    
    switch (buttonState) {
        case ButtonStateDisplayedActive:
            [self setButtonToTintColor:_selectedTintColor];
            [self setSelected:NO];
            break;
            
        case ButtonStateDisplayedInactive:
            [self setButtonToTintColor:_defaultTintColor];
            [self setSelected:NO];
            break;
            
        case ButtonStateSelected:
            [self setButtonToTintColor:_selectedTintColor];
            [self setSelected:YES];
            break;
            
        default:
            break;
    }
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (_hideTitleWhenSelected) {
        _title.hidden = !_showTitle || selected;
    }
}

- (void)setHighlighted:(BOOL)highlighted{
// Need to disable Highlighting to keep icon from flicker
}

- (void)setDefaultTintColor:(UIColor *)defaultTintColor{
    _defaultTintColor = defaultTintColor;
    [self setButtonToTintColor:defaultTintColor];
}

- (void)setSelectedTintColor:(UIColor *)selectedTintColor{
    _selectedTintColor = selectedTintColor;
}

- (void)setButtonToTintColor:(UIColor*)tintColor{
    _title.textColor = tintColor;
    self.imageView.tintColor = tintColor;
}

- (void)setShowTitle:(BOOL)showTitle{
    _showTitle = showTitle;
    _title.hidden = !showTitle;
}

- (void)showSpinner
{
    [self setImage:nil forState:UIControlStateNormal];
    [self setImage:nil forState:UIControlStateSelected];
    
    [UIView animateWithDuration:.15 animations:^{
        self.tintColor = [UIColor colorWithWhite:1. alpha:0.];
    }];

    [self.spinner startAnimating];
}

- (void)hideSpinner
{
    [self setImage:self.defaultImage forState:UIControlStateNormal];
    [self setImage:self.selectedImage forState:UIControlStateSelected];
    [self.spinner stopAnimating];
}


@end
