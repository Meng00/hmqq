//
//  HMMyAuction.m
//  hmArt
//
//  Created by 刘学 on 15/7/20.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import "HMMyAuction.h"

@interface HMMyAuction ()

@end

#define MYAUCTCELL_REUSEID @"MyAuctionCell"

@implementation HMMyAuction

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"我的正在竞买";
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
    
    _pageSize = 10;
    _pageIndex = 1;
   
    [_myAuctCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:MYAUCTCELL_REUSEID];
    
    _myAuctCollectionView.backgroundColor = [UIColor clearColor];
    
    
    //CGRect rect = _myAuctCollectionView.frame;
    //rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y;
    //_myAuctCollectionView.frame = rect;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ClickTabBar:) name:@"HMArtTabBarClickedAtIndexZero" object:nil];
    
    _countSecondsArray = [[NSMutableArray alloc] initWithCapacity:2];
    [self queryDoing];
    
}

-(void) viewDidDisappear:(BOOL)animated
{
    if (_timer) {
        [_timer invalidate];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshDoing) object:[NSNumber numberWithBool:YES]];
    
    [super viewDidDisappear:animated];
}

- (void)ClickTabBar:(NSNotification *)noticatication
{
    if (_timer) {
        [_timer invalidate];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshDoing) object:[NSNumber numberWithBool:YES]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark query methods
- (void)queryDoing
{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 3];
    [queryParam setValue:[NSNumber numberWithInteger:_pageIndex] forKey:@"pageIndex"];
    [queryParam setValue:[NSNumber numberWithInteger:_pageSize] forKey:@"pageSize"];
    [queryParam setObject:[HMGlobalParams sharedInstance].mobile forKey:@"username"];
    
    _requestId = [net asynRequest:interfaceMyAuction with:queryParam needSSL:NO target:self action:@selector(dealAuctions:result:)];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    [_activity startAnimating];
    
}

- (void)refreshDoing
{
    
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestDoingRefreshId != 0) {
        [net cancelRequest:_requestDoingRefreshId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 3];
    [queryParam setValue:[NSNumber numberWithInteger:1] forKey:@"pageIndex"];
    [queryParam setValue:[NSNumber numberWithInteger:_resultArray.count] forKey:@"pageSize"];
    [queryParam setObject:[HMGlobalParams sharedInstance].mobile forKey:@"username"];
    
    _requestDoingRefreshId = [net asynRequest:interfaceMyAuction with:queryParam needSSL:NO target:self action:@selector(refreshAuctions:result:)];
    [_activity startAnimating];
    
    [self performSelector:@selector(refreshDoing) withObject:[NSNumber numberWithBool:YES] afterDelay:3.0];
}


- (void)dealAuctions:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestId = 0;
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *ret = result.value;
        
        if (_pageIndex == 1) {
            [_resultArray removeAllObjects];
        }
        [_myAuctCollectionView footerEndRefreshing];
        NSArray *data = [ret objectForKey:@"obj"];
        for (unsigned int i = 0; i < data.count; ++i) {
            [_resultArray addObject:[data objectAtIndex:i]];
        }
        _pageCount = [[ret objectForKey:@"pageCount"] integerValue];
        
        if (_pageIndex != _pageCount && _pageCount > 0) {
            [_myAuctCollectionView addFooterWithTarget:self action:@selector(loadMoreDoingUp)];
            _myAuctCollectionView.footerPullToRefreshText = [NSString stringWithFormat:@"第%ld页/共%ld页 上拉加载下一页", (long)_pageIndex, (long)_pageCount];
            _myAuctCollectionView.footerRefreshingText = @"正在加载数据，请耐心等待...";
            _myAuctCollectionView.footerReleaseToRefreshText = @"松开马上加载...";
        }else{
            [_myAuctCollectionView removeFooter];
        }
        
        [_myAuctCollectionView reloadData];
        //[self initCount];
        [self performSelector:@selector(refreshDoing) withObject:[NSNumber numberWithBool:YES] afterDelay:3.0];
        //_timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countdown) userInfo:nil repeats:YES];
        
    } else {
        if (result.message && result.message.length > 0) {
            [HMUtility showTip:result.message inView:self.view];
        }else{
            [HMUtility showTip:@"信息下载失败!" inView:self.view];
        }
    }
}

