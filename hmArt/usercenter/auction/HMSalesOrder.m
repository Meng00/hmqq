//
//  HMSalesOrder.m
//  hmArt
//
//  Created by 刘学 on 15/7/20.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import "HMSalesOrder.h"

@interface HMSalesOrder ()

@end

@implementation HMSalesOrder

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"二次销售";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"view_bg.png"]];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    
    _resultArray = [[NSMutableArray alloc] init];
    _dataLoaded = NO;
    _pageSize = 10;
    _pageIndex = 1;
    _searchType = 1;
    _resultTable.tableHeaderView = nil;
    _resultTable.disableRefreshing = YES;
    _resultTable.disableLoadingMore = YES;
    _resultTable.backgroundColor = [UIColor clearColor];
    
    _topView = [[LCView alloc] initWithFrame:CGRectMake(4, 5, 312, 0)];
    [_topView setPaddingTop:5 paddingBottom:5 paddingLeft:5 paddingRight:0];
    _topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_topView];
    
    CGRect rect = _resultTable.frame;
    rect.origin.y = _topView.frame.origin.y + _topView.frame.size.height + 5;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - _topView.frame.origin.y - _topView.frame.size.height - HM_SYS_VIEW_OFFSET;
    _resultTable.frame = rect;
    
    [self query];
    [self queryBanlance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 点击事件
#pragma mark 点击触发事件函数
-(void)searchOrder:(UITapGestureRecognizer *)sender {
    UIView *view = [sender view];
    NSInteger tag = view.tag;
    if (tag == 1001) {
        _button1.textColor = [UIColor redColor];
        _button2.textColor = [UIColor colorWithRed:84.0/255 green:84.0/255 blue:84.0/255 alpha:1.0];
        _searchType = 1;
    }else if(tag == 1002){
        _button2.textColor = [UIColor redColor];
        _button1.textColor = [UIColor colorWithRed:84.0/255 green:84.0/255 blue:84.0/255 alpha:1.0];
        _searchType = 2;
    }
    _pageIndex = 1;
    CGRect rect = _resultTable.frame;
    rect.origin.y = _topView.frame.origin.y + _topView.frame.size.height + 5;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - HM_SYS_VIEW_OFFSET - rect.origin.y;
    _resultTable.frame = rect;
    
    [self query];
}

#pragma mark -
#pragma mark query methods
- (void)query
{
    _dataLoaded = NO;
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    NSMutableDictionary *queryParams = [[NSMutableDictionary alloc] initWithCapacity:3];
    HMGlobalParams *params = [HMGlobalParams sharedInstance];
    [queryParams setObject:params.mobile forKey:@"username"];
    [queryParams setObject:[NSNumber numberWithInteger:_pageIndex] forKey:@"pageIndex"];
    [queryParams setObject:[NSNumber numberWithInteger:_pageSize] forKey:@"pageSize"];
    
    _requestId = [net asynRequest:interfaceMemberAuctRequestNote with:queryParams needSSL:NO target:self action:@selector(dealLogs:withResult:)];
    
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
            [HMUtility showTip:@"信息下载失败!" inView:self.view];
        }
    }
    _dataLoaded = YES;
}

