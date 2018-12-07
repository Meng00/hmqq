//
//  HMArtistInfoList.h
//  hmArt
//
//  Created by wangyong on 13-7-12.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"
#import "LCNetworkInterface.h"

@interface HMArtistInfoList : UIViewController<UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate>
{
    unsigned int _requestId;
    NSMutableArray *_resultArray;
    
    //分页参数
    NSInteger _pageIndex;
    NSInteger _pageSize;
    NSInteger _pageCount;
    
    NSString *_infoStr;
    NSInteger _typeForMarco;
}
@property (nonatomic) NSInteger artistId;
@property (nonatomic) NSInteger infoType;
@property (strong, nonatomic) IBOutlet PullTableView *resultTable;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (copy, nonatomic) NSString *artistName;
@end
