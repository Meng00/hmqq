//
//  HMArtistList.m
//  hmArt
//
//  Created by wangyong on 13-7-11.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import "HMArtistList.h"
#import "HMArtistCell.h"
//#import "HMArtistInfo.h"
#import "HMUtility.h"
#import "HMSearchHome.h"

@interface HMArtistList ()

@end

@implementation HMArtistList

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"艺术家列表";
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
    [HMUtility navBar:self.navigationController.navigationBar backImage:@"home_bg.png" backTag:HM_SYS_NAVIBARBG_TAG];
    self.tabBarController.tabBar.hidden=YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
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
    
    // 右侧按钮
    UIBarButtonItem *rightButton =  [[UIBarButtonItem alloc] initWithTitle:@"我要搜索" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonDown:)];
    
    self.navigationItem.rightBarButtonItem = rightButton;

    
    [self query];
}

- (void)rightButtonDown:(id)sender
{
        HMSearchHome *ctrl = [[HMSearchHome alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:ctrl animated:YES];
//    self.tabBarController.selectedIndex = 1;
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"HMShowSearchViewAtHome" object:nil];
    
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
    [queryParam setValue:[NSNumber numberWithInteger:0] forKey:@"rec"];
    if (_keyword && _keyword.length > 0) {
        [queryParam setValue:_keyword forKey:@"keyword"];
    }
    if (_area && _area.length > 0) {
        [queryParam setValue:_area forKey:@"area"];
    }
    
    _requestId = [net asynRequest:interfaceArtistSearch with:queryParam needSSL:NO target:self action:@selector(dealArtists:result:)];
    
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    
}

- (void)dealArtists:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestId = 0;
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *ret = result.value;
        NSLog(@"%@",ret);
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
            [HMUtility showTip:@"%@查询失败!" inView:self.view];
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
    return 110.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"hmArtistCell";
    
    HMArtistCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [HMUtility loadViewFromNib:@"HMArtistCell" withClass:[HMArtistCell class]];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    NSDictionary *dic = [_resultArray objectAtIndex:indexPath.row];
//    cell.nameLabel.text = [NSString stringWithFormat:@"竞买号：%@", [item objectForKey:@"code"]];
    cell.nameLabel.text = [NSString stringWithFormat:@"作者：%@", [dic objectForKey:@"name"]];
    cell.birthLabel.text =  [dic objectForKey:@"birthDate"];
    cell.hometownLabel.text = [dic objectForKey:@"nativePlace"];
    NSString *credit = [HMUtility getString:[NSString stringWithFormat:@"%@", [dic objectForKey:@"creditRating"]]];
    
    if (credit.length > 0) {
        [cell setLevel:[credit integerValue]];
    } else
        [cell setLevel:0];
    NSString *image = [HMUtility getString:[dic objectForKey:@"photos"]];
    if (image.length > 0) {
        cell.portraitImage.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, image];
        [cell.portraitImage load];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [_resultArray objectAtIndex:indexPath.row];
    HMArtistDetail *detail = [[HMArtistDetail alloc] initWithNibName:nil bundle:nil];
    detail.artistId= [[dic objectForKey:@"id"] integerValue];
    [self.navigationController pushViewController:detail animated:YES];
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
