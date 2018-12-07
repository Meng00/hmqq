//
//  HMModalBaseView.h
//  hmArt
//
//  Created by wangyong on 13-7-7.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LC_BACKGROUNDVIEW_MAX_WIDTH 280
#define LC_BACKGROUNDVIEW_MAX_HEIGHT 440

@interface HMModalBaseView : UIView
{
    BOOL _customizeSize;
    UIScrollView *_mockView;
}

@property (nonatomic) CGSize dialogSize;

@property (nonatomic) CGFloat radius;

@property (nonatomic, copy) UIColor *backgroundColorForMockView;

@property (nonatomic, copy) UIColor *borderColorForMockView;

@property (nonatomic) BOOL close;

- (id)initWithTap2Close:(BOOL)close;

- (void)reset;

- (void)setModalView:(UIView *)view baseView:(UIView *)rootView;

@end
