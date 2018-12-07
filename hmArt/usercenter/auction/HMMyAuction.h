//
//  HMMyAuction.h
//  hmArt
//
//  Created by 刘学 on 15/7/20.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"
#import "LCView.h"
#import "HMUtility.h"
#import "HMGlobalParams.h"
#import "LCNetworkInterface.h"
#import "HMNetImageView.h"
#import "MJRefresh.h"

#import "HMAuctionDetail.h"

@interface HMMyAuction : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>
{
    unsigned int _requestId;
    unsigned int _requestDoingRefreshId;
    
    NSMutableArray *_resultArray;
    NSMutableArray *_countSecondsArray;
    
    //分页参数
    NSInteger _pageIndex;
    NSInteger _pageSize;
    NSInteger _pageCount;
    
    NSTimer *_timer;
}

@property (strong, nonatomic) IBOutlet UICollectionView *myAuctCollectionView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;


@end
