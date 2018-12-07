//
//  HMMemberCoupon.m
//  hmArt
//
//  Created by wangyong on 14-8-14.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMMemberCoupon.h"

@interface HMMemberCoupon ()

@end

#define CELL_REUSEID @"CouponCollectionCell"

@implementation HMMemberCoupon

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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"view_bg.png"]];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];

    _items = [[NSMutableArray alloc] init];

    _titleView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _titleView.layer.borderWidth = 1.0;


    CGRect rect = _collectionView.frame;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - HM_SYS_VIEW_OFFSET - rect.origin.y;
    _collectionView.frame = rect;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CELL_REUSEID];

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapNotice:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    _noticeLabel.userInteractionEnabled = YES;
    [_noticeLabel addGestureRecognizer:tap];
    
    _pageIndex = 1;
    _pageSize = 10;
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

#pragma mark -
#pragma mark event handler
- (void)tapNotice:(UITapGestureRecognizer *)tap
{
    LCWebView *web = [[LCWebView alloc] initWithNibName:nil bundle:nil];
    web.url = kUrlVoucher;
    web.title = @"代金券使用须知";
    [self.navigationController pushViewController:web animated:YES];
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
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 165)];
    view.backgroundColor = [UIColor whiteColor];
    view.autoresizesSubviews = NO;
    NSDictionary *coupon = [_items objectAtIndex:indexPath.row];
    HMNetImageView *iv = [[HMNetImageView alloc] initWithFrame:CGRectMake(5, 5, 140, 100)];
    iv.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [coupon objectForKey:@"image"]];
    [iv load];
    [view addSubview:iv];
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 105, 140, 20)];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.font = [UIFont systemFontOfSize:13.0];
    labelTitle.text = [NSString stringWithFormat:@"代金券%@元", [coupon objectForKey:@"price"]]; //[coupon objectForKey:@"name"];
    [view addSubview:labelTitle];

    UILabel *labelDesc = [[UILabel alloc] initWithFrame:CGRectMake(5, 125, 140, 20)];
    labelDesc.backgroundColor = [UIColor clearColor];
    labelDesc.font = [UIFont systemFontOfSize:11.0];
    labelDesc.textColor = [UIColor redColor];
    labelDesc.text = [coupon objectForKey:@"expensStr"];
    [view addSubview:labelDesc];

    UILabel *labelExpired = [[UILabel alloc] initWithFrame:CGRectMake(2, 145, 146, 20)];
    labelExpired.backgroundColor = [UIColor clearColor];
    labelExpired.font = [UIFont systemFontOfSize:11.0];
    NSMutableString *str = [[NSMutableString alloc] init];
    NSString *sExpire = [coupon objectForKey:@"expires"];
    sExpire = [sExpire substringToIndex:10];
    [str appendFormat:@"有效期：%@",sExpire];
    NSInteger couponStatus = [[coupon objectForKey:@"status"] integerValue];
    switch (couponStatus) {
        case 2:
            [str appendString:@"(已使用)"];
            break;
        case 3:
            [str appendString:@"(已过期)"];
            break;
        case 4:
            [str appendString:@"(已冻结)"];
            break;
            
        default:
            break;
    }
    labelExpired.text = str;
    [view addSubview:labelExpired];

    [cell.contentView addSubview:view];
    cell.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.contentView.layer.borderWidth = 1.0;
    return  cell;
}

#pragma mark -
#pragma mark query methods
- (void)query
{
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    if ([HMGlobalParams sharedInstance].anonymous) {
        return;
    }
    NSMutableDictionary *queryParams = [[NSMutableDictionary alloc] initWithCapacity:3];
    [queryParams setObject:[HMGlobalParams sharedInstance].mobile forKey:@"username"];
    [queryParams setObject:[NSNumber numberWithInteger:_pageIndex] forKey:@"pageIndex"];
    [queryParams setObject:[NSNumber numberWithInteger:_pageSize] forKey:@"pageSize"];
    
    _requestId = [net asynRequest:interfaceVouchersList with:queryParams needSSL:NO target:self action:@selector(dealCoupons:withResult:)];
}
- (void)dealCoupons:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    _requestId = 0;
    [_collectionView footerEndRefreshing];
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSLog(@"%@", result.value);
        NSDictionary *ret = result.value;
        NSArray *cateList = [ret objectForKey:@"obj"];
        if (_pageIndex == 1) {
            [_items removeAllObjects];
        }
        for (NSDictionary* each in cateList) {
            [_items addObject:each];
        }
        [_collectionView footerEndRefreshing];
        _pageCount = [[ret objectForKey:@"pageCount"] integerValue];
        _total = [[ret objectForKey:@"total"] integerValue];
        NSString *count = [NSString stringWithFormat:@"%ld张", (long)_total];
        _countLabel.text = count;
        [_countLabel setColor:[UIColor redColor] fromIndex:0 length:(count.length - 1)];
        [_countLabel setFont:[UIFont systemFontOfSize:14.0] fromIndex:0 length:count.length];
        
        if (_pageIndex < _pageCount) {
            [_collectionView addFooterWithTarget:self action:@selector(loadMore)];
            _collectionView.footerPullToRefreshText = [NSString stringWithFormat:@"第%ld页/共%ld页 上拉加载下一页", (long)_pageIndex, (long)_pageCount];
            _collectionView.footerRefreshingText = @"正在加载数据，请耐心等待...";
            _collectionView.footerReleaseToRefreshText = @"松开马上加载更多数据...";
        }else{
            [_collectionView removeFooter];
        }
        [_collectionView reloadData];
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
@end