- (void)refreshAuctions:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestDoingRefreshId = 0;
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *ret = result.value;
        
        NSArray *data = [ret objectForKey:@"obj"];
        for (unsigned int i = 0; i < data.count; ++i) {
            [_resultArray replaceObjectAtIndex:i withObject:[data objectAtIndex:i]];
        }
        [self refreshPriceAndTimes];
    }
}


#pragma mark -
#pragma mark collection view methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return _resultArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MYAUCTCELL_REUSEID forIndexPath:indexPath];
        for (UIView *subview in cell.contentView.subviews) {
            [subview removeFromSuperview];
        }
        NSDictionary *audict = [_resultArray objectAtIndex:indexPath.row];
        HMNetImageView *iv = [[HMNetImageView alloc] initWithFrame:CGRectMake(5, 5, 140, 130)];
        iv.contentMode = UIViewContentModeScaleAspectFit;
        iv.image = [UIImage imageNamed:@"holder_320_180.png"];
        NSString *imgUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [audict objectForKey:@"image"]];
        iv.imageUrl = imgUrl;
        [iv load];
        [cell.contentView addSubview:iv];
        
        UILabel *labelCode = [[UILabel alloc] initWithFrame:CGRectMake(5, 140, 95, 15)];
        labelCode.backgroundColor = [UIColor clearColor];
        labelCode.font = [UIFont systemFontOfSize:11.0];
        labelCode.text = [NSString stringWithFormat:@"编号:%@", [audict objectForKey:@"code"]]; //[coupon objectForKey:@"name"];
        [cell.contentView addSubview:labelCode];
        
        UILabel *labelPrice = [[UILabel alloc] initWithFrame:CGRectMake(5, 155, 95, 15)];
        labelPrice.backgroundColor = [UIColor clearColor];
        labelPrice.font = [UIFont systemFontOfSize:11.0];
        labelPrice.textColor = [UIColor redColor];
        labelPrice.tag = 1003;
        NSNumber *price = [audict objectForKey:@"auctionPrice"];
        if (price) {
            labelPrice.text = [NSString stringWithFormat:@"当前价格:￥%@", price];
        }else{
            labelPrice.text = @"当前价格:未出价";
        }
        [cell.contentView addSubview:labelPrice];
        
        UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(5, 170, 140, 15)];
        labelName.backgroundColor = [UIColor clearColor];
        labelName.font = [UIFont systemFontOfSize:13.0];
        labelName.text = [audict objectForKey:@"artName"]; //[coupon objectForKey:@"name"];
        [cell.contentView addSubview:labelName];
    
        /**
        UILabel *labelRemain = [[UILabel alloc] initWithFrame:CGRectMake(5, 185, 140, 15)];
        labelRemain.backgroundColor = [UIColor clearColor];
        labelRemain.font = [UIFont systemFontOfSize:11.0];
        labelRemain.textColor = [UIColor redColor];
        labelRemain.tag = 1001;
        labelRemain.text = @"距离结束:";
        [cell.contentView addSubview:labelRemain];
        **/
        
        //出价按钮区域
        UIView *dealView = [[UIView alloc] initWithFrame:CGRectMake(100, 136, 45, 35)];
        dealView.backgroundColor = [UIColor brownColor];
        dealView.autoresizesSubviews = NO;
        dealView.tag = 10000 + indexPath.row;
        
        UILabel *labelDeal = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 45, 15)];
        labelDeal.backgroundColor = [UIColor clearColor];
        labelDeal.font = [UIFont systemFontOfSize:9.0];
        labelDeal.textColor = [UIColor whiteColor];
        labelDeal.textAlignment = NSTextAlignmentCenter;
        labelDeal.text = @"我要竞买";
        [dealView addSubview:labelDeal];
        
        UILabel *labelTimes = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 45, 20)];
        labelTimes.backgroundColor = [UIColor clearColor];
        labelTimes.font = [UIFont systemFontOfSize:9.0];
        labelTimes.textAlignment = NSTextAlignmentCenter;
        labelTimes.tag = 1002;
        NSInteger times = [[audict objectForKey:@"auctionNumber"] integerValue];
        labelTimes.text = [NSString stringWithFormat:@"出价%ld次", (long)times];
        [dealView addSubview:labelTimes];
    
        [cell.contentView addSubview:dealView];
        
        cell.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.contentView.layer.borderWidth = 1.0;
        return  cell;
    
    return nil;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
        NSDictionary *item = [_resultArray objectAtIndex:indexPath.row];
        HMAuctionDetail *ctrl = [[HMAuctionDetail alloc] initWithNibName:nil bundle:nil];
        ctrl.code = [item objectForKey:@"code"];
        //ctrl.level = [[item objectForKey:@"id"] integerValue];
        ctrl.title = [item objectForKey:@"artName"];
        [self.navigationController pushViewController:ctrl animated:YES];
    
    
}

