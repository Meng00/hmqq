//
//  HMPriceChart.h
//  hmArt
//
//  Created by wangyong on 13-7-26.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "HMUtility.h"

@interface HMPriceChart : UIView
{
    CALayer *linesLayer;

    NSInteger hInteval;
    
    UIView *_popView;
    
    UILabel *_showLabel;
}
@property (nonatomic) NSInteger rangeLo;
@property (nonatomic) NSInteger rangeHi;

//横竖轴显示标签
@property (nonatomic, strong) NSArray *hDesc;

//点信息
@property (nonatomic, strong) NSArray *array;

@end
