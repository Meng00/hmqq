//
//  HMUserCenter.h
//  hmArt
//
//  Created by wangyong on 13-6-16.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCNetworkInterface.h"
#import "HMLoginEx.h"
#import "HMUserInfo.h"
#import "HMMemberCoupon.h"
#import "HMMemberPointLog.h"
#import "HMMemberAuctionRecords.h"
#import "HMMemberFeedback.h"
#import "HMFavoriteList.h"
#import "LCActionSheet.h"
#import "HMAuctOrders.h"
#import "HMMyAuction.h"
#import "HMUpgradeVIP.h"
#import "HMSalesOrder.h"
#import "HMSellerReg.h"

@interface HMUserCenter : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    unsigned int _requestId;
    unsigned int _requestAuctionsId;
    unsigned int _requestVouchersId;
    NSInteger _unreadCount;
    NSInteger _unreadVouchersCount;
    NSInteger _unreadAuctionsCount;
    
    BOOL _haveRead;
    BOOL _toRead;
    unsigned int _requestUpgradeId;

}
- (IBAction)callButtonDown:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *resultTable;
@property (strong, nonatomic) IBOutlet UILabel *mobileLabel;
@property (strong, nonatomic) IBOutlet UILabel *levelLabel;
@property (strong, nonatomic) IBOutlet UIImageView *levelImage;
@property (strong, nonatomic) IBOutlet UIButton *btnUpgrade;
- (IBAction)btnUpgradeDown:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *upgradeView;
@property (strong, nonatomic) IBOutlet UIButton *haveReadButton;
@property (strong, nonatomic) IBOutlet UILabel *showBidNoticeLabel;
- (IBAction)upgradeButtonDown:(id)sender;
- (IBAction)haveReadButtonDown:(id)sender;
@end
