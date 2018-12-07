//
//  HMAuctionRecords.h
//  hmArt
//
//  Created by wangyong on 14-8-12.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMGlobal.h"
#import "HMUtility.h"
#import "HMMemberAuctionRecords.h"
#import "HMGlobalParams.h"
#import "HMLoginEx.h"
#import "PullTableView.h"
#import "HMTransactionRecordCell.h"
#import  "HMAuctionDetail.h"
#import "HMAuctionSearch.h"

@interface HMAuctionRecords : UIViewController<UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate, auctionsSearchDelegate>
{
    unsigned int _requestId;
    NSMutableArray *_resultArray;
    
    //分页参数
    NSInteger _pageIndex;
    NSInteger _pageSize;
    NSInteger _pageCount;
    

}
@property(copy,nonatomic) NSString *area;
@property(copy,nonatomic) NSString *startTime;
@property(copy,nonatomic) NSString *endTime;
@property(copy,nonatomic) NSString *artName;
@property(copy,nonatomic) NSString *artist;
@property(copy,nonatomic) NSString *code;
@property(nonatomic) NSInteger type;
@property (strong, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic) IBOutlet PullTableView *resultTable;
@property (strong, nonatomic) IBOutlet UILabel *searchLabel;
@property (strong, nonatomic) IBOutlet UILabel *memberAuditLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@end
