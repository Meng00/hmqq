//
//  HMMemberAuctionRecords.h
//  hmArt
//
//  Created by wangyong on 14-8-14.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"
#import "HMUtility.h"
#import "LCAlertView.h"
#import "HMGlobal.h"
#import "HMAuctionRecordCell.h"
#import  "HMAuctionDetail.h"
@interface HMMemberAuctionRecords : UIViewController<UITableViewDelegate, UITableViewDataSource, PullTableViewDelegate>
{
    unsigned int _requestId;
    unsigned int _requestMoneyId;
    NSMutableArray *_resultArray;
    
    //分页参数
    NSInteger _pageIndex;
    NSInteger _pageSize;
    NSInteger _pageCount;
    NSInteger  _counts;
    
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@property (strong, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic) IBOutlet PullTableView *resultTable;
@property (strong, nonatomic) IBOutlet UILabel *moneyLabel;
@property (strong, nonatomic) IBOutlet UILabel *timesLabel;
@end
