//
//  HMMemberPointProduct.h
//  hmArt
//
//  Created by wangyong on 14-8-14.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"
#import "HMGlobal.h"
#import "HMNetImageView.h"
#import "HMUtility.h"
#import "HMPointsProductCell.h"
#import "LCAlertView.h"
#import "AttributedLabel.h"
#import "HMLoginEx.h"
#import "HMImageZoomView.h"

@interface HMMemberPointProduct : UIViewController<UITableViewDataSource, UITableViewDelegate, HMImageZommViewDelegate,  PullTableViewDelegate>
{
    unsigned int _requestId;
    unsigned int _requestImageId;
    NSMutableArray *_resultArray;
    
    //分页参数
    NSInteger _pageIndex;
    NSInteger _pageSize;
    NSInteger _pageCount;
    
    unsigned int _requestPointsId;
    NSInteger _myPoints;
    
    NSInteger _exchangeTag;
    
    BOOL _hiddenBar;
}
@property (nonatomic, copy) NSString *categoryName;
@property (nonatomic) NSInteger categoryId;
@property (strong, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet PullTableView *resultTable;
@property (strong, nonatomic) IBOutlet AttributedLabel *pointTitleLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (strong, nonatomic) IBOutlet UIView *confirmView;
@property (strong, nonatomic) IBOutlet AttributedLabel *myPointsLabel;
@property (strong, nonatomic) IBOutlet UILabel *productIdLabel;
@property (strong, nonatomic) IBOutlet UILabel *exchangePointsLabel;
@property (strong, nonatomic) IBOutlet UILabel *remainPointsLabel;
@property (strong, nonatomic) IBOutlet UIView *fullImageView;
- (IBAction)exchangeButtonDown:(id)sender;
- (IBAction)cancelButtonDown:(id)sender;
@end
