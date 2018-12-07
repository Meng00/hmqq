//
//  HMFavoriteList.m
//  hmArt
//
//  Created by wangyong on 13-6-16.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import "HMFavoriteList.h"
#import "LCAlertView.h"
@interface HMFavoriteList ()

@end

@implementation HMFavoriteList

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"我的收藏";
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
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - HM_SYS_VIEW_OFFSET;
    _resultTable.frame = rect;
    
    _resultArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    _pageSize = 10;
    _pageIndex = 1;
    _resultTable.tableHeaderView = nil;
    _resultTable.disableRefreshing = YES;
    _resultTable.disableLoadingMore = YES;
    _resultTable.backgroundColor = [UIColor clearColor];
    

    _curIndexPath = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setResultTable:nil];
    [self setActivity:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    HMGlobalParams *params = [HMGlobalParams sharedInstance];
    if (params.anonymous) {
        HMLoginEx *login = [[HMLoginEx alloc] initWithNibName:nil bundle:nil];
        login.hideBackButton = YES;
        [self.navigationController pushViewController:login animated:YES];
    }else{
        //if (!_dataLoaded)
        [self query];
    }

}
- (void)viewWillDisappear:(BOOL)animated
{
    if (_requestId > 0) {
        LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
         [net cancelRequest:_requestId];
    }
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
    [queryParam setObject:[HMGlobalParams sharedInstance].mobile forKey:@"username"];
    
    _requestId = [net asynRequest:interfaceFavoriteList with:queryParam needSSL:NO target:self action:@selector(dealFavoriteList:result:)];
    
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    
}

- (void)dealFavoriteList:(NSString *)serviceName result:(LCInterfaceResult *)result
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
        if (_pageIndex < _pageCount) {
            _resultTable.disableLoadingMore = NO;
            [_resultTable setLoadingMoreText:[NSString stringWithFormat:@"第%ld页/共%ld页 上拉加载下一页", (long)_pageIndex, (long)_pageCount] forState:EGOOPullNormal];
        }else{
            _resultTable.disableLoadingMore = YES;
        }
        [self checkRightButton];
        [_resultTable reloadData];
        _resultTable.pullTableIsLoadingMore = NO;
        
    } else {
        if (result.message && result.message.length > 0) {
            [HMUtility showTip:result.message inView:self.view];
        }else{
            [HMUtility showTip:@"收藏信息下载失败!" inView:self.view];
        }
    }
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 140.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"hmPictureCell";
    
    HMPictureCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [HMUtility loadViewFromNib:@"HMPictureCell" withClass:[HMPictureCell class]];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    NSDictionary *dic = [_resultArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = [dic objectForKey:@"artName"];
    cell.sizeLabel.text = [dic objectForKey:@"artist"];
//    cell.priceLabel.text = [NSString stringWithFormat:@"售价:￥%@", [dic objectForKey:@"price"]];
    cell.timeLabel.text = [dic objectForKey:@"createDate"];
    cell.picImage.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [dic objectForKey:@"image"]];
    [cell.picImage load];


    cell.priceLabel.hidden = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [_resultArray objectAtIndex:indexPath.row];
    HMPaintingDetail *info = [[HMPaintingDetail alloc] initWithNibName:nil bundle:nil];
    info.paintingId = [[dic objectForKey:@"artId"] integerValue];
    [self.navigationController pushViewController:info animated:YES];
    
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _curIndexPath = indexPath;
        [LCAlertView showWithTitle:nil message:@"确认删除吗?" cancelTitle:@"取消" cancelBlock:nil otherTitle:@"确定" otherBlock:^{[self removeFavorite];}];
        
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
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

- (void)favoriteButtonDown:(id)sender
{
    if (_resultArray.count < 1) {
        return;
    }
    UIBarButtonItem *barButton = self.navigationItem.rightBarButtonItem;
    if ([barButton.title isEqualToString:@"取消收藏"]) {
        [barButton setTitle:@"完成"];
        [self.resultTable setEditing:YES animated:YES];
    }else{
        [barButton setTitle:@"取消收藏"];
        [self.resultTable setEditing:NO animated:NO];
    }
}

- (void)removeFavorite
{

    NSDictionary *dic = [_resultArray objectAtIndex:_curIndexPath.row];

    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity:4];
    [queryParam setObject:[dic objectForKey:@"id"] forKey:@"id"];
    [queryParam setObject:[HMGlobalParams sharedInstance].mobile forKey:@"username"];
    
    _requestId = [net asynRequest:interfaceFavoriteDel with:queryParam needSSL:NO target:self action:@selector(dealFavoriteDel:withResult:)];
    
    
}
- (void)dealFavoriteDel:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    //[_activity stopAnimating];
    //[HMUtility dismissModalView:_activity];
    _requestId = 0;
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        [_resultArray removeObjectAtIndex:_curIndexPath.row];
        [self.resultTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:_curIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self checkRightButton];
    } else {
        if (result.message && result.message.length > 0) {
            [HMUtility showTip:result.message inView:self.view];
        }else{
            [HMUtility showTip:@"删除失败，请重新操作!" inView:self.view];
        }
    }
}

- (void)checkRightButton
{
    if (_resultArray.count>0) {
        // 右侧按钮
        UIBarButtonItem *favoriteButton =  [[UIBarButtonItem alloc] initWithTitle:@"取消收藏" style:UIBarButtonItemStyleDone target:self action:@selector(favoriteButtonDown:)];
        
        self.navigationItem.rightBarButtonItem = favoriteButton;
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
}

@end
