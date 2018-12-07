//
//  HMAuctioneerArtwords.m
//  hmArt
//
//  Created by 刘学 on 15-7-7.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import "HMAuctioneerArtwords.h"

@interface HMAuctioneerArtwords ()

@end

@implementation HMAuctioneerArtwords

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"作品列表";
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
    
    
//
    CGRect rect = _resultTable.frame;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - HM_SYS_VIEW_OFFSET;
    _resultTable.frame = rect;
    
    _resultArray = [[NSMutableArray alloc] initWithCapacity:1];
    _dataLoaded = NO;
    
    _pageSize = 10;
    _pageIndex = 1;
    _resultTable.tableHeaderView = nil;
    _resultTable.disableRefreshing = YES;
    _resultTable.disableLoadingMore = YES;
    _resultTable.backgroundColor = [UIColor clearColor];
    
    [self query];
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
    
    [queryParam setValue:[NSNumber numberWithInteger:_auctioneerId] forKey:@"auctioneerId"];
    
    _requestId = [net asynRequest:interfaceAuctioneerArtwork with:queryParam needSSL:NO target:self action:@selector(dealPictures:result:)];
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    
}

- (void)dealPictures:(NSString *)serviceName result:(LCInterfaceResult *)result
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
        
        NSArray *pictures = [ret objectForKey:@"obj"];
        
        for (unsigned int i = 0; i < pictures.count; ++i) {
            [_resultArray addObject:[pictures objectAtIndex:i]];
        }
        _pageCount = [[ret objectForKey:@"pageCount"] integerValue];
        if (_pageIndex < _pageCount) {
            _resultTable.disableLoadingMore = NO;
            [_resultTable setLoadingMoreText:[NSString stringWithFormat:@"第%ld页/共%ld页 上拉加载下一页", (long)_pageIndex, (long)_pageCount] forState:EGOOPullNormal];
        }else{
            _resultTable.disableLoadingMore = YES;
        }
        
        _dataLoaded = YES;
        [_resultTable reloadData];
        _resultTable.pullTableIsLoadingMore = NO;
        
    } else {
        [HMUtility alert:@"下载失败!" title:@"提示"];
        [HMUtility tap2Action:@"重新加载" on:self.view target:self action:@selector(query)];
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
        label.text = @"没有展品信息";
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
    static NSString *CellIdentifier = @"auctArtworksCell";
    
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
    
    HMNetImageView *iv = [[HMNetImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    iv.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [dic objectForKey:@"image"]];
    [iv load];
    [cellView addCustomSubview:iv intervalLeft:0];
    
    LCView *rightView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, 0, 120)];
    [cellView setPaddingTop:3 paddingBottom:3 paddingLeft:3 paddingRight:3];
    [cellView addCustomSubview:rightView intervalLeft:5];
    
    UILabel *artName = [[UILabel alloc] init];
    artName.text = [dic objectForKey:@"artName"];
    //artName.textColor = [UIColor redColor];
    artName.font = [UIFont systemFontOfSize:14.0f];
    [rightView addCustomSublabel:artName intervalTop:0 textMaxShowWidth:0 textMaxShowHeight:45];
    
    UILabel *artist = [[UILabel alloc] init];
    artist.text = [NSString stringWithFormat:@"作   者:%@", [dic objectForKey:@"artist"]];
    //artist.textColor = [UIColor redColor];
    artist.font = [UIFont systemFontOfSize:14.0f];
    [rightView addCustomSublabel:artist intervalTop:5];
    
    UILabel *artSize = [[UILabel alloc] init];
    artSize.text = [NSString stringWithFormat:@"尺   寸:%@", [dic objectForKey:@"artSize"]];
    //artSize.textColor = [UIColor redColor];
    artSize.font = [UIFont systemFontOfSize:14.0f];
    [rightView addCustomSublabel:artSize intervalTop:5];
    
    UILabel *artCreateTime = [[UILabel alloc] init];
    artCreateTime.text = [NSString stringWithFormat:@"创作时间:%@", [dic objectForKey:@"artCreateTime"]];
    //artCreateTime.textColor = [UIColor redColor];
    artCreateTime.font = [UIFont systemFontOfSize:14.0f];
    [rightView addCustomSublabel:artCreateTime intervalTop:5];
    
    if([dic objectForKey:@"initPrice"]){
        UILabel *sortLable = [[UILabel alloc] init];
        sortLable.text = [NSString stringWithFormat:@"价   格:￥%@", [dic objectForKey:@"initPrice"]];
        sortLable.font = [UIFont systemFontOfSize:14.0f];
        [rightView addCustomSublabel:sortLable intervalTop:3];
    }
    
    [cellView resize];
    
    float h = cellView.frame.size.height+cellView.frame.origin.y;
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width,h);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [_resultArray objectAtIndex:indexPath.row];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    HMAuctioneerArtwordDetail *ctrl = [[HMAuctioneerArtwordDetail alloc] initWithNibName:nil bundle:nil];
    ctrl.title = [dic objectForKey:@"artName"];
    ctrl.artworkId = [[dic objectForKey:@"id"] integerValue];
    ctrl.auctioneerName = _auctioneerName;
    ctrl.auctioneerImage = _auctioneerImage;
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
