//
//  HMAuctOrders.m
//  hmArt
//
//  Created by 刘学 on 15-7-7.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import "HMAuctOrders.h"

@interface HMAuctOrders ()

@end

@implementation HMAuctOrders

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"我的竞买订单";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"view_bg.png"]];
    [HMUtility navBar:self.navigationController.navigationBar backImage:@"home_bg.png" backTag:HM_SYS_NAVIBARBG_TAG];
    self.tabBarController.tabBar.hidden=YES;
    
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    self.tabBarController.tabBar.hidden=YES;
    
    _resultArray = [[NSMutableArray alloc] init];
    _dataLoaded = NO;
    _pageSize = 10;
    _pageIndex = 1;
    _searchType = 1;
    _resultTable.tableHeaderView = nil;
    _resultTable.disableRefreshing = YES;
    _resultTable.disableLoadingMore = YES;
    _resultTable.backgroundColor = [UIColor clearColor];
    
    _topView = [[LCView alloc] initWithFrame:CGRectMake(0, 5, 320, 0)];
    [_topView setPaddingTop:5 paddingBottom:5 paddingLeft:0 paddingRight:0];
    _topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_topView];
    _button1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 79, 0)];
    _button1.text = @"待付款";
    _button1.tag = 1001;
    _button1.textAlignment = NSTextAlignmentCenter;
    _button1.textColor = [UIColor redColor];
    _button1.userInteractionEnabled = YES;
    [_button1 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchOrder:)]];
    [_topView addCustomSublabel:_button1 intervalLeft:0 textMaxShowWidth:0 textMaxShowHeight:0 font:[UIFont systemFontOfSize:13.0f]];
    UILabel *line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 0)];
    [_topView addCustomSublabel:line1 intervalLeft:0];
    line1.backgroundColor = [UIColor grayColor];
    _button2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 79, 0)];
    _button2.text = @"待发货";
    _button2.tag = 1002;
    _button2.textAlignment = NSTextAlignmentCenter;
    _button2.textColor = [UIColor colorWithRed:84.0/255 green:84.0/255 blue:84.0/255 alpha:1.0];
    _button2.userInteractionEnabled = YES;
    [_button2 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchOrder:)]];
    [_topView addCustomSublabel:_button2 intervalLeft:0 textMaxShowWidth:0 textMaxShowHeight:0 font:[UIFont systemFontOfSize:13.0f]];
    UILabel *line2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 0)];
    [_topView addCustomSublabel:line2 intervalLeft:0];
    line2.backgroundColor = [UIColor grayColor];
    _button3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 79, 0)];
    _button3.text = @"待收货";
    _button3.tag = 1003;
    _button3.textAlignment = NSTextAlignmentCenter;
    _button3.textColor = [UIColor colorWithRed:84.0/255 green:84.0/255 blue:84.0/255 alpha:1.0];
    _button3.userInteractionEnabled = YES;
    [_button3 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchOrder:)]];
    [_topView addCustomSublabel:_button3 intervalLeft:0 textMaxShowWidth:0 textMaxShowHeight:0 font:[UIFont systemFontOfSize:13.0f]];
    UILabel *line3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 0)];
    [_topView addCustomSublabel:line3 intervalLeft:0];
    line3.backgroundColor = [UIColor grayColor];
    _button4 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 79, 0)];
    _button4.text = @"全部";
    _button4.tag = 1004;
    _button4.textAlignment = NSTextAlignmentCenter;
    _button4.textColor = [UIColor colorWithRed:84.0/255 green:84.0/255 blue:84.0/255 alpha:1.0];
    _button4.userInteractionEnabled = YES;
    [_button4 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchOrder:)]];
    [_topView addCustomSublabel:_button4 intervalLeft:0 textMaxShowWidth:0 textMaxShowHeight:0 font:[UIFont systemFontOfSize:13.0f]];
    
    [_topView resize];
    line1.frame = CGRectMake(line1.frame.origin.x, line1.frame.origin.y, 1, _topView.frame.size.height-10);
    line2.frame = CGRectMake(line2.frame.origin.x, line2.frame.origin.y, 1, _topView.frame.size.height-10);
    line3.frame = CGRectMake(line3.frame.origin.x, line3.frame.origin.y, 1, _topView.frame.size.height-10);
    
    _amountView = [[LCView alloc] initWithFrame:CGRectMake(0, _topView.frame.origin.y+_topView.frame.size.height+5, 320, 0)];
    [_amountView setPaddingTop:3 paddingBottom:0 paddingLeft:0 paddingRight:0];
    _amountView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_amountView];
    
    UILabel *count0 = [[UILabel alloc] init];
    count0.text = @"购买数:";
    [_amountView addCustomSublabel:count0 intervalLeft:10 textMaxShowWidth:0 textMaxShowHeight:0 font:[UIFont systemFontOfSize:12.0f]];
    _count = [[UILabel alloc] init];
    _count.text = @"0";
    _count.textColor = [UIColor redColor];
    [_amountView addCustomSublabel:_count intervalLeft:2 textMaxShowWidth:0 textMaxShowHeight:0 font:[UIFont systemFontOfSize:12.0f]];
    UILabel *count1 = [[UILabel alloc] init];
    count1.text = @"件";
    [_amountView addCustomSublabel:count1 intervalLeft:2 textMaxShowWidth:0 textMaxShowHeight:0 font:[UIFont systemFontOfSize:12.0f]];
    
    _line = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 42)];
    [_amountView addCustomSublabel:_line intervalLeft:0 textMaxShowWidth:0 textMaxShowHeight:0 font:[UIFont systemFontOfSize:12.0f]];
    
    UILabel *amount0 = [[UILabel alloc] init];
    amount0.text = @"总金额: ";
    [_amountView addCustomSublabel:amount0 intervalLeft:5 textMaxShowWidth:0 textMaxShowHeight:0 font:[UIFont systemFontOfSize:12.0f]];
    _amount = [[UILabel alloc] init];
    _amount.text = @"￥0";
    _amount.textColor = [UIColor redColor];
    [_amountView addCustomSublabel:_amount intervalLeft:2 textMaxShowWidth:0 textMaxShowHeight:0 font:[UIFont systemFontOfSize:12.0f]];
    UILabel *_amount1 = [[UILabel alloc] init];
    _amount1.text = @"元";
    [_amountView addCustomSublabel:_amount1 intervalLeft:2 textMaxShowWidth:0 textMaxShowHeight:0 font:[UIFont systemFontOfSize:12.0f]];
    //[_amountView resize];
    
    CGRect frame = _line.frame;
    frame.size.width = _amountView.frame.size.width - _amount1.frame.size.width - _amount1.frame.origin.x + frame.size.width - 10;
    _line.frame = frame;
    
    [_amountView resize];
    
    UIButton *paybut = [UIButton buttonWithType:UIButtonTypeCustom];
    paybut.frame = CGRectMake(240, 25, 70, 30);
    paybut.tag = 1001;
    [paybut setTitle:@"去支付" forState:UIControlStateNormal];
    [paybut setBackgroundImage:[UIImage imageNamed:@"btn_bg_brown.png"] forState:UIControlStateNormal];
    paybut.userInteractionEnabled = YES;
    [paybut addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagPayment:)]];
    [_amountView addSubview:paybut];
    
    
    CGRect rect = _resultTable.frame;
    rect.origin.y = _amountView.frame.origin.y + _amountView.frame.size.height + 10;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - HM_SYS_VIEW_OFFSET - rect.origin.y;
    _resultTable.frame = rect;
    
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self query];
}

