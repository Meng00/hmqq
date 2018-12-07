//
//  HMAuctionArea.h
//  hmArt
//
//  Created by wangyong on 14-8-18.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMUtility.h"
#import "HMGlobal.h"
#import "PullTableView.h"
#import "LCNetworkInterface.h"
#import "MJRefresh.h"
#import "HMTransactionRecordCell.h"
#import "HMAnimateImageView.h"
#import "HMAuctionPreview.h"
#import "HMAuctionDetail.h"
#import "HMAuctSearch.h"
#import "JSDropDownMenu.h"

@interface HMAuctionArea : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, hmAnimateImageViewDelegate,JSDropDownMenuDataSource,JSDropDownMenuDelegate,UISearchBarDelegate>
{
    
    NSInteger _searchType;
    
    unsigned int _requestDoingId;
    unsigned int _requestDoingRefreshId;
    unsigned int _requestDoneId;
    unsigned int _requestWillDoId;
    unsigned int _requestWillDoRecId;
    unsigned int _requestLabelId;
    NSMutableArray *_resultDoingArray;
    NSMutableArray *_countSecondsArray;
    NSMutableArray *_countGroupSecondsArray;

    NSMutableArray *_resultDoneArray;
    NSMutableArray *_resultWillDoArray;
    NSMutableArray *_resultWillDoGroupArray;
    //分页参数
    NSInteger _pageDoingIndex;
    NSInteger _pageDoingSize;
    NSInteger _pageDoingCount;

    NSInteger _pageDoneIndex;
    NSInteger _pageDoneSize;
    NSInteger _pageDoneCount;
    
    NSInteger _pageWillDoIndex;
    NSInteger _pageWillDoSize;
    NSInteger _pageWillDoCount;

    NSTimer *_timer;
    NSTimer *_timer2;
    
    UIBarButtonItem *_rightButton;
    
    NSMutableArray *_timeArray;
    NSMutableArray *_sortArray;
    NSInteger _curTimeIndex;
    NSInteger _curTimeId;
    NSInteger _curSortIndex;
    NSInteger _curSortId;
    NSInteger _curPriceIndex;
    NSInteger _curTypeIndex;
    NSString *_keyword;
    
    JSDropDownMenu *menu;
    NSMutableArray *_data1;
    NSMutableArray *_data2;
    NSMutableArray *_data3;
    NSMutableArray *_data4;
    
//    NSInteger _currentData1Index;
//    NSInteger _currentData2Index;
//    NSInteger _currentData3Index;
//    NSInteger _currentData4Index;
    
    UIButton *_btnAccessoryView;// 遮盖层
}

@property (nonatomic) NSInteger level;
@property (nonatomic, strong) NSString *viewTitle;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (strong, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic) IBOutlet UILabel *auctionDoing;
@property (strong, nonatomic) IBOutlet UILabel *auctionDone;
@property (strong, nonatomic) IBOutlet UILabel *auctionWillDo;
@property (strong, nonatomic) IBOutlet UIView *doingView;
@property (strong, nonatomic) IBOutlet UIView *willDoView;
@property (strong, nonatomic) IBOutlet UIView *doneView;
@property (strong, nonatomic) IBOutlet UICollectionView *doingCollectionView;
//@property (strong, nonatomic) IBOutlet UICollectionView *willDoCollectionView;
@property (strong, nonatomic) IBOutlet UITableView *willDoTable;
@property (strong, nonatomic) IBOutlet UITableView *doneTable;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (strong, nonatomic) IBOutlet HMAnimateImageView *willDoRecImage;


- (void)setParams:(NSString *)params;
@end
