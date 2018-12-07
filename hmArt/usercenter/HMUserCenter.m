//
//  HMUserCenter.m
//  hmArt
//
//  Created by wangyong on 13-6-16.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import "HMUserCenter.h"
#import "HMGlobalParams.h"
#import "LCAlertView.h"
#import "HMFavoriteList.h"

@interface HMUserCenter ()

@end

@implementation HMUserCenter

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"会员中心";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"view_bg.png"]]];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    
    CGRect rect = _resultTable.frame;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - HM_SYS_VIEW_OFFSET;
    _resultTable.frame = rect;

   // 右侧按钮
    UIBarButtonItem *okButton =  [[UIBarButtonItem alloc] initWithTitle:@"退出登录" style:UIBarButtonItemStyleDone target:self action:@selector(exitButtonDown:)];
    okButton.style = UIBarButtonItemStyleDone;
    
    self.navigationItem.rightBarButtonItem = okButton;

    _unreadCount = 0;
  
    UITapGestureRecognizer *tapHaveRead = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHaveRead:)];
    tapHaveRead.numberOfTapsRequired = 1;
    tapHaveRead.numberOfTouchesRequired = 1;
    _showBidNoticeLabel.userInteractionEnabled = YES;
    [_showBidNoticeLabel addGestureRecognizer:tapHaveRead];
    _toRead = NO;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [HMUtility navBar:self.navigationController.navigationBar backImage:@"home_bg.png" backTag:HM_SYS_NAVIBARBG_TAG];

    
    HMGlobalParams *params = [HMGlobalParams sharedInstance];
    if (params.anonymous) {
        HMLoginEx *login = [[HMLoginEx alloc] initWithNibName:nil bundle:nil];
        login.hideBackButton = YES;
        [self.navigationController pushViewController:login animated:NO];
    }else{
        if (_toRead) {
            _toRead = NO;
            [HMUtility showModalView:_upgradeView baseView:self.view clickBackgroundToClose:YES fixSize:CGSizeMake(260, 210)];
        }else{
            _mobileLabel.text = params.mobile;
            _levelLabel.text = (params.vip == 1) ? @"（VIP会员）" : @"（普通会员）";
            _btnUpgrade.hidden = (params.vip == 1);
            _levelImage.image = (params.vip == 1) ? [UIImage imageNamed:@"vipMember.png"] : [UIImage imageNamed:@"normalMember.png"];
            [self query];
            [self queryUnreadVouchers];
            [self queryUnreadCAuctions];
        }

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark -
#pragma mark button methods
- (IBAction)callButtonDown:(id)sender {
    NSString *name = [NSString stringWithFormat:@"致电我们-%@ ？", HM_SYS_CUSTOM_SERVICE_PHONE];
    LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:name phone:HM_SYS_CUSTOM_SERVICE_PHONE type:0 name:@"更多服务" cancelButtonTitle:@"取消" okButtonTitle:@"确定"];
    [actionSheet showPhonecall:self.tabBarController.tabBar];
}


- (void)exitButtonDown:(id)sender
{
    [LCAlertView showWithTitle:@"提示" message:@"确定要退出登录么?" cancelTitle:@"取消" cancelBlock:nil otherTitle:@"确定" otherBlock:^{[self logout];}];
}

- (void)logout
{
    HMGlobalParams *params = [HMGlobalParams sharedInstance];
    params.anonymous = YES;
    params.mobile = nil;
    params.name = nil;
    [HMUtility writeUserInfo];
    HMLoginEx *login = [[HMLoginEx alloc] initWithNibName:nil bundle:nil];
    login.hideBackButton = YES;
    [self.navigationController pushViewController:login animated:YES];
    
}

#pragma mark -
#pragma mark query
- (void)query
{
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    NSMutableDictionary *queryParams = [[NSMutableDictionary alloc] initWithCapacity:1];
    [queryParams setValue:[HMGlobalParams sharedInstance].mobile forKeyPath:@"username"];
    _requestId = [net asynRequest:interfaceFeebackUnreadSuggestion with:queryParams needSSL:NO target:self action:@selector(procUnread:withResult:)];
    
}

- (void)procUnread:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    _requestId = 0;
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        _unreadCount = [[result.value objectForKey:@"obj"] integerValue];
    }else{
        _unreadCount = 0;

    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:5 inSection:0];
    [_resultTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)queryUnreadVouchers
{
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestVouchersId != 0) {
        [net cancelRequest:_requestVouchersId];
    }
    NSMutableDictionary *queryParams = [[NSMutableDictionary alloc] initWithCapacity:1];
    [queryParams setValue:[HMGlobalParams sharedInstance].mobile forKeyPath:@"username"];
    _requestVouchersId = [net asynRequest:interfaceVouchersUnread with:queryParams needSSL:NO target:self action:@selector(procUnreadVouchers:withResult:)];
    
}

