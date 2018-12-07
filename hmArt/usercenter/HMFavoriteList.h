//
//  HMFavoriteList.h
//  hmArt
//
//  Created by wangyong on 13-6-16.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"
#import "LCNetworkInterface.h"
#import "HMUtility.h"
#import "HMPictureCell.h"
#import "HMGlobalParams.h"
#import "HMLoginEx.h"
#import "HMPaintingDetail.h"

@interface HMFavoriteList : UIViewController<UITableViewDelegate,UITableViewDelegate, PullTableViewDelegate>
{
    unsigned int _requestId;
    NSMutableArray *_resultArray;
    
    //分页参数
    NSInteger _pageIndex;
    NSInteger _pageSize;
    NSInteger _pageCount;
    
    NSIndexPath *_curIndexPath;

}
@property (strong, nonatomic) IBOutlet PullTableView *resultTable;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@end
