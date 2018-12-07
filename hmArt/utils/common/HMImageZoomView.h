//
//  HMImageZoomView.h
//  hmArt
//
//  Created by wangyong on 14-9-12.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCNetworkInterface.h"

@protocol HMImageZommViewDelegate <NSObject>

- (void)imageTapedWithObject:(id)sender;

@end

@interface HMImageZoomView : UIScrollView <UIScrollViewDelegate>
{
    UIImageView *imgView;
    
    //记录自己的位置
    CGRect scaleOriginRect;
    
    //图片的大小
    CGSize imgSize;
    
    //缩放前大小
    CGRect initRect;
    
}

@property (nonatomic, retain) id<HMImageZommViewDelegate> zoomDelegate;

- (void) setContentWithFrame:(CGRect) rect;
- (void) setImage:(UIImage *) image;
- (void) setAnimationRect;
- (void) rechangeInitRdct;
- (void) startLoadImage;
- (void) stopLoadImage;

@end
