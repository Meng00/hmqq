//
//  HMPriceTrend.h
//  hmArt
//
//  Created by wangyong on 13-7-26.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCNetworkInterface.h"
#import "HMUtility.h"

@interface HMPriceTrend : UIViewController
{
    unsigned int _requestId;
    NSMutableArray *_resultArray;
    NSUInteger _totalCount;
    
    NSMutableArray *_valueArray;
    NSMutableArray *_hArray;
}
@property (nonatomic) NSInteger artistId;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@end
