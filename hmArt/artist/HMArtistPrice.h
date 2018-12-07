//
//  HMArtistPrice.h
//  hmArt
//
//  Created by wangyong on 13-8-13.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "LCNetworkInterface.h"
#import "HMUtility.h"

@interface HMArtistPrice : UIViewController <CPTBarPlotDataSource, CPTBarPlotDelegate>
{
    NSMutableArray *_resultArray;
    unsigned int _requestId;
    NSInteger _minPrice;
    NSInteger _maxPrice;
}

@property (nonatomic) NSInteger artistId;
@property (nonatomic, strong) CPTBarPlot *aaplPlot;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (strong, nonatomic) IBOutlet CPTGraphHostingView *hostView;
@end
