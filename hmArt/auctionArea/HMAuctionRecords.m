//
//  HMAuctionRecords.m
//  hmArt
//
//  Created by wangyong on 14-8-12.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMAuctionRecords.h"

@interface HMAuctionRecords ()

@end

@implementation HMAuctionRecords

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"竞买记录";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"view_bg.png"]];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    
    CGRect rect = _resultTable.frame;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - HM_SYS_VIEW_OFFSET;
    _resultTable.frame = rect;
    if (IOS7) {
        _resultTable.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0);
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSearch:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    _searchLabel.userInteractionEnabled = YES;
    [_searchLabel addGestureRecognizer:tap];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMemberAudit:)];
    tap1.numberOfTapsRequired = 1;
    tap1.numberOfTouchesRequired = 1;
    _memberAuditLabel.userInteractionEnabled = YES;
    [_memberAuditLabel addGestureRecognizer:tap1];

    _resultArray = [[NSMutableArray alloc] init];
    
    _titleView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _titleView.layer.borderWidth = 1.0;
    
    
    
    //    _resultArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        _pageSize = 10;
        _pageIndex = 1;
        _resultTable.tableHeaderView = nil;
        _resultTable.disableRefreshing = YES;
        _resultTable.disableLoadingMore = YES;
        _resultTable.backgroundColor = [UIColor clearColor];
        
        [self query];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ClickTabBar:) name:@"HMArtTabBarClickedAtIndexSecond" object:nil];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HMArtTabBarClickedAtIndexSecond" object:nil];
    [super viewWillDisappear:animated];
}

- (void)ClickTabBar:(NSNotification *)noticatication
{
    _artist = @"";
    _artName = @"";
    _startTime = @"";
    _endTime = @"";
    _area = @"";
    _pageIndex = 1;
    [self query];
   
}