- (void)procUnreadVouchers:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    _requestVouchersId = 0;
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        _unreadVouchersCount = [[result.value objectForKey:@"obj"] integerValue];
    }else{
        _unreadVouchersCount = 0;
        
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    [_resultTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)queryUnreadCAuctions
{
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestAuctionsId != 0) {
        [net cancelRequest:_requestAuctionsId];
    }
    NSMutableDictionary *queryParams = [[NSMutableDictionary alloc] initWithCapacity:1];
    [queryParams setValue:[HMGlobalParams sharedInstance].mobile forKeyPath:@"username"];
    _requestAuctionsId = [net asynRequest:interfaceAuctionRecordUnread with:queryParams needSSL:NO target:self action:@selector(procUnreadAuctions:withResult:)];
    
}

- (void)procUnreadAuctions:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    _requestAuctionsId = 0;
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        _unreadAuctionsCount = [[result.value objectForKey:@"obj"] integerValue];
    }else{
        _unreadAuctionsCount = 0;
        
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    [_resultTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark -
#pragma mark tableview data & delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *kitemID = nil;
    if (indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 5) {
        kitemID = [NSString stringWithFormat:@"cellFor%ld", (long)indexPath.row];
    }else{
        kitemID = @"cellForYP";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kitemID];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kitemID];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    switch (indexPath.row) {
        case 0:
        {
            cell.imageView.image = [UIImage imageNamed:@"mem_favorite.png"];
            cell.textLabel.text =  @"我的正在竞买";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
            
            break;
        case 1:
            cell.imageView.image = [UIImage imageNamed:@"mem_points.png"];
            cell.textLabel.text =  @"我的成功购买";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            /**
            cell.textLabel.text = @"我的积分";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [UIImage imageNamed:@"mem_points.png"];
             **/
            break;
        case 2:
            cell.imageView.image = [UIImage imageNamed:@"mem_coupon.png"];
            cell.textLabel.text =  @"我的收藏";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            /**
            cell.textLabel.text = @"我的代金券";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [UIImage imageNamed:@"mem_coupon.png"];
            for (UIView *subview in cell.contentView.subviews) {
                if (subview.tag > 0) {
                    [subview removeFromSuperview];
                }
            }
            if (_unreadVouchersCount > 0) {
                UILabel *but = [[UILabel alloc] initWithFrame:CGRectMake(250, 6, 32, 32)];
                but.text = [NSString stringWithFormat:@"%ld", (long)_unreadVouchersCount];
                but.textColor = [UIColor whiteColor];
                but.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"count_bg.png"]];
                but.textAlignment = NSTextAlignmentCenter;
                but.tag = 101;
                [cell.contentView addSubview:but];
            }
             **/
            
            break;
        case 3://
            cell.imageView.image = [UIImage imageNamed:@"mem_audit.png"];
            cell.textLabel.text =  @"二次委托销售";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            /**
            cell.textLabel.text = @"我的成功竞买";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [UIImage imageNamed:@"mem_audit.png"];
            for (UIView *subview in cell.contentView.subviews) {
                if (subview.tag > 0) {
                    [subview removeFromSuperview];
                }
            }
            if (_unreadAuctionsCount > 0) {
                UILabel *but = [[UILabel alloc] initWithFrame:CGRectMake(250, 6, 32, 32)];
                but.text = [NSString stringWithFormat:@"%ld", (long)_unreadAuctionsCount];
                but.textColor = [UIColor whiteColor];
                but.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"count_bg.png"]];
                but.textAlignment = NSTextAlignmentCenter;
                but.tag = 101;
                [cell.contentView addSubview:but];
            }
             **/
            break;
//        case 4:
//        {
//            cell.textLabel.text = @"升级VIP申请";
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            cell.imageView.image = [UIImage imageNamed:@"mem_info.png"];
//        }
//            break;
        case 4:
        {
            cell.textLabel.text = @"信息修改";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [UIImage imageNamed:@"mem_info.png"];
        }
            break;
        case 5:
        {
            cell.textLabel.text = @"意见反馈";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [UIImage imageNamed:@"mem_suggest.png"];
            for (UIView *subview in cell.contentView.subviews) {
                if (subview.tag > 0) {
                    [subview removeFromSuperview];
                }
            }
            if (_unreadCount > 0) {
                UILabel *but = [[UILabel alloc] initWithFrame:CGRectMake(250, 6, 32, 32)];
                but.text = [NSString stringWithFormat:@"%ld", (long)_unreadCount];
                but.textColor = [UIColor whiteColor];
                but.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"count_bg.png"]];
                but.textAlignment = NSTextAlignmentCenter;
                but.tag = 101;
                [cell.contentView addSubview:but];
            }
        }
            break;
        case 6:
        {
            cell.textLabel.text = @"商家签约入驻";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.imageView.image = [UIImage imageNamed:@"misc_aboutus.png"];
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            //我的正在竞买
            HMMyAuction *ctrl = [[HMMyAuction alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:ctrl animated:YES];
        }
            break;
            
        case 1:
        {
            //我的成功购买
            HMAuctOrders *ctrl = [[HMAuctOrders alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:ctrl animated:YES];
            
            /**我的积分
            HMMemberPointLog *ctrl = [[HMMemberPointLog alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:ctrl animated:YES];
            **/
        }
            break;
            
        case 2:
        {
            /**我的代金券
            HMMemberCoupon *ctrl = [[HMMemberCoupon alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:ctrl animated:YES];
            **/
            //我的收藏
            HMFavoriteList *ctrl = [[HMFavoriteList alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:ctrl animated:YES];
        }
            break;
            
        case 3:
        {
            //二次委托销售
            
            HMSalesOrder *ctrl = [[HMSalesOrder alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:ctrl animated:YES];
            /*** 我的成功竞买
            HMMemberAuctionRecords *ctrl = [[HMMemberAuctionRecords alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:ctrl animated:YES];
             **/
        }
            break;
            
//        case 4:
//        {
//            //升级VIP申请
//            HMUpgradeVIP *ctrl = [[HMUpgradeVIP alloc] initWithNibName:nil bundle:nil];
//            [self.navigationController pushViewController:ctrl animated:YES];
//            
//        }
//            break;
        case 4:
        {
            
            //信息修改
            HMUserInfo *ctrl = [[HMUserInfo alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:ctrl animated:YES];
        }
            break;
            
        case 5:
        {
            //意见反馈
            HMMemberFeedback *ctrl = [[HMMemberFeedback alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:ctrl animated:YES];
        }
            break;
        case 6:
        {
            //商家签约入驻
            HMSellerReg *ctrl = [[HMSellerReg alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:ctrl animated:YES];
        }
            break;
        default:
            break;
    }
    
}

- (IBAction)btnUpgradeDown:(id)sender {
//    _upgradeView.hidden = NO;
//    [HMUtility showModalView:_upgradeView baseView:self.view clickBackgroundToClose:YES fixSize:CGSizeMake(260, 210)];
    HMUpgradeVIP *ctrl = [[HMUpgradeVIP alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:ctrl animated:YES];

}

- (IBAction)upgradeButtonDown:(id)sender {
    if (!_haveRead) {
        [HMUtility alert:@"若您已仔细阅读过竞买须知,请勾选“我已查看竞买须知”" title:@"操作提示"];
        return;
    }
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestUpgradeId != 0) {
        [net cancelRequest:_requestUpgradeId];
    }
    NSMutableDictionary *queryParams = [[NSMutableDictionary alloc] initWithCapacity:3];
    [queryParams setObject:[HMGlobalParams sharedInstance].mobile forKey:@"username"];
    _requestUpgradeId = [net asynRequest:interfaceUserUpgrade with:queryParams needSSL:NO target:self action:@selector(dealUpgrade:withResult:)];
//    [_activity startAnimating];
//    [HMUtility showModalView:_activity baseView:self.view clickBackgroundToClose:NO];
    
}

- (IBAction)haveReadButtonDown:(id)sender {
    _haveRead = !_haveRead;
    UIImage *image = _haveRead ? [UIImage imageNamed:@"checked.png"] : [UIImage imageNamed:@"check_not.png"];
    [_haveReadButton setImage:image forState:UIControlStateNormal];
    
}

- (void)dealUpgrade:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    _requestUpgradeId = 0;
//    [_activity stopAnimating];
//    [HMUtility dismissModalView:_activity];
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        [LCAlertView showWithTitle:@"提示" message:@"您的升级请求已提交，我们的工作人员会尽快与您联系，请保持手机畅通！" cancelTitle:@"确定" cancelBlock:^{
            _upgradeView.hidden = YES;
            [HMUtility dismissModalView:_upgradeView];
        } otherTitle:nil otherBlock:nil];
    }else{
        if ([result.message length] > 0) {
            [HMUtility showTip:result.message inView:self.view];
        }else{
            [HMUtility showTip:@"升级申请提交失败，请重新操作！" inView:self.view];
        }
    }
}

- (void)tapHaveRead:(UITapGestureRecognizer *)tap
{
    
    [HMUtility dismissModalView:_upgradeView];
    _toRead = YES;
    LCWebView *web = [[LCWebView alloc] initWithNibName:nil bundle:nil];
    web.url = kUrlBidNotice;
    web.title = @"竞买须知";
    [self.navigationController pushViewController:web animated:YES];
    
    _haveRead = YES;
    UIImage *image = _haveRead ? [UIImage imageNamed:@"checked.png"] : [UIImage imageNamed:@"check_not.png"];
    [_haveReadButton setImage:image forState:UIControlStateNormal];
    
}

@end
