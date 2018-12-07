//
//  HMPictureList.h
//  hmArt
//
//  Created by wangyong on 13-7-12.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"
#import "LCNetworkInterface.h"
#import "HMPictureCell.h"
#import "HMUtility.h"
#import "HMPaintingDetail.h"

@interface HMPictureList : UIViewController<UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate>
{
    unsigned int _requestId;
    BOOL _dataLoaded;
    NSMutableArray *_resultArray;
    
    //分页参数
    NSInteger _pageIndex;
    NSInteger _pageSize;
    NSInteger _pageCount;
    
    NSString *_infoStr;
    
    NSMutableDictionary *_searchParams;
    
    NSString *_nameStr;
    NSString *_composerStr;
    NSString *_minPriceStr;
    NSString *_maxPriceStr;
    
}
@property (nonatomic) NSInteger pictureType; //作品类型kPictureType,1-待售；2-已售；3-精品
@property (nonatomic) NSInteger groupType;  //0-画家，1-画廊
@property (nonatomic) NSInteger artistId;
@property (nonatomic) NSInteger categoryId; //画廊分类id
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic) BOOL searchForSale;
@property (nonatomic, copy) NSString *minPrice;
@property (nonatomic, copy) NSString *maxPrice;

@property (strong, nonatomic) IBOutlet PullTableView *resultTable;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

- (void)setParams:(NSString *)params;
@end