- (void)didReceiveMemoryWarning
{
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
        _button3.textColor = [UIColor colorWithRed:84.0/255 green:84.0/255 blue:84.0/255 alpha:1.0];
        _button4.textColor = [UIColor colorWithRed:84.0/255 green:84.0/255 blue:84.0/255 alpha:1.0];
        _searchType = 1;
    }else if(tag == 1002){
        _button2.textColor = [UIColor redColor];
        _button1.textColor = [UIColor colorWithRed:84.0/255 green:84.0/255 blue:84.0/255 alpha:1.0];
        _button3.textColor = [UIColor colorWithRed:84.0/255 green:84.0/255 blue:84.0/255 alpha:1.0];
        _button4.textColor = [UIColor colorWithRed:84.0/255 green:84.0/255 blue:84.0/255 alpha:1.0];
        _searchType = 2;
    }else if(tag == 1003){
        _button3.textColor = [UIColor redColor];
        _button2.textColor = [UIColor colorWithRed:84.0/255 green:84.0/255 blue:84.0/255 alpha:1.0];
        _button1.textColor = [UIColor colorWithRed:84.0/255 green:84.0/255 blue:84.0/255 alpha:1.0];
        _button4.textColor = [UIColor colorWithRed:84.0/255 green:84.0/255 blue:84.0/255 alpha:1.0];
        _searchType = 3;
    }else if(tag == 1004){
        _button1.textColor = [UIColor colorWithRed:84.0/255 green:84.0/255 blue:84.0/255 alpha:1.0];
        _button2.textColor = [UIColor colorWithRed:84.0/255 green:84.0/255 blue:84.0/255 alpha:1.0];
        _button3.textColor = [UIColor colorWithRed:84.0/255 green:84.0/255 blue:84.0/255 alpha:1.0];
        _button4.textColor = [UIColor redColor];
        _searchType = 4;
    }
    _pageIndex = 1;
    _amountView.hidden = YES;
    CGRect rect = _resultTable.frame;
    rect.origin.y = _topView.frame.origin.y + _topView.frame.size.height + 5;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - HM_SYS_VIEW_OFFSET - rect.origin.y;
    _resultTable.frame = rect;
    
    [self query];
}