- (void)tapDoingAuction:(UITapGestureRecognizer *)recognize
{
    NSInteger tag = [recognize.view tag];
    NSInteger row = tag - 10000;
    NSDictionary *item = [_resultArray objectAtIndex:row];
    HMAuctionDetail *ctrl = [[HMAuctionDetail alloc] initWithNibName:nil bundle:nil];
    ctrl.code = [item objectForKey:@"code"];
    ctrl.title = [item objectForKey:@"artName"];
    [self.navigationController pushViewController:ctrl animated:YES];
    
}

- (void)loadMoreDoingDown
{
    _pageIndex--;
    if (_pageIndex < 1) {
        _pageIndex = 1;
        return;
    }
    [self queryDoing];
}

- (void)loadMoreDoingUp
{
    _pageIndex++;
    if (_pageIndex > _pageCount) {
        _pageIndex = _pageCount;
        return;
    }
    [self queryDoing];
}

#pragma mark -
#pragma mark timer countdown
- (void)initCount
{
    for (int i = 0; i < _resultArray.count; i++) {
        NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:i inSection:0];
        UICollectionViewCell *cell = [_myAuctCollectionView cellForItemAtIndexPath:indexPath1];
        NSNumber *remainMilSeconds = [[_resultArray objectAtIndex:i] objectForKey:@"remainTime"];
        UILabel *labelRemain = (UILabel *)[cell.contentView viewWithTag:1001];
        if (remainMilSeconds && [remainMilSeconds longLongValue] > 0) {
            NSUInteger remainSeconds = [remainMilSeconds longLongValue] / 1000;
            labelRemain.text = [NSString stringWithFormat:@"距离结束:%@", [HMUtility compareCurrentTimeBySeconds:remainSeconds]];
            [_countSecondsArray addObject:[NSNumber numberWithInteger:remainSeconds]];
        }else{
            labelRemain.text = @"已结束";
            [_countSecondsArray addObject:[NSNumber numberWithInteger:0]];
        }
    }
}

- (void)countdown
{
    for (int i = 0; i < _resultArray.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UICollectionViewCell *cell = [_myAuctCollectionView cellForItemAtIndexPath:indexPath];
        NSUInteger remainSeconds = [[_countSecondsArray objectAtIndex:i] integerValue];
        if (remainSeconds > 0) {
            UILabel *labelRemain = (UILabel *)[cell.contentView viewWithTag:1001];
            labelRemain.text = [NSString stringWithFormat:@"距离结束:%@", [HMUtility compareCurrentTimeBySeconds:remainSeconds]];
            remainSeconds--;
            [_countSecondsArray replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:remainSeconds]];
        }
    }
}

- (void)refreshPriceAndTimes
{
    for (int i = 0; i < _resultArray.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UICollectionViewCell *cell = [_myAuctCollectionView cellForItemAtIndexPath:indexPath];
        NSDictionary *item = [_resultArray objectAtIndex:i];
        NSNumber *price = [item objectForKey:@"auctionPrice"];
        UILabel *labelPrice = (UILabel *)[cell.contentView viewWithTag:1003];
        if (price) {
            labelPrice.text = [NSString stringWithFormat:@"当前价格:￥%@", price];
        }else{
            labelPrice.text = @"当前价格:未出价";
        }
        NSInteger times = [[item objectForKey:@"auctionNumber"] integerValue];
        UILabel *labelTimes = (UILabel *)[cell.contentView viewWithTag:1002];
        labelTimes.text = [NSString stringWithFormat:@"出价%ld次", (long)times];
    }
}



@end
