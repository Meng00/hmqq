//
//  HMArtistList.h
//  hmArt
//
//  Created by wangyong on 13-7-11.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"
#import "LCNetworkInterface.h"
#import "HMUtility.h"
#import "HMArtistDetail.h"

@interface HMArtistList : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, PullTableViewDelegate>
{
    unsigned int _requestId;
    NSMutableArray *_resultArray; 
    
    //分页参数
    NSInteger _pageIndex;
    NSInteger _pageSize;
    NSInteger _pageCount;

}

@property (copy, nonatomic) NSString *keyword;
@property (copy, nonatomic) NSString *area;

@property (strong, nonatomic) IBOutlet PullTableView *resultTable;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@end
