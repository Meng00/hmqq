//
//  HMAuctionPreview.m
//  hmArt
//
//  Created by wangyong on 14-8-25.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMAuctionPreview.h"

@interface HMAuctionPreview ()

@end

#define CELL_REUSEID @"PreviewCollectionCell"

@implementation HMAuctionPreview

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title =  @"竞买预展";
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
    
    //NSDate *d = [HMUtility dateFrom:_auditDate withFormat:@"yyyy-MM-dd" timeZone:nil];
    //NSString *cs = [HMUtility stringFromDate:d withFormat:@"yyyy年M月d日" timeZone:nil];
    _auditDateLabel.text = _auditDate;
    _items = [[NSMutableArray alloc] init];
    
    _titleView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _titleView.layer.borderWidth = 1.0;
    
    
    CGRect rect = _collectionView.frame;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - HM_SYS_VIEW_OFFSET - rect.origin.y;
    _collectionView.frame = rect;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CELL_REUSEID];
    
    _auditDateLabel.text = _auditDate;
    _titleNameLabel.text = _titleName;
    _pageIndex = 1;
    _pageSize = 50;
    [self query];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (_requestId != 0) {
        [[LCNetworkInterface sharedInstance] cancelRequest:_requestId];
    }
    [super viewWillDisappear:animated];
}

- (void)setParams:(NSString *)params
{
    NSDictionary *dicParam = [HMUtility parametersWithSeparator:@"=" delimiter:@"&" url:params];
    _level = [[dicParam objectForKey:@"areaId"] integerValue];
    _auditDate = [dicParam objectForKey:@"date"];
}


#pragma mark -
#pragma mark collection view methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_REUSEID forIndexPath:indexPath];
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.contentView.autoresizesSubviews = NO;
    NSDictionary *item = [_items objectAtIndex:indexPath.row];
    HMNetImageView *iv = [[HMNetImageView alloc] initWithFrame:CGRectMake(3, 3, 144, 128)];
    iv.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [item objectForKey:@"image"]];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [iv load];
    [cell.contentView addSubview:iv];
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 154, 140, 20)];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.font = [UIFont systemFontOfSize:13.0];
    labelTitle.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"artName"]]; //[coupon objectForKey:@"name"];
    [cell.contentView addSubview:labelTitle];
    
    UILabel *labelCode = [[UILabel alloc] initWithFrame:CGRectMake(5, 134, 140, 20)];
    labelCode.backgroundColor = [UIColor clearColor];
    labelCode.font = [UIFont systemFontOfSize:13.0];
    labelCode.text = [NSString stringWithFormat:@"编号：%@", [item objectForKey:@"code"]];
    [cell.contentView addSubview:labelCode];
    
    UILabel *labelPrice = [[UILabel alloc] initWithFrame:CGRectMake(5, 174, 140, 20)];
    labelPrice.backgroundColor = [UIColor clearColor];
    labelPrice.font = [UIFont systemFontOfSize:13.0];
    labelPrice.text = [NSString stringWithFormat:@"起拍价格：￥%@", [item objectForKey:@"initPrice"]];
    [cell.contentView addSubview:labelPrice];
    
//    UILabel *labelDate = [[UILabel alloc] initWithFrame:CGRectMake(5, 194, 140, 36)];
//    labelDate.backgroundColor = [UIColor clearColor];
//    labelDate.font = [UIFont systemFontOfSize:13.0];
//    labelDate.textColor = [UIColor redColor];
//    labelDate.numberOfLines = 2;
//    labelDate.lineBreakMode = NSLineBreakByWordWrapping;
//    labelDate.text = [NSString stringWithFormat:@"%@开拍", [item objectForKey:@"auctionStartTime"]];
//    [cell.contentView addSubview:labelDate];
    
    UIButton *subbut = [UIButton buttonWithType:UIButtonTypeCustom];
    subbut.frame = CGRectMake(5, 194, 140, 30);
    subbut.tag = [[item objectForKey:@"id"] integerValue];
    subbut.titleLabel.tag = indexPath.row;
    if ([item objectForKey:@"subscribe"] && [[item objectForKey:@"subscribe"] boolValue]) {
        [subbut setTitle:@"取消提醒" forState:UIControlStateNormal];
    }else{
        [subbut setTitle:@"开拍提醒" forState:UIControlStateNormal];
    }
    [subbut setBackgroundImage:[UIImage imageNamed:@"btn_bg_brown.png"] forState:UIControlStateNormal];
    [subbut addTarget:self action:@selector(butSubscribe:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:subbut];
    
    cell.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.contentView.layer.borderWidth = 1.0;
    return  cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *auction = [_items objectAtIndex:indexPath.row];
    HMAuctionDetail *ctrl = [[HMAuctionDetail alloc] initWithNibName:nil bundle:nil];
    ctrl.code = [auction objectForKey:@"code"];
    [self.navigationController pushViewController:ctrl animated:YES];
}

