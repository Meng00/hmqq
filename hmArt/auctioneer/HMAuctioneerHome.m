//
//  HMAuctioneerHome.m
//  hmArt
//
//  Created by 刘学 on 15-7-6.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import "HMAuctioneerHome.h"

@interface HMAuctioneerHome ()

@end

#define CELL_REUSEID @"HMAuctioneerHomeCell"

@implementation HMAuctioneerHome

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"拍卖商";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _titleName;
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"view_bg.png"]];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    
    // 右侧按钮
//    UIBarButtonItem *rightButton =  [[UIBarButtonItem alloc] initWithTitle:@"我要搜索" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonDown:)];
//    
//    self.navigationItem.rightBarButtonItem = rightButton;
    
    _items = [[NSMutableArray alloc] initWithCapacity:1];
    
    CGRect rect = _collectionView.frame;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - HM_SYS_VIEW_OFFSET - rect.origin.y;
    _collectionView.frame = rect;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CELL_REUSEID];
    
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
    NSDictionary *cate = [_items objectAtIndex:indexPath.row];
    
    HMNetImageView *iv = [[HMNetImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 100)];
    iv.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [cate objectForKey:@"image"]];
    [iv load];
    [cell.contentView addSubview:iv];
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 101, 150, 20)];
    labelTitle.backgroundColor = [UIColor brownColor];
    labelTitle.font = [UIFont systemFontOfSize:13.0];
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.text = [cate objectForKey:@"name"];
    [cell.contentView addSubview:labelTitle];
    cell.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.contentView.layer.borderWidth = 1.0;
    return  cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *cate = [_items objectAtIndex:indexPath.row];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.backBarButtonItem = item;
    HMAuctioneerArtwords *ctrl = [[HMAuctioneerArtwords alloc] initWithNibName:nil bundle:nil];
    ctrl.auctioneerId = [[cate objectForKey:@"id"] integerValue];
    ctrl.auctioneerName = [cate objectForKey:@"name"];
    ctrl.auctioneerImage = [cate objectForKey:@"image"];
    [self.navigationController pushViewController:ctrl animated:YES];
}


#pragma mark -
#pragma mark query methods
- (void)query
{
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    
    _requestId = [net asynRequest:interfaceAuctioneerList with:nil needSSL:NO target:self action:@selector(dealCategory:withResult:)];
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
}

- (void)dealCategory:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestId = 0;
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSArray *ret = [result.value objectForKey:@"obj"];
        for (NSDictionary *cate in ret) {
            [_items addObject:cate];
        }
        [_collectionView reloadData];
    }else{
        if ([result.message length]>0) {
            [HMUtility showTip:result.message inView:self.view];
        }else{
            [HMUtility showTip:@"拍卖行信息加载失败！" inView:self.view];
        }
    }
}

- (void)setParams:(NSString *)params
{
    NSDictionary *dicParam = [HMUtility parametersWithSeparator:@"=" delimiter:@"&" url:params];
    self.titleName = [dicParam objectForKey:@"title"];
    self.title = [dicParam objectForKey:@"title"];
}


@end