#pragma mark -
#pragma mark event handler
- (void)tapSearch:(UITapGestureRecognizer *)tap
{
    HMAuctionSearch *ctrl = [[HMAuctionSearch alloc] initWithNibName:nil bundle:nil];
    ctrl.delegate = self;
    [self.navigationController pushViewController:ctrl animated:YES];
}
- (void)tapMemberAudit:(UITapGestureRecognizer *)tap
{
    /*
    HMGlobalParams *params = [HMGlobalParams sharedInstance];
    if (params.anonymous) {
        HMLoginEx *login = [[HMLoginEx alloc] initWithNibName:nil bundle:nil];
//        login.hideBackButton = YES;
        [self.navigationController pushViewController:login animated:YES];
        return;
    }
     */
    HMMemberAuctionRecords *ctrl = [[HMMemberAuctionRecords alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:ctrl animated:YES];
}


#pragma mark -
#pragma mark tableview datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    return _resultArray.count;
}
/*
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2.0;
}



- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 2.0;
}
*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 104;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"hmAuditCell";
    
    HMTransactionRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [HMUtility loadViewFromNib:@"HMTransactionRecordCell" withClass:[HMTransactionRecordCell class]];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    NSDictionary *item = [_resultArray objectAtIndex:indexPath.row];
    cell.auditImage.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [item objectForKey:@"image"]];
    [cell.auditImage load];
    cell.nameLabel.text = [item objectForKey:@"artName"];
    cell.codeLabel.text = [NSString stringWithFormat:@"编号:%@", [item objectForKey:@"code"]];
    cell.authorLabel.text = [NSString stringWithFormat:@"作者:%@", [item objectForKey:@"artist"]];
    NSInteger auctionStatus = [[item objectForKey:@"auctionStatus"] integerValue];
    if (auctionStatus == 3 || auctionStatus == 4) {
        cell.dealTimeLabel.text = [NSString stringWithFormat:@"竞买时间:%@", [item objectForKey:@"auctionDate"]];
        cell.priceLabel.text = [NSString stringWithFormat:@"成交价:￥%@", [item objectForKey:@"auctionPrice"]];
        cell.locationLabel.text = [NSString stringWithFormat:@"归属地：%@", [item objectForKey:@"area"]];
    }else if (auctionStatus == 2){
        cell.dealTimeLabel.text = @"";
        cell.priceLabel.text = @"流拍";
        //cell.locationLabel.text = [NSString stringWithFormat:@"竞买时间:%@", [item objectForKey:@"auctionDate"]];
        cell.locationLabel.text = @"";
    }
    return cell;
}

#pragma mark -
#pragma mark pullableTable methods
- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    _pageIndex++;
    if (_pageIndex > _pageCount) {
        return;
    }
    [self query];
}


#pragma mark -
#pragma mark query methods
- (void)query
{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    
    NSMutableDictionary *queryParams = [[NSMutableDictionary alloc] initWithCapacity:3];
//    HMGlobalParams *params = [HMGlobalParams sharedInstance];
//    [queryParams setObject:params.mobile forKey:@"username"];
    [queryParams setObject:[NSNumber numberWithInteger:2] forKey:@"type"];
    [queryParams setObject:[NSNumber numberWithInteger:_pageIndex] forKey:@"pageIndex"];
    [queryParams setObject:[NSNumber numberWithInteger:_pageSize] forKey:@"pageSize"];
    
    
    if (_startTime && _startTime.length > 0) {
        [queryParams setValue:_startTime forKey:@"startTime"];
    }
    if (_endTime && _endTime.length > 0) {
        [queryParams setValue:_endTime forKey:@"endTime"];
    }
    
    if (_artist && _artist.length > 0) {
        [queryParams setValue:_artist forKey:@"artist"];
    }
    if (_artName && _artName.length > 0) {
        [queryParams setValue:_artName forKey:@"artName"];
    }
    if (_area && _area.length > 0) {
        [queryParams setValue:_area forKey:@"area"];
    }
    if (_code && _code.length > 0) {
        [queryParams setValue:_code forKey:@"code"];
    }
    if (_type) {
        [queryParams setValue:[NSNumber numberWithInteger:_type] forKey:@"type"];
    }
    _requestId = [net asynRequest:interfaceAuctionRecords with:queryParams needSSL:NO target:self action:@selector(dealAuctionRecords:withResult:)];
    
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    
}

- (void)dealAuctionRecords:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestId = 0;
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *ret = result.value;
        if (_pageIndex == 1) {
            [_resultArray removeAllObjects];
        }
        
        NSArray *data = [ret objectForKey:@"obj"];
        for (unsigned int i = 0; i < data.count; ++i) {
            [_resultArray addObject:[data objectAtIndex:i]];
        }
        _pageCount = [[ret objectForKey:@"pageCount"] integerValue];
        if (_pageIndex < _pageCount) {
            _resultTable.disableLoadingMore = NO;
            [_resultTable setLoadingMoreText:[NSString stringWithFormat:@"第%ld页/共%ld页 上拉加载下一页", (long)_pageIndex, (long)_pageCount] forState:EGOOPullNormal];
        }else{
            _resultTable.disableLoadingMore = YES;
        }
        
        [_resultTable reloadData];
        _resultTable.pullTableIsLoadingMore = NO;
        
    } else {
        if (result.message && result.message.length > 0) {
            [HMUtility showTip:result.message inView:self.view];
        }else{
            [HMUtility showTip:@"竞买记录信息下载失败!" inView:self.view];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [_resultArray objectAtIndex:indexPath.row];
    HMAuctionDetail *ctrl = [[HMAuctionDetail alloc] initWithNibName:nil bundle:nil];
    ctrl.code= [item objectForKey:@"code"];
    ctrl.source = 2;
    ctrl.title = [item objectForKey:@"artName"];
    [self.navigationController pushViewController:ctrl animated:YES];
 
}

#pragma mark -
#pragma mark auction search datasource & delegate
- (void)auctionsDidSearch:(NSDictionary *)conditions
{
    _artist = [conditions objectForKey:@"artist"];
    _artName = [conditions objectForKey:@"artName"];
    _startTime = [conditions objectForKey:@"startTime"];
    _endTime = [conditions objectForKey:@"endTime"];
    _area = [conditions objectForKey:@"area"];
    _code = [conditions objectForKey:@"code"];
    _type = [[conditions objectForKey:@"type"] integerValue];
    _pageIndex = 1;
    [self query];
}
@end