#pragma mark -
#pragma mark query methods
- (void)query
{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 3];
    [queryParam setValue:[NSNumber numberWithInteger:_pageIndex] forKey:@"pageIndex"];
    [queryParam setValue:[NSNumber numberWithInteger:_pageSize] forKey:@"pageSize"];
    [queryParam setValue:[HMGlobalParams sharedInstance].mobile forKey:@"username"];
    if (_level) {
        [queryParam setValue:[NSNumber numberWithInteger:_level] forKey:@"level"];
    }
    if (_areaListId) {
        [queryParam setValue:[NSNumber numberWithInteger:_areaListId] forKey:@"areaListId"];
    }
    [queryParam setValue:[NSNumber numberWithInteger:3] forKey:@"type"];
    //[queryParam setValue:_auditDate forKey:@"startTime"];
    //[queryParam setValue:_auditDate forKey:@"endTime"];
    
    _requestId = [net asynRequest:interfaceAuctionSearch with:queryParam needSSL:NO target:self action:@selector(dealAuctions:result:)];
    
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    
}

- (void)dealAuctions:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestId = 0;
    [_collectionView footerEndRefreshing];
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *ret = result.value;
        if (_pageIndex == 1) {
            [_items removeAllObjects];
        }
        [_collectionView footerEndRefreshing];
        NSArray *data = [ret objectForKey:@"obj"];
        for (NSDictionary *audit in data) {
            [_items addObject:audit];
        }
        _pageCount = [[ret objectForKey:@"pageCount"] integerValue];
        if (_pageIndex < _pageCount) {
            [_collectionView addFooterWithTarget:self action:@selector(loadMore)];
            _collectionView.footerPullToRefreshText = [NSString stringWithFormat:@"第%ld页/共%ld页 上拉加载下一页", (long)_pageIndex, (long)_pageCount];
            _collectionView.footerRefreshingText = @"正在加载数据，请耐心等待...";
            _collectionView.footerReleaseToRefreshText = @"松开马上加载更多数据...";
        }else{
            [_collectionView removeFooter];
        }
        [_collectionView reloadData];
        
    } else {
        if (result.message && result.message.length > 0) {
            [HMUtility showTip:result.message inView:self.view];
        }else{
            [HMUtility showTip:@"%@查询失败!" inView:self.view];
        }
    }
}


- (void)loadMore
{
    _pageIndex++;
    if (_pageIndex > _pageCount) {
        return;
    }
    [self query];
}

- (void)butSubscribe:(UIButton *)but
{
    NSInteger tag = [but tag];
    NSLog(@"tag = %i", tag);
    
    HMGlobalParams *params = [HMGlobalParams sharedInstance];
    if (params.anonymous) {
        HMLoginEx *ctrl = [[HMLoginEx alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:ctrl animated:YES];
        return;
    }

    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 2];
    [queryParam setValue:params.mobile forKey:@"username"];
    [queryParam setValue:[NSNumber numberWithInteger:tag] forKey:@"auctionId"];
    [queryParam setValue:[NSNumber numberWithInteger:[but.titleLabel tag]] forKey:@"index"];
    
    if([but.titleLabel.text isEqualToString:@"开拍提醒"]){
        _requestId = [net asynRequest:interfaceAuctionSms with:queryParam needSSL:NO target:self action:@selector(dealSubscribe:result:)];
    }else{
        _requestId = [net asynRequest:interfaceAuctionSmsCancel with:queryParam needSSL:NO target:self action:@selector(dealSubscribe:result:)];
    }
    
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];

}

- (void)dealSubscribe:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestId = 0;
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *ret = [result.value objectForKey:@"obj"];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[ret objectForKey:@"index"] integerValue] inSection:0];
        UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:indexPath];
        UIButton *subbut = (UIButton *)[cell.contentView viewWithTag:[[ret objectForKey:@"auctionId"] integerValue]];
        if ([[ret objectForKey:@"type"] integerValue] == 1) {
            [subbut setTitle:@"取消提醒" forState:UIControlStateNormal];
        }else{
            [subbut setTitle:@"开拍提醒" forState:UIControlStateNormal];
        }
        
        
    }
    
}

@end
