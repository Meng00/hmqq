//
//  HMMemberPointProduct.m
//  hmArt
//
//  Created by wangyong on 14-8-14.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMMemberPointProduct.h"

@interface HMMemberPointProduct ()

@end

@implementation HMMemberPointProduct

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"积分商品";
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
    
    _resultArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    _pageSize = 10;
    _pageIndex = 1;
    _resultTable.tableHeaderView = nil;
    _resultTable.disableRefreshing = YES;
    _resultTable.disableLoadingMore = YES;
    _resultTable.backgroundColor = [UIColor clearColor];
    
    _fullImageView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height+20);
    _fullImageView.alpha = 0;
    _hiddenBar = NO;

    
    _categoryLabel.text = [NSString stringWithFormat:@"分类:%@", _categoryName];
    [self query];
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![HMGlobalParams sharedInstance].anonymous) {
        _myPoints = 0;
        [self queryMemberPoints];
    }else{
        _pointTitleLabel.hidden = YES;
    }

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
    return 200;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"hmArtistCell";
    
    HMPointsProductCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [HMUtility loadViewFromNib:@"HMPointsProductCell" withClass:[HMPointsProductCell class]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
     }
    NSDictionary *item = [_resultArray objectAtIndex:indexPath.section];
    
    cell.productImage.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [item objectForKey:@"image"]];
    [cell.productImage load];
    cell.nameLabel.text = [NSString stringWithFormat:@"礼品名称：%@",[item objectForKey:@"name"]];
    cell.codeLabel.text = [NSString stringWithFormat:@"编号：%@", [item objectForKey:@"code"]];
    cell.pointsLabel.text = [NSString stringWithFormat:@"%@",[item objectForKey:@"integral"]];
    cell.cateLabel.text = [NSString stringWithFormat:@"库存：%@", [item objectForKey:@"stock"]];
    if ([[item objectForKey:@"stock"] integerValue] > 0) {
//        cell.exchangeButton.hidden = NO;
        cell.exchangeButton.enabled = YES;
        cell.exchangeButton.tag = indexPath.section + 1000;
        [cell.exchangeButton addTarget:self action:@selector(exchange:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        cell.exchangeButton.enabled = NO;
    }
    cell.descLabel.text = [NSString stringWithFormat:@"%@",[item objectForKey:@"description"]];

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 1;
    cell.productImage.userInteractionEnabled = YES;
    cell.productImage.tag = indexPath.section + 2000;
    [cell.productImage addGestureRecognizer:tap];

    return cell;
}

- (void)exchange:(id)sender
{
    if ([HMGlobalParams sharedInstance].anonymous) {
        HMLoginEx *ctrl = [[HMLoginEx alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:ctrl animated:YES];
        return;
    }
    NSInteger tag = [sender tag];
    _exchangeTag = tag;
    NSDictionary *item = [_resultArray objectAtIndex:_exchangeTag-1000];
    NSInteger ep = [[item objectForKey:@"integral"] integerValue];
    if (ep > _myPoints) {
        [LCAlertView showWithTitle:@"提示" message:@"您的积分不足！" buttonTitle:@"确认"];
        return;
    }
 
    NSString *points = [NSString stringWithFormat:@"您的可用积分:%ld", (long)_myPoints];
    _myPointsLabel.text = points;
    [_myPointsLabel setTextAlign:kCAAlignmentCenter];
    [_myPointsLabel setColor:[UIColor orangeColor] fromIndex:7 length:points.length-7];
    [_myPointsLabel setFont:[UIFont systemFontOfSize:14.0] fromIndex:0 length:points.length];

    _productIdLabel.text = [NSString stringWithFormat:@"商品编码:%@", [item objectForKey:@"code"]];
    _exchangePointsLabel.text = [NSString stringWithFormat:@"%ld", (long)ep];
    _remainPointsLabel.text = [NSString stringWithFormat:@"%d", _myPoints - ep];
    _confirmView.hidden = NO;
    [HMUtility showModalView:_confirmView baseView:self.view clickBackgroundToClose:YES fixSize:CGSizeMake(280, 210)];
}

- (IBAction)exchangeButtonDown:(id)sender {
    NSDictionary *item = [_resultArray objectAtIndex:_exchangeTag-1000];
    NSString *code = [NSString stringWithFormat:@"%@",[item objectForKey:@"code"]];
    [self queryExchange:code];
}

- (IBAction)cancelButtonDown:(id)sender {
    _confirmView.hidden = YES;
    [HMUtility dismissModalView:_confirmView];
}

- (void)queryExchange:(NSString *)code
{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    NSMutableDictionary *queryParams = [[NSMutableDictionary alloc] initWithCapacity:3];
    HMGlobalParams *params = [HMGlobalParams sharedInstance];
    [queryParams setObject:params.mobile forKey:@"username"];
    [queryParams setObject:code forKey:@"code"];
    _requestId = [net asynRequest:interfaceMemberGiftExchange with:queryParams needSSL:NO target:self action:@selector(dealAuctionExchange:withResult:)];
}

- (void)dealAuctionExchange:(NSString *)serviceName withResult:(LCInterfaceResult *)result{
    [_activity stopAnimating];
    _requestId=0;
    [HMUtility dismissModalView:_activity];
    if (result.result==HM_SYS_INTERFACE_SUCCESS) {
        _confirmView.hidden = YES;
        [HMUtility dismissModalView:_confirmView];
        [HMUtility alert:result.message  title:@"提示"];
        [self queryMemberPoints];
        
    }else{
        [HMUtility alert:result.message  title:@"提示"];
        
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
     HMGlobalParams *params = [HMGlobalParams sharedInstance];
    [queryParams setObject:params.mobile forKey:@"username"];
    _requestPointsId = [net asynRequest:interfaceMemberPoints with:queryParams needSSL:NO target:self action:@selector(dealMemberpoint:withResult:)];
}
- (void)dealMemberpoint:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    _requestPointsId = 0;
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *ret = [result.value objectForKey:@"obj"];
        _myPoints = [[ret objectForKey:@"total"] integerValue];
    }else{
        _myPoints = 0;
    }
    _pointTitleLabel.hidden = NO;
    NSString *pos = [NSString stringWithFormat:@"我的积分:%ld",(long)_myPoints];
    _pointTitleLabel.text = pos;
    [_pointTitleLabel setTextAlign:kCAAlignmentRight];
    [_pointTitleLabel setColor:[UIColor redColor] fromIndex:5 length:pos.length-5];
    [_pointTitleLabel setFont:[UIFont systemFontOfSize:14.0] fromIndex:0 length:pos.length];

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
    [queryParams setObject:[NSNumber numberWithInteger:_categoryId] forKey:@"groupId"];
    [queryParams setObject:[NSNumber numberWithInteger:_pageIndex] forKey:@"pageIndex"];
    [queryParams setObject:[NSNumber numberWithInteger:_pageSize] forKey:@"pageSize"];
    
    _requestId = [net asynRequest:interfaceMemberGiftList with:queryParams needSSL:NO target:self action:@selector(dealAuctionRecords:withResult:)];
    
    
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
            [HMUtility showTip:@"积分商品信息下载失败!" inView:self.view];
        }
    }
}

