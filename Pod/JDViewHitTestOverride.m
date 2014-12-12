//
//  UIViewHitTestOverride.m
//  MinimalTabBar
//
//  Created by james.dunay on 12/3/14.
//  Copyright (c) 2014 James.Dunay. All rights reserved.
//

#import "JDViewHitTestOverride.h"

@implementation JDViewHitTestOverride

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView* child = [super hitTest:point withEvent:event];
    return child == self ? self.scrollView : child;
}

@end
