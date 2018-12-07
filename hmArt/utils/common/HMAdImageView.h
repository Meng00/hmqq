//
//  HMAdImageView.h
//  hmArt
//
//  Created by wangyong on 14-8-17.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCNetworkInterface.h"
#import "HMGlobalParams.h"
#import "HMJSWebView.h"

@interface HMAdImageView : UIImageView
{
    BOOL _pageIncrement;
    BOOL _switching;
    NSUInteger _interval;
    NSMutableArray *_adItems;
    NSMutableArray *_requestIds;
    NSMutableArray *_adImages;
    NSUInteger _current;
//    UIViewController *_parentController;
}

@property (strong, nonatomic) IBOutlet UIViewController *parent;
//- (void)setParent:(UIViewController *)parent;
- (void)startSwitch;
- (void)stopSwitch;
- (BOOL)isSwitching;
- (void)addItem:(NSDictionary *)ad;
- (void)setInterval:(NSUInteger)interval;
@end