-(void) tagPayment:(id)sender{
    if (_resultArray.count < 1) {
        return;
    }
    HMAuctOrderPayment *ctrl = [[HMAuctOrderPayment alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:ctrl animated:YES];
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
    [queryParams setObject:[NSNumber numberWithInteger:_searchType] forKey:@"type"];
    [queryParams setObject:[NSNumber numberWithInteger:_pageIndex] forKey:@"pageIndex"];
    [queryParams setObject:[NSNumber numberWithInteger:_pageSize] forKey:@"pageSize"];
    
    _requestId = [net asynRequest:interfaceMemberAuctOrder with:queryParams needSSL:NO target:self action:@selector(dealLogs:withResult:)];
    
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
        if(_searchType == 1){
            float total = 0;
            for (signed i = 0; i<_resultArray.count; i++) {
                NSDictionary *dic = [_resultArray objectAtIndex:i];
                float price = [[dic objectForKey:@"auctionPrice"] floatValue];
                float service = [[dic objectForKey:@"serviceAmount"] floatValue];
                total = total + price + service;
            }
            _amountView.hidden = NO;
            float w = 0;
            CGRect frame = _count.frame;
            _count.text = [NSString stringWithFormat:@"%i", _resultArray.count];
            CGSize size =  [HMUtility calculateSize:_count.text withFont:_count.font fixedWidth:320];
            w = w + (size.width - frame.size.width);
            frame.size = size;
            _count.frame = frame;
            
            frame = _amount.frame;
            _amount.text = [NSString stringWithFormat:@"￥%0.0f", total];
            size =  [HMUtility calculateSize:_amount.text withFont:_amount.font fixedWidth:320];
            w = w + (size.width - frame.size.width);
            frame.size = size;
            _amount.frame = frame;
            
            frame = _line.frame;
            frame.size.width = frame.size.width - w;
            _line.frame = frame;
            
            [_amountView resize];
            
            CGRect rect = _resultTable.frame;
            rect.origin.y = _amountView.frame.origin.y + _amountView.frame.size.height + 10;
            rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - HM_SYS_VIEW_OFFSET - rect.origin.y;
            _resultTable.frame = rect;
            
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
            [HMUtility showTip:@"订单信息下载失败!" inView:self.view];
        }
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
        label.text = @"没有竞买订单";
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
    static NSString *CellIdentifier = @"auctOrderCell";
    
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
    
    if(_searchType == 1 || _searchType == 2 || _searchType == 3 || _searchType == 4){
        LCView *rightView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, 120, 0)];
        [cellView addCustomSubview:rightView intervalLeft:5];
        
        UILabel *code = [[UILabel alloc] init];
        code.text = [NSString stringWithFormat:@"订单号:%@", [dic objectForKey:@"code"]];
        [rightView addCustomSublabel:code intervalTop:0 textMaxShowWidth:0 textMaxShowHeight:0 font:[UIFont systemFontOfSize:11.0f]];
        
        UILabel *artName = [[UILabel alloc] init];
        artName.text = [dic objectForKey:@"artName"];
        [rightView addCustomSublabel:artName intervalTop:3 textMaxShowWidth:0 textMaxShowHeight:20 font:[UIFont systemFontOfSize:11.0f]];
        
        UILabel *ownerType = [[UILabel alloc] init];
        NSInteger ot = [[dic objectForKey:@"ownerType"] integerValue];
        if(ot == 0) ownerType.text = [NSString stringWithFormat:@"作品类型:平台自营"];
        else if(ot == 1) ownerType.text = [NSString stringWithFormat:@"作品类型:本人委托"];
        else if(ot == 2) ownerType.text = [NSString stringWithFormat:@"作品类型:藏家委托"];
        [rightView addCustomSublabel:ownerType intervalTop:3 textMaxShowWidth:0 textMaxShowHeight:0 font:[UIFont systemFontOfSize:11.0f]];
        
        UILabel *orderStatusZh = [[UILabel alloc] init];
        orderStatusZh.text = [NSString stringWithFormat:@"订单状态:%@", [dic objectForKey:@"orderStatusZh"]];
        [rightView addCustomSublabel:orderStatusZh intervalTop:3 textMaxShowWidth:0 textMaxShowHeight:0 font:[UIFont systemFontOfSize:11.0f]];
        
        UILabel *time = [[UILabel alloc] init];
        time.text = [NSString stringWithFormat:@"竞买时间:%@", [dic objectForKey:@"createDate"]];
        [rightView addCustomSublabel:time intervalTop:3 textMaxShowWidth:0 textMaxShowHeight:0 font:[UIFont systemFontOfSize:11.0f]];
        
        
        
        LCView *leftView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, 100, 0)];
        [cellView addCustomSubview:leftView intervalLeft:0];
        leftView.backgroundColor = [UIColor clearColor];
        
        UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, leftView.frame.size.width, 0)];
        price.text = [NSString stringWithFormat:@"拍下价: ￥%@", [dic objectForKey:@"auctionPrice"]];
        //price.textAlignment = NSTextAlignmentRight;
        price.textColor = [UIColor redColor];
        [leftView addCustomSublabel:price intervalTop:15 textMaxShowWidth:leftView.frame.size.width textMaxShowHeight:0 font:[UIFont systemFontOfSize:10.0f]];
        
        UILabel *serviceAmount = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, leftView.frame.size.width, 0)];
        serviceAmount.text = [NSString stringWithFormat:@"佣 金: ￥%@", [dic objectForKey:@"serviceAmount"]];
        //serviceAmount.textAlignment = NSTextAlignmentRight;
        serviceAmount.textColor = [UIColor redColor];
        [leftView addCustomSublabel:serviceAmount intervalTop:0 textMaxShowWidth:leftView.frame.size.width textMaxShowHeight:0 font:[UIFont systemFontOfSize:10.0f]];
        
        
        
        
        
    }else if(_searchType == 2){
        
        
        
        
    }
    
    
    
    
    
    [cellView resize];
    
    float h = cellView.frame.size.height+cellView.frame.origin.y;
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width,h);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [_resultArray objectAtIndex:indexPath.row];
    HMAuctOrderDetail *ctrl = [[HMAuctOrderDetail alloc] initWithNibName:nil bundle:nil];
    ctrl.orderId = [[dic objectForKey:@"id"] integerValue];
    [self.navigationController pushViewController:ctrl animated:YES];
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


@end
