//
//  HMMain.h
//  hmArt
//
//  Created by wangyong on 14-8-12.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMUtility.h"
#import "HMAdImageView.h"
#import "LCNetworkInterface.h"
#import "HMNetImageView.h"
#import "HMUserCenter.h"
#import "HMGlobalParams.h"
#import "HMMemberPoints.h"
#import "LCView.h"
#import "HMArtistList.h"
#import "HMGalleryCategory.h"
#import "HMAuctioneerHome.h"
#import "HMAuctionArea.h"
#import "HMJSWebView.h"
#import "HMHome.h"

@interface HMMain : UIViewController
{
    unsigned int _requestAreaId;
    unsigned int _requestAdId;
    unsigned int _requestId;
    unsigned int _requestVersionId;
    NSMutableArray *_funcItems;
    NSMutableArray *_areaItems;
    NSDictionary *ahDic;
    LCView *_topView;//
    
    NSMutableArray *_ahItems;//中间区域广告
    NSUInteger _ahCurrent;
}
@property (strong, nonatomic) IBOutlet HMAdImageView *adImageView;
@property (strong, nonatomic) IBOutlet UIImageView *memberImage;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;
@property (strong, nonatomic) IBOutlet UIImageView *pointsImage;
@end
