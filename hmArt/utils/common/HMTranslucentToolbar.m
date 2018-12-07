//
//  HMTranslucentToolbar.m
//  hmArt
//
//  Created by wangyong on 13-7-29.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import "HMTranslucentToolbar.h"

@implementation HMTranslucentToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.clearsContextBeforeDrawing = YES;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
