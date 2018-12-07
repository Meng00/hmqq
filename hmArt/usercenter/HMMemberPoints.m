//
//  HMMemberPoints.m
//  hmArt
//
//  Created by wangyong on 14-8-14.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMMemberPoints.h"

@interface HMMemberPoints ()

@end

#define CELL_REUSEID @"PointsCollectionCell"


@implementation HMMemberPoints

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"积分商城";
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
    
    CGRect rect = _collectionView.frame;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - HM_SYS_VIEW_OFFSET - rect.origin.y;
    _collectionView.frame = rect;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CELL_REUSEID];
    
    [self queryCategory];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark -
#pragma mark event handler
- (void)tapRecords:(UITapGestureRecognizer *)tap
{
    HMMemberPointRecords *ctrl = [[HMMemberPointRecords alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:ctrl animated:YES];
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
    HMNetImageView *iv = [[HMNetImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    NSDictionary *cate = [_items objectAtIndex:indexPath.row];
    iv.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [cate objectForKey:@"image"]];
    [iv load];
    [cell.contentView addSubview:iv];
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 100, 20)];
    labelTitle.backgroundColor = [UIColor brownColor];
    labelTitle.font = [UIFont systemFontOfSize:14.0];
    labelTitle.adjustsFontSizeToFitWidth = YES;
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.text = [cate objectForKey:@"name"];
    [cell.contentView addSubview:labelTitle];
    cell.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.contentView.layer.borderWidth = 1.0;
    return  cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    HMMemberPointProduct *ctrl = [[HMMemberPointProduct alloc] initWithNibName:nil bundle:nil];
    NSDictionary *cate = [_items objectAtIndex:indexPath.row];
    ctrl.categoryId = [[cate objectForKey:@"id"] integerValue];
    ctrl.categoryName = [cate objectForKey:@"name"];
    [self.navigationController pushViewController:ctrl animated:YES];
}

#pragma mark -
#pragma mark query methods
- (void)queryCategory
{
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestCateId != 0) {
        [net cancelRequest:_requestCateId];
    }
    
    _requestCateId = [net asynRequest:interfaceMemberGiftCategory with:nil needSSL:NO target:self action:@selector(dealCategories:withResult:)];
}
- (void)dealCategories:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    _requestCateId = 0;
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSArray *cateList = [result.value objectForKey:@"obj"];
        for (NSDictionary* each in cateList) {
            [_items addObject:each];
        }
        [_collectionView reloadData];
    }
}



@end
