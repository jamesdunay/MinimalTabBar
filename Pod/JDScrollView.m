//
//  JDScrollView.m
//  Boards
//
//  Created by James Dunay on 1/23/16.
//  Copyright © 2016 James Dunay. All rights reserved.
//

#import "JDScrollView.h"

@implementation JDScrollView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.subviews each:^(UIView *view) {
        if (CGRectGetHeight(view.frame) != CGRectGetHeight(self.frame)) {
            view.frame = CGRectMake(view.frame.origin.x, 0, view.frame.size.width, self.frame.size.height);
        }
    }];
}

@end
