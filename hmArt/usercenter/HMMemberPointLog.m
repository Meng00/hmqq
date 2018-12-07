//
//  HMMemberPointLog.m
//  hmArt
//
//  Created by wangyong on 14-9-25.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMMemberPointLog.h"
#import "HMPointsRecordCell.h"

@interface HMMemberPointLog ()

@end

@implementation HMMemberPointLog

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"我的积分";
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
        
    _titleView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _titleView.layer.borderWidth = 1.0;
    
    
    _resultArray = [[NSMutableArray alloc] init];
    
    _pageSize = 10;
    _pageIndex = 1;
    _resultTable.tableHeaderView = nil;
    _resultTable.disableRefreshing = YES;
    _resultTable.disableLoadingMore = YES;
    _resultTable.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCount:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    _countLabel.userInteractionEnabled = YES;
    [_countLabel addGestureRecognizer:tap];

    
    [self queryMemberPoints];
    [self query];

}

- (void)tapCount:(UITapGestureRecognizer *)tap
{
    HMMemberPointRecords *ctrl = [[HMMemberPointRecords alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:ctrl animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    _requestId = [net asynRequest:interfaceMemberPointsLog with:queryParams needSSL:NO target:self action:@selector(dealLogs:withResult:)];
    
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    
}
- (void)dealLogs:(NSString *)serviceName withResult:(LCInterfaceResult *)result
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
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"pointsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 3, 150, 21)];
        labelTitle.font = [UIFont systemFontOfSize:15.0];
        labelTitle.backgroundColor = [UIColor clearColor];
        labelTitle.tag = 1001;
        [cell.contentView addSubview:labelTitle];
        
        UILabel *labelStart = [[UILabel alloc] initWithFrame:CGRectMake(160, 3, 90, 21)];
        labelStart.font = [UIFont systemFontOfSize:15.0];
        labelStart.backgroundColor = [UIColor clearColor];
        labelStart.tag = 1002;
        [cell.contentView addSubview:labelStart];
        
        UILabel *labelEnd = [[UILabel alloc] initWithFrame:CGRectMake(5, 24, 300, 21)];
        labelEnd.font = [UIFont systemFontOfSize:15.0];
        labelEnd.backgroundColor = [UIColor clearColor];
        labelEnd.tag = 1003;
        [cell.contentView addSubview:labelEnd];
        
        UILabel *labelSubscribe = [[UILabel alloc] initWithFrame:CGRectMake(5, 45, 300, 21)];
        labelSubscribe.font = [UIFont systemFontOfSize:13.0];
        labelSubscribe.backgroundColor = [UIColor clearColor];
        labelSubscribe.tag = 1004;
        [cell.contentView addSubview:labelSubscribe];
    }
    NSDictionary *dic = [_resultArray objectAtIndex:indexPath.section];
    NSNumber *t = [dic objectForKey:@"type"];
    UILabel *lbl1 = (UILabel *)[cell viewWithTag:1001];
    NSString *sPoints = (t.intValue == 1) ? @"+" : @"-";
    lbl1.text = [NSString stringWithFormat:@"· 积分：%@%@",sPoints, [dic objectForKey:@"integral"]];
    
    UILabel *lbl2 = (UILabel *)[cell viewWithTag:1002];
    NSString *sType = (t.intValue == 1) ? @"赠送" : @"使用";
    lbl2.text = [NSString stringWithFormat:@"· 类型：%@", sType];
    
    UILabel *lbl3 = (UILabel *)[cell viewWithTag:1003];
    lbl3.text = [NSString stringWithFormat:@"· 时间：%@", [dic objectForKey:@"createDate"]];
    
    UILabel *lbl4 = (UILabel *)[cell viewWithTag:1004];
    lbl4.text = [NSString stringWithFormat:@"· 说明：%@", [dic objectForKey:@"remark"]];
    
    return cell;
}

@end
