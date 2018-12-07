//
//  HMModalBaseView.m
//  hmArt
//
//  Created by wangyong on 13-7-7.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import "HMModalBaseView.h"
#import <QuartzCore/QuartzCore.h>

@implementation HMModalBaseView

- (id)initWithTap2Close:(BOOL)close
{
    CGRect frame = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self reset];
        
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        //        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        //        self.layer.borderWidth = 2;
        self.autoresizesSubviews = NO;
        
        _close = close;
        _mockView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _mockView.backgroundColor = [UIColor whiteColor];
        _mockView.layer.borderColor = [UIColor whiteColor].CGColor;
        _mockView.layer.borderWidth = 2;
        _mockView.autoresizesSubviews = NO;
        
        UITapGestureRecognizer *mock = [[UITapGestureRecognizer alloc] initWithTarget:nil action:nil];
        [_mockView addGestureRecognizer:mock];
        [self addSubview:_mockView];
        
        _customizeSize = NO;
        _radius = 10;
    }
    return self;
}

- (void)dealloc
{
    [_mockView removeFromSuperview];
    _mockView = nil;
}

- (void)reset
{
    _customizeSize = NO;
    _backgroundColorForMockView = [UIColor whiteColor];
    _borderColorForMockView = [UIColor whiteColor];
    _radius = 10;
    _close = NO;
}

- (void)setDialogSize:(CGSize)dialogSize
{
    _dialogSize = dialogSize;
    _customizeSize = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_close) {
        for (UIView * v in _mockView.subviews) {
            [v removeFromSuperview];
        }
        [self removeFromSuperview];
    }
}

- (void)setModalView:(UIView *)view baseView:(UIView *)rootView
{
    CGPoint offset = CGPointMake(0, 0);
    
    if ([rootView isKindOfClass:[UIScrollView class]]) {
        // 是scrollview，计算覆盖的内容大小
        UIScrollView *sv = (UIScrollView *)rootView;
        CGFloat h = (sv.contentSize.height > self.frame.size.height) ? sv.contentSize.height : self.frame.size.height;
        CGFloat w = (sv.contentSize.width > self.frame.size.width) ? sv.contentSize.width : self.frame.size.width;
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, w, h);
        offset = sv.contentOffset;
    }
    
    if (_customizeSize) {
        CGFloat x = (rootView.frame.size.width - _dialogSize.width) / 2 - _radius;
        CGFloat y = (rootView.frame.size.height - _dialogSize.height) / 2 - _radius;
        x += offset.x;
        y += offset.y;
        
        if (x < 0) x = 0;
        if (y < 0) y = 0;
        
        _mockView.frame = CGRectMake(x, y, _dialogSize.width + _radius * 2, _dialogSize.height + _radius * 2);
    } else {
        CGFloat w = (view.frame.size.width < LC_BACKGROUNDVIEW_MAX_WIDTH) ?
        view.frame.size.width + _radius * 2 : LC_BACKGROUNDVIEW_MAX_WIDTH;
        
        CGFloat h = (view.frame.size.width < LC_BACKGROUNDVIEW_MAX_HEIGHT) ?
        view.frame.size.height + _radius * 2 : LC_BACKGROUNDVIEW_MAX_HEIGHT;
        
        CGFloat x = (rootView.frame.size.width - w) / 2 - _radius;
        CGFloat y = (rootView.frame.size.height - h) / 2 - _radius;
        
        x += offset.x;
        y += offset.y;
        
        if (x < 0) x = 0;
        if (y < 0) y = 0;
        
        _mockView.frame = CGRectMake(x, y, w, h);
    }
    
    _mockView.backgroundColor = _backgroundColorForMockView;
    _mockView.layer.borderColor = _borderColorForMockView.CGColor;
    
    UIEdgeInsets inset = UIEdgeInsetsMake(_radius, _radius, _radius, _radius);
    _mockView.contentInset = inset;
    _mockView.contentSize = view.frame.size;
    _mockView.showsHorizontalScrollIndicator = YES;
    _mockView.showsVerticalScrollIndicator = YES;
    _mockView.scrollEnabled = YES;
    
    _mockView.layer.cornerRadius = _radius;
    
    view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    [_mockView addSubview:view];
    
    [rootView addSubview:self];
}

@end
