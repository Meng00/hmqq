//
//  HMMemberCoupon.h
//  hmArt
//
//  Created by wangyong on 14-8-14.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttributedLabel.h"
#import "LCWebView.h"
#import "HMNetImageView.h"
#import "LCNetworkInterface.h"
#import "MJRefresh.h"

@interface HMMemberCoupon : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSMutableArray *_items;
    unsigned int _requestId;
    NSInteger _pageIndex;
    NSInteger _pageSize;
    NSInteger _pageCount;
    NSInteger _total;
}

@property (strong, nonatomic) IBOutlet AttributedLabel *countLabel;
@property (strong, nonatomic) IBOutlet UILabel *noticeLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIView *titleView;
@end
