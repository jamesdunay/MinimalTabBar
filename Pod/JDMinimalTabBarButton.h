//
//  MinimalButton.h
//  MinimalTabBar
//
//  Created by james.dunay on 12/7/14.
//  Copyright (c) 2014 James.Dunay. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ButtonStateDisplayedInactive = (1 << 0),
    ButtonStateSelected = (1 << 1),
    ButtonStateDisplayedActive = (1 << 2)
} ButtonState;



@interface JDMinimalTabBarButton : UIButton

@property (nonatomic) ButtonState buttonState;

@property (nonatomic, strong) UIColor* selectedTintColor;
@property (nonatomic, strong) UIColor* defaultTintColor;
@property (nonatomic) UILabel* title;
@property (nonatomic) BOOL showTitle;
@property (nonatomic) BOOL hideTitleWhenSelected;

-(id)initWithButtonWithTabBarItem:(UITabBarItem*)tabBarItem;

@end