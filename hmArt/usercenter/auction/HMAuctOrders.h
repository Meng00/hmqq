//
//  HMAuctOrders.h
//  hmArt
//
//  Created by 刘学 on 15-7-7.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"
#import "LCView.h"
#import "HMUtility.h"
#import "HMGlobalParams.h"
#import "LCNetworkInterface.h"
#import "HMNetImageView.h"
#import "HMAuctOrderDetail.h"
#import "HMAuctOrderPayment.h"

@interface HMAuctOrders : UIViewController<UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate>
{
    unsigned int _requestId;
    BOOL _dataLoaded;
    NSMutableArray *_resultArray;
    
    //分页参数
    NSInteger _pageIndex;
    NSInteger _pageSize;
    NSInteger _pageCount;
    
    LCView *_topView;
    UILabel *_button1;
    UILabel *_button2;
    UILabel *_button3;
    UILabel *_button4;
    
    LCView *_amountView;
    UILabel *_count;
    UILabel *_amount;
    UILabel *_line;
    
    NSInteger _searchType;//1：待支付；2：待发货：3：待收货；4：全部
    
    
    
}

@property (strong, nonatomic) IBOutlet PullTableView *resultTable;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end
