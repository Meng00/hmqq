//
//  HMMemberAuctionRecords.m
//  hmArt
//
//  Created by wangyong on 14-8-14.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMMemberAuctionRecords.h"

@interface HMMemberAuctionRecords ()

@end

@implementation HMMemberAuctionRecords

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"我的竞买";
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

    
    
     _resultArray = [[NSMutableArray alloc] init];
    _titleView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _titleView.layer.borderWidth = 1.0;
    
    
    CGRect rect = _resultTable.frame;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - HM_SYS_VIEW_OFFSET - rect.origin.y;
    _resultTable.frame = rect;
    if (IOS7) {
        _resultTable.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0);
    }
    
    //    _resultArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    _pageSize = 10;
    _pageIndex = 1;
    _resultTable.tableHeaderView = nil;
    _resultTable.disableRefreshing = YES;
    _resultTable.disableLoadingMore = YES;
    _resultTable.backgroundColor = [UIColor clearColor];
    [self query];
    [self queryMoney];
   
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    HMGlobalParams  *params = [HMGlobalParams sharedInstance];
    [queryParams setObject:params.mobile forKey:@"username"];
    [queryParams setObject:[NSNumber numberWithInteger:2] forKey:@"type"];
    [queryParams setObject:[NSNumber numberWithInteger:_pageIndex] forKey:@"pageIndex"];
    [queryParams setObject:[NSNumber numberWithInteger:_pageSize] forKey:@"pageSize"];
    
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
        NSLog(@"%@", ret);
        if (_pageIndex == 1) {
            [_resultArray removeAllObjects];
        }
        
        NSArray *data = [ret objectForKey:@"obj"];
        for (unsigned int i = 0; i < data.count; ++i) {
            [_resultArray addObject:[data objectAtIndex:i]];
        }
        _timesLabel.text = [NSString stringWithFormat:@"%@", [ret objectForKey:@"total"]];
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

- (void)queryMoney
{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestId != 0) {
        [net cancelRequest:_requestMoneyId];
    }
    
    NSMutableDictionary *queryParams = [[NSMutableDictionary alloc] initWithCapacity:3];
    HMGlobalParams  *params = [HMGlobalParams sharedInstance];
    [queryParams setObject:params.mobile forKey:@"username"];
    
    _requestMoneyId = [net asynRequest:interfaceAuctionMoney with:queryParams needSSL:NO target:self action:@selector(dealMoney:withResult:)];
    
}

- (void)dealMoney:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *ret = result.value;
        _moneyLabel.text = [NSString stringWithFormat:@"￥%@", [ret objectForKey:@"obj"]];
    } else {
        _moneyLabel.text = @"￥0.00";
    }
    
}

#pragma mark -
#pragma mark tableview datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _resultArray.count;
   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"hmArtistCell";
    
    HMAuctionRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [HMUtility loadViewFromNib:@"HMAuctionRecordCell" withClass:[HMAuctionRecordCell class]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *item = [_resultArray objectAtIndex:indexPath.section];
    cell.auditImage.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [item objectForKey:@"image"]];
    [cell.auditImage load];
    cell.codeLabel.text = [NSString stringWithFormat:@"●  编号：%@", [item objectForKey:@"code"]];
    cell.authorLabel.text = [NSString stringWithFormat:@"● 作者：%@", [item objectForKey:@"artist"]];
    cell.nameLabel.text = [NSString stringWithFormat:@"● 作品：%@", [item objectForKey:@"artName"]];
    cell.exchangeTimeLabel.text = [NSString stringWithFormat:@"竞买时间：%@", [item objectForKey:@"auctionDate"]];
    cell.priceLabel.text = [NSString stringWithFormat:@"● 成交价：￥%@", [item objectForKey:@"auctionPrice"]];
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [_resultArray objectAtIndex:indexPath.section];
    HMAuctionDetail *ctrl = [[HMAuctionDetail alloc] initWithNibName:nil bundle:nil];
    ctrl.code= [item objectForKey:@"code"];
    ctrl.title = [item objectForKey:@"artName"];
    [self.navigationController pushViewController:ctrl animated:YES];
    
}

@end
