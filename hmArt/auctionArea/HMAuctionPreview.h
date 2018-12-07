//
//  HMAuctionPreview.h
//  hmArt
//
//  Created by wangyong on 14-8-25.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMGlobal.h"
#import "HMUtility.h"
#import "LCNetworkInterface.h"
#import "HMNetImageView.h"
#import "MJRefresh.h"
#import "HMAuctionDetail.h"

@interface HMAuctionPreview : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSMutableArray *_items;
    unsigned int _requestId;
    NSInteger _pageIndex;
    NSInteger _pageSize;
    NSInteger _pageCount;
}
@property (copy, nonatomic) NSString *auditDate;
@property (copy, nonatomic) NSString *titleName;
@property (nonatomic) NSInteger level;
@property (nonatomic) NSInteger areaListId;
@property (strong, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic) IBOutlet UILabel *auditDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleNameLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

- (void)setParams:(NSString *)params;

@end
