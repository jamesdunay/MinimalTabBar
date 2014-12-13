//
//  MinimalButton.m
//  MinimalTabBar
//
//  Created by james.dunay on 12/7/14.
//  Copyright (c) 2014 James.Dunay. All rights reserved.
//

#import "JDMinimalTabBarButton.h"

@implementation JDMinimalTabBarButton

-(id)initWithButtonWithTabBarItem:(UITabBarItem*)tabBarItem{
    self = [super init];
    if (self) {
        
        self.tag = tabBarItem.tag;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _buttonState = ButtonStateDisplayedInactive;
        
        [[self imageView] setContentMode:UIViewContentModeScaleAspectFit];

        UIImage *defaultImage = [tabBarItem.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage *selectedImage = [tabBarItem.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        [self setImage:defaultImage forState:UIControlStateNormal];
        [self setImage:selectedImage forState:UIControlStateSelected];
        
        _title = [[UILabel alloc] init];
        _title.translatesAutoresizingMaskIntoConstraints = NO;
        _title.text = tabBarItem.title;
        _title.font = [UIFont fontWithName:@"Avenir-Heavy" size:10.f];
        _title.textColor = [UIColor whiteColor];
        [_title sizeToFit];
        
        [self addSubview:_title];
        
        [self addConstraints:[self defaultConstraints]];
    }
    return self;
}


-(NSArray*)defaultConstraints{
    
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
    
    return [constraints copy];
}

-(void)setButtonState:(ButtonState)buttonState{
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

-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (_hideTitleWhenSelected) {
        _title.hidden = selected;
    }
}

-(void)setHighlighted:(BOOL)highlighted{
// Need to disable Highlighting to keep icon from flicker
}

-(void)setDefaultTintColor:(UIColor *)defaultTintColor{
    _defaultTintColor = defaultTintColor;
    [self setButtonToTintColor:defaultTintColor];
}

-(void)setSelectedTintColor:(UIColor *)selectedTintColor{
    _selectedTintColor = selectedTintColor;
}

-(void)setButtonToTintColor:(UIColor*)tintColor{
    _title.textColor = tintColor;
    self.imageView.tintColor = tintColor;
}

-(void)setShowTitle:(BOOL)showTitle{
    _showTitle = showTitle;
    _title.hidden = !showTitle;
}



@end