- (void)queryBanlance
{
    
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    if (_requestId2 != 0) {
        [net cancelRequest:_requestId2];
    }
    NSMutableDictionary *queryParams = [[NSMutableDictionary alloc] initWithCapacity:3];
    HMGlobalParams *params = [HMGlobalParams sharedInstance];
    [queryParams setObject:params.mobile forKey:@"username"];
    
    _requestId2 = [net asynRequest:interfaceMemberGetBalance with:queryParams needSSL:NO target:self action:@selector(dealBanlance:withResult:)];
    
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    
}
- (void)dealBanlance:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestId2 = 0;
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *ret = result.value;
        
        LCView *view1 = [[LCView alloc] init];
        [_topView addCustomSubview:view1 intervalTop:0];
        
        UILabel *ban = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view1.frame.size.width - 110, 0)];
        ban.text = [NSString stringWithFormat:@"账户余额：￥%@ 元",[ret objectForKey:@"obj"]];
        [view1 addCustomSublabel:ban intervalLeft:0];
        
        UILabel *recharge = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 0)];
        recharge.text = [NSString stringWithFormat:@"去充值"];
        recharge.textColor = [UIColor redColor];
        recharge.tag = 1002;
        recharge.textAlignment = NSTextAlignmentRight;
        recharge.userInteractionEnabled = YES;
        [recharge addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagRecharge:)]];
        [view1 addCustomSublabel:recharge intervalLeft:5];
        
        [_topView resize];
        
        CGRect rect = _resultTable.frame;
        rect.origin.y = _topView.frame.origin.y + _topView.frame.size.height + 5;
        rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - _topView.frame.origin.y - _topView.frame.size.height - HM_SYS_VIEW_OFFSET;
        _resultTable.frame = rect;
        
    } else {
        
    }
    _dataLoaded = YES;
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (!_dataLoaded) {
        return @"正在努力加载数据...";
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_resultArray.count == 0 && _dataLoaded) {
        return 100;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_resultArray.count == 0 && _dataLoaded) {
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(10, 20, 300, 64)];
        header.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 280, 21)];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"没有数据";
        label.font = [UIFont systemFontOfSize:14.0];
        [header addSubview:label];
        
        return header;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"salesOrderCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    NSDictionary *dic = [_resultArray objectAtIndex:indexPath.row];
    
    LCView *cellView = [[LCView alloc] initWithFrame:CGRectMake(4, 5, 312, 0)];
    [cellView setPaddingTop:3 paddingBottom:3 paddingLeft:3 paddingRight:3];
    cellView.backgroundColor = [UIColor whiteColor];
    [cell addSubview:cellView];
    
    HMNetImageView *iv = [[HMNetImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    iv.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [dic objectForKey:@"image"]];
    [iv load];
    [cellView addCustomSubview:iv intervalLeft:0];
    
    LCView *rightView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [cellView addCustomSubview:rightView intervalLeft:5];
    
    UILabel *artName = [[UILabel alloc] init];
    artName.text = [dic objectForKey:@"artName"];
    [rightView addCustomSublabel:artName intervalTop:3 textMaxShowWidth:0 textMaxShowHeight:20];
    
    UILabel *price = [[UILabel alloc] init];
    price.text = [NSString stringWithFormat:@"起拍价: %@", [dic objectForKey:@"initPrice"]];
    [rightView addCustomSublabel:price intervalTop:3];
    
   
    UILabel *orderStatusZh = [[UILabel alloc] init];
    orderStatusZh.text = [NSString stringWithFormat:@"状态: %@", [dic objectForKey:@"statusCh"]];
    [rightView addCustomSublabel:orderStatusZh intervalTop:3];
    
    if([dic objectForKey:@"statusExplain"]){
        UILabel *statusExplain = [[UILabel alloc] init];
        statusExplain.text = [NSString stringWithFormat:@"说明: %@",[dic objectForKey:@"statusExplain"]];
        [rightView addCustomSublabel:statusExplain intervalTop:3];
    }

    if([dic objectForKey:@"code"]){
        UILabel *code = [[UILabel alloc] init];
        code.text = [NSString stringWithFormat:@"竞买号: %@",[dic objectForKey:@"code"]];
        [rightView addCustomSublabel:code intervalTop:3];
    }
    
    
    [cellView resize];
    
    float h = cellView.frame.size.height+cellView.frame.origin.y;
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width,h);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [_resultArray objectAtIndex:indexPath.row];
    if([dic objectForKey:@"code"]){
        HMAuctionDetail *ctrl = [[HMAuctionDetail alloc] initWithNibName:nil bundle:nil];
        ctrl.code = [dic objectForKey:@"code"];
        ctrl.title = [dic objectForKey:@"artName"];
        ctrl.source = 1;
        [self.navigationController pushViewController:ctrl animated:YES];
    }

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


-(void) tagRecharge:(id)sender{
    
    UIView *view = [sender view];
    NSInteger tag = view.tag;
    
    if(tag == 1002){
        HMRecharge *ctrl = [[HMRecharge alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:ctrl animated:YES];
    }
}



@end
