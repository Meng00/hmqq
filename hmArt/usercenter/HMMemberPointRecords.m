//
//  HMMemberPointRecords.m
//  hmArt
//
//  Created by wangyong on 14-8-14.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMMemberPointRecords.h"

@interface HMMemberPointRecords ()

@end

@implementation HMMemberPointRecords

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"礼品兑换记录";
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
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - HM_SYS_VIEW_OFFSET - rect.origin.y;
    _resultTable.frame = rect;
    
    if (IOS7) {
        _resultTable.contentInset = UIEdgeInsetsMake(-30, 0, 0, 0);
    }
    
    _titleView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _titleView.layer.borderWidth = 1.0;
    
    
    _resultArray = [[NSMutableArray alloc] init];
    
    _pageSize = 10;
    _pageIndex = 1;
    _resultTable.tableHeaderView = nil;
    _resultTable.disableRefreshing = YES;
    _resultTable.disableLoadingMore = YES;
    _resultTable.backgroundColor = [UIColor clearColor];
    
    [self queryMemberPoints];
    [self query];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"hmArtistCell";
    
    HMPointsRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [HMUtility loadViewFromNib:@"HMPointsRecordCell" withClass:[HMPointsRecordCell class]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *item = [_resultArray objectAtIndex:indexPath.section];
    cell.productImage.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [item objectForKey:@"image"]];
    [cell.productImage load];
    cell.nameLabel.text = [NSString stringWithFormat:@"礼品名称:%@", [item objectForKey:@"name"]];
    cell.codeLabel.text = [NSString stringWithFormat:@"ID:%@", [item objectForKey:@"giftCode"]];
    cell.pointsLabel.text = [NSString stringWithFormat:@"%@",[item objectForKey:@"integral"]];
    cell.exchangeTimeLabel.text = [NSString stringWithFormat:@"兑换时间:%@",[item objectForKey:@"createDate"]];
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
    HMGlobalParams *params = [HMGlobalParams sharedInstance];
    [queryParams setObject:params.mobile forKey:@"username"];
    [queryParams setObject:[NSNumber numberWithInteger:_pageIndex] forKey:@"pageIndex"];
    [queryParams setObject:[NSNumber numberWithInteger:_pageSize] forKey:@"pageSize"];
    
    _requestId = [net asynRequest:interfaceMemberGiftOrder with:queryParams needSSL:NO target:self action:@selector(dealAuctionRecords:withResult:)];
    
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
        _pageCount = [[ret objectForKey:@"pageCount"] integerValue];
        
         _countLabel.text =[NSString stringWithFormat:@"您有%ld条兑换记录",(long)[[ret objectForKey:@"total"] integerValue]];
        
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
            [HMUtility showTip:@"积分记录信息下载失败!" inView:self.view];
        }
    }
}

#pragma mark -
#pragma mark query methods
- (void)queryMemberPoints
{
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestPointsId != 0) {
        [net cancelRequest:_requestPointsId];
    }
    NSMutableDictionary *queryParams = [[NSMutableDictionary alloc] initWithCapacity:3];
    [queryParams setObject:[HMGlobalParams sharedInstance].mobile forKey:@"username"];
    _requestPointsId = [net asynRequest:interfaceMemberPoints with:queryParams needSSL:NO target:self action:@selector(dealCategoriespoint:withResult:)];
}
- (void)dealCategoriespoint:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    _requestPointsId = 0;
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *ret = [result.value objectForKey:@"obj"];
        NSInteger t = [[ret objectForKey:@"total"] integerValue];
        _myPoints = t;
        _pointsLabel.text =[NSString stringWithFormat:@"%ld",(long)t];
    }else{
        _myPoints = 0;
        _pointsLabel.text = @"0";
        [HMUtility showTip:result.message inView:self.view];
    }
}

@end
