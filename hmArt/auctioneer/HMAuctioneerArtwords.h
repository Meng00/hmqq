//
//  HMAuctioneerArtwords.h
//  hmArt
//
//  Created by 刘学 on 15-7-7.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"
#import "LCNetworkInterface.h"
#import "HMPictureCell.h"
#import "HMUtility.h"
#import "HMPaintingDetail.h"
#import "LCView.h"
#import "HMArtworkDetail.h"
#import "HMAuctioneerArtwordDetail.h"

@interface HMAuctioneerArtwords : UIViewController<UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate>
{
    unsigned int _requestId;
    BOOL _dataLoaded;
    NSMutableArray *_resultArray;
    
    //分页参数
    NSInteger _pageIndex;
    NSInteger _pageSize;
    NSInteger _pageCount;
    
    
}
@property (nonatomic) NSInteger auctioneerId;
@property (copy, nonatomic) NSString *auctioneerName;
@property (copy, nonatomic) NSString *auctioneerImage;
@property (strong, nonatomic) IBOutlet PullTableView *resultTable;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;


@end
