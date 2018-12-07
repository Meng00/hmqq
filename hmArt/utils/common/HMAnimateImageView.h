//
//  HMAnimateImageView.h
//  hmArt
//
//  Created by wangyong on 14-8-26.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCNetworkInterface.h"

@class HMAnimateImageView;

@protocol hmAnimateImageViewDelegate <NSObject>

@optional
- (void)animatedImageView:(HMAnimateImageView *)animatedImageView tapAtIndex:(NSInteger)index;

@end

@interface HMAnimateImageView : UIImageView
{
    BOOL _pageIncrement;
    BOOL _switching;
    NSUInteger _interval;
    NSMutableArray *_adItems;
    NSMutableArray *_requestIds;
    NSMutableArray *_adImages;
    NSUInteger _current;
}

@property (nonatomic, retain) IBOutlet id<hmAnimateImageViewDelegate> delegate;

- (void)startSwitch;
- (void)stopSwitch;
- (BOOL)isSwitching;
- (void)addItem:(NSString *)imgUrl;
- (void)setInterval:(NSUInteger)interval;

@end
