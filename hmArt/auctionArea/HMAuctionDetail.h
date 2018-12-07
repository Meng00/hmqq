//
//  HMAuctionDetail.h
//  hmArt
//
//  Created by wangyong on 14-8-27.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMNetImageView.h"
#import "LCNetworkInterface.h"
#import "HMUtility.h"
#import "HMInputController.h"
#import "HMGlobalParams.h"
#import "HMLoginEx.h"
#import "LCAlertView.h"
#import <ShareSDK/ShareSDK.h>
#import "LCWebView.h"
#import "HMImageZoomView.h"
#import "HMUpgradeVIP.h"

@interface HMAuctionDetail : HMInputController<HMImageZommViewDelegate>
{
    unsigned int _requestImageId;
    unsigned int _requestId;
    NSDictionary *_auction;
    
    NSTimer *_timer;
    NSUInteger _remainSeconds;

    NSInteger _pageIndex;
    NSInteger _pageSize;
    NSInteger _totalCount;
    NSMutableArray *_auctionRecords;
    NSTimer *_recordTimer;
    
    NSInteger _stepPrice;   //每次加价幅度
    unsigned long long _curPrice;    //当前最新价
    unsigned long long _inputPrice;  //目前文本框的出价
    NSInteger _initPrice;
    
    unsigned int _requestBidId;
    unsigned int _requestUpgradeId;
    
    BOOL _haveRead;
    BOOL _toRead;
    
    BOOL _hiddenBar;
    
    BOOL _vipLevel;
    
}

@property (copy, nonatomic) NSString *fenxiangContext;
@property (copy, nonatomic) NSString *code;
@property (nonatomic) NSInteger level;
@property (nonatomic) NSInteger source;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet HMNetImageView *pictureImageView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (strong, nonatomic) IBOutlet UIScrollView *auctionScrollView;
@property (strong, nonatomic) IBOutlet HMNetImageView *auctionImageView;
@property (strong, nonatomic) IBOutlet UIView *historyContentView;
@property (strong, nonatomic) IBOutlet UITextField *priceInput;
@property (strong, nonatomic) IBOutlet UILabel *auctionNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *auctionPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeRemainLabel;
@property (strong, nonatomic) IBOutlet UILabel *myPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *initialPriceLabel;
@property (strong, nonatomic) IBOutlet UIView *auctionContentView;
@property (strong, nonatomic) IBOutlet UILabel *stepPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *depositLabel;
@property (strong, nonatomic) IBOutlet UILabel *commissionLabel;
@property (strong, nonatomic) IBOutlet UIView *bidderRecordsView;
@property (strong, nonatomic) IBOutlet UIImageView *moreImageView;
@property (strong, nonatomic) IBOutlet UIView *infoView;
@property (strong, nonatomic) IBOutlet UILabel *descLabel;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UILabel *drawTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *sizeLabel;
@property (strong, nonatomic) IBOutlet UIView *upgradeView;
@property (strong, nonatomic) IBOutlet UIButton *haveReadButton;
@property (strong, nonatomic) IBOutlet UILabel *haveReadLabel;
@property (strong, nonatomic) IBOutlet UIView *biddingView;
@property (strong, nonatomic) IBOutlet UIView *fullImageView;
@property (strong, nonatomic) IBOutlet UILabel *showBidNoticeLabel;

- (IBAction)priceChanged:(id)sender;
- (IBAction)stepButtonDown:(UIButton *)sender;
- (IBAction)bidButtonDown:(id)sender;
- (IBAction)upgradeButtonDown:(id)sender;
- (IBAction)shareButtonDown:(id)sender;
- (IBAction)haveReadButtonDown:(id)sender;
@end