#pragma mark -
#pragma mark detail auto zoom
- (void)tapImage:(UITapGestureRecognizer *)tap
{
    [self hideStatusBar:YES];
    _fullImageView.alpha = 1;
    
    UIImageView *imageView = (UIImageView *)tap.view;
    NSUInteger tag = imageView.tag;
    NSDictionary *item = [_resultArray objectAtIndex:tag-2000];
    
    HMImageZoomView *zoomView = [[HMImageZoomView alloc] initWithFrame:_fullImageView.bounds];
    zoomView.contentOffset = CGPointMake(0, 0);
    NSString *imgUrlBig = [item objectForKey:@"image2"];
    NSMutableString *imgUrl = [[NSMutableString alloc] initWithCapacity:10];
    [imgUrl appendFormat:@"%@", HM_SYS_IMGSRV_PREFIX];
    if (imgUrlBig && imgUrlBig.length > 0) {
        [imgUrl appendString:imgUrlBig];
    }else{
        [imgUrl appendFormat:@"%@", [item objectForKey:@"image"]];
    }
    
    [zoomView startLoadImage];
    zoomView.tag = 101;
    zoomView.zoomDelegate = self;
    [_fullImageView addSubview:zoomView];
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:_fullImageView];
    
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    if (_requestImageId != 0) {
        [net cancelRequest:_requestImageId];
    }
    _requestImageId = [net asynExternalRequest:imgUrl needSSL:NO cached:YES target:self action:@selector(dealImage:result:)];
}

- (void)dealImage:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    _requestImageId = 0;
    HMImageZoomView *zoomView = (HMImageZoomView *)[_fullImageView viewWithTag:101];
    [zoomView stopLoadImage];
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        UIImage *image = [UIImage imageWithData:result.value];
        [zoomView setImage:image];
        [self performSelector:@selector(setOriginFrame:) withObject:zoomView afterDelay:0.1];
    }
}

- (void) setOriginFrame:(HMImageZoomView *) sender
{
    [UIView animateWithDuration:0.4 animations:^{
        [sender setAnimationRect];
    }];
}

- (void)hideStatusBar:(BOOL)hidden
{
    [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:NO];
    _hiddenBar = hidden;
    if([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]){
        [self prefersStatusBarHidden];
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (BOOL)prefersStatusBarHidden
{
    if (_hiddenBar) {
        return YES;
    }
    return NO;
}

- (void)imageTapedWithObject:(id)sender
{
    if (_requestImageId != 0) {
        [[LCNetworkInterface sharedInstance] cancelRequest:_requestImageId];
    }
    for (UIView *subView in _fullImageView.subviews) {
        if (subView.tag > 0) {
            [subView removeFromSuperview];
        }
    }
    [_fullImageView removeFromSuperview];
    [self hideStatusBar:NO];
}

@end
