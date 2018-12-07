//
//  HMArtistInfoList.m
//  hmArt
//
//  Created by wangyong on 13-7-12.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import "HMArtistInfoList.h"
#import "HMUtility.h"
#import "HMInformation.h"

@interface HMArtistInfoList ()

@end

@implementation HMArtistInfoList

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

    switch (_infoType) {
        case 1:
        {
            _infoStr = @"活动信息";
            _typeForMarco = kInfoTypeActivity;
        }
           break;
        case 2:
        {
            _infoStr = @"获奖信息";
            _typeForMarco = kInfoTypePrize;
        }
            break;
        case 3:
        {
            _infoStr = @"出版信息";
             _typeForMarco = kInfoTypePublish;
        }
            break;
        default:
        {
            _infoStr = @"展览信息";
             _typeForMarco = kInfoTypeExhibition;
        }
             break;
    }
    self.title = [NSString stringWithFormat:@"%@列表", _infoStr];

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
    [queryParam setValue:[NSNumber numberWithInteger:_artistId] forKey:@"artistId"];
    [queryParam setValue:[NSNumber numberWithInteger:_pageIndex] forKey:@"pageIndex"];
    [queryParam setValue:[NSNumber numberWithInteger:_pageSize] forKey:@"pageSize"];
    switch (_infoType) {
        case 1:
        {
            _requestId = [net asynRequest:interfaceArtistAcitvitySearch with:queryParam needSSL:NO target:self action:@selector(dealArtistInfo:withResult:)];
        }
            break;
        case 2:
        {
            _requestId = [net asynRequest:interfaceArtistAwardsSearch with:queryParam needSSL:NO target:self action:@selector(dealArtistInfo:withResult:)];
        }
            break;
        case 3:
        {
            _requestId = [net asynRequest:interfaceArtistCopyrightSearch with:queryParam needSSL:NO target:self action:@selector(dealArtistInfo:withResult:)];
        }
            break;
            
        default:
        {
            _requestId = [net asynRequest:interfaceArtistExpoSearch with:queryParam needSSL:NO target:self action:@selector(dealArtistInfo:withResult:)];
        }
            break;
    }
    
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    
}

- (void)dealArtistInfo:(NSString *)serviceName withResult:(LCInterfaceResult *)result
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
            [HMUtility showTip:@"信息下载失败!" inView:self.view];
        }
    }
}


- (void)queryInfoDetail:(NSInteger)infoId
{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity:1];
    [queryParam setValue:[NSNumber numberWithInteger:infoId] forKey:@"id"];
    switch (_infoType) {
        case 1:
        {
            _requestId = [net asynRequest:interfaceArtistAcitvityDetail with:queryParam needSSL:NO target:self action:@selector(dealInfoDetail:withResult:)];
        }
            break;
        case 2:
        {
            _requestId = [net asynRequest:interfaceArtistAwardsDetail with:queryParam needSSL:NO target:self action:@selector(dealInfoDetail:withResult:)];
        }
            break;
        case 3:
        {
            _requestId = [net asynRequest:interfaceArtistCopyrightDetail with:queryParam needSSL:NO target:self action:@selector(dealInfoDetail:withResult:)];
        }
            break;
            
        default:
        {
            _requestId = [net asynRequest:interfaceArtistExpoDetail with:queryParam needSSL:NO target:self action:@selector(dealInfoDetail:withResult:)];
        }
            break;
    }
    
    
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    
}
- (void)dealInfoDetail:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestId = 0;
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *ret = result.value;
        NSDictionary *obj = [ret objectForKey:@"obj"];
        switch (_typeForMarco) {
            case kInfoTypeActivity:
            {
                
                HMInformation *info = [[HMInformation alloc] initWithTitle:[NSString stringWithFormat:@"%@-活动信息", _artistName]];
                info.framesArray = [obj objectForKey:@"data"];
                info.infoDictionary = obj;
                info.infoType = _typeForMarco;
                [self.navigationController pushViewController:info animated:YES];
            }
                 break;
            case kInfoTypePrize:
            {
                HMInformation *info = [[HMInformation alloc] initWithTitle:[NSString stringWithFormat:@"%@-获奖信息", _artistName]];
                info.framesArray = [obj objectForKey:@"data"];
                info.infoDictionary = obj;
                info.infoType = _typeForMarco;
                [self.navigationController pushViewController:info animated:YES];
            }
                break;
            case kInfoTypePublish:
            {
                 HMInformation *info = [[HMInformation alloc] initWithTitle:[NSString stringWithFormat:@"%@-出版信息", _artistName]];
                info.framesArray = [obj objectForKey:@"data"];
                info.infoDictionary = obj;
                info.infoType = _typeForMarco;
                [self.navigationController pushViewController:info animated:YES];
            }
                break;
            case kInfoTypeExhibition:
            {
                 HMInformation *info = [[HMInformation alloc] initWithTitle:[NSString stringWithFormat:@"%@-展览信息", _artistName]];
                info.framesArray = [obj objectForKey:@"data"];
                info.infoDictionary = obj;
                info.infoType = _typeForMarco;
                [self.navigationController pushViewController:info animated:YES];
            }
                break;
             default:
                break;
        }
    } else {
        if (result.message && result.message.length > 0) {
            [HMUtility showTip:result.message inView:self.view];
        }else{
            [HMUtility showTip:[NSString stringWithFormat:@"%@加载失败!", _infoStr] inView:self.view];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"hmnewscell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        if (IOS7) {
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
    }
    NSDictionary *dic = [_resultArray objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.text = [dic objectForKey:@"name"];
    /*
    if (_infoType == kInfoTypeActivity) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(230, 6, 72, 32)];
        label.text = [dic objectForKey:@"activityDate"];
        label.font = [UIFont systemFontOfSize:13.0];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:label];
    }
    */
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSDictionary *dic = [_resultArray objectAtIndex:row];
    NSInteger infoId = [[dic objectForKey:@"id"] integerValue];
    [self queryInfoDetail:infoId];
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
