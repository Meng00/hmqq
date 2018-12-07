//
//  HMSalesOrder.h
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
#import "HMAuctionDetail.h"
#import "HMRecharge.h"

@interface HMSalesOrder : UIViewController<UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate>
{
    unsigned int _requestId;
    unsigned int _requestId2;
    BOOL _dataLoaded;
    NSMutableArray *_resultArray;
    
    //分页参数
    NSInteger _pageIndex;
    NSInteger _pageSize;
    NSInteger _pageCount;
    
    LCView *_topView;
    UILabel *_button1;
    UILabel *_button2;
    
    NSInteger _searchType;//1：申请；2：竞买订单
    
    
    
}

@property (strong, nonatomic) IBOutlet PullTableView *resultTable;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end
