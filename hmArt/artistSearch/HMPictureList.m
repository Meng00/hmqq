//
//  HMPictureList.m
//  hmArt
//
//  Created by wangyong on 13-7-12.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import "HMPictureList.h"

@interface HMPictureList ()

@end

@implementation HMPictureList

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _groupType = 0;
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

    switch (_pictureType) {
        case kPictureTypeGallery:
        {
            _infoStr = @"在售作品";
        }
            break;
        case kPictureTypeForSale:
        {
            _infoStr = @"已售作品";
        }
            break;
        case kPictureTypeSaled:
        {
            _infoStr = @"精品展区";
        }
            break;
//        case kPictureTypeWonderful:
//        {
//            _infoStr = @"精品展区";
//        }
//            break;
       default:
        {
            _infoStr = @"作品列表";
        }
            break;
    }
    self.title = _infoStr; //[NSString stringWithFormat:@"%@列表", _infoStr];
    
    _searchParams = [[NSMutableDictionary alloc] initWithCapacity:1];
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

- (void)setParams:(NSString *)params
{
    NSDictionary *dicParam = [HMUtility parametersWithSeparator:@"=" delimiter:@"&" url:params];
    _groupType =[[dicParam objectForKey:@"groupType"] integerValue];
    NSNumber *cateId = [dicParam objectForKey:@"cateId"];
    if (cateId) {
        _categoryId = [cateId integerValue];
    }else{
        _categoryId = 0;
    }
    
    NSNumber *artId = [dicParam objectForKey:@"artistId"];
    if (artId) {
        _artistId = [artId integerValue];
    }else{
        _artistId = 0;
    }
    
    NSNumber *typeParam = [dicParam objectForKey:@"type"];
    if (typeParam) {
        _pictureType = [typeParam integerValue];
    }else{
        _pictureType = 0;
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
    if (_groupType == 1) {
        [queryParam setValue:[NSNumber numberWithInteger:_groupType] forKey:@"groupType"];
        [queryParam setValue:[NSNumber numberWithInteger:_categoryId] forKey:@"cateId"];
    }else{
        if (_keyword && _keyword.length > 0) {
            [queryParam setObject:_keyword forKey:@"keyword"];
        }
        if (_pictureType > 0) {
            [queryParam setValue:[NSNumber numberWithInteger:_pictureType] forKey:@"type"];
        }
        if (_artistId > 0) {
            [queryParam setValue:[NSNumber numberWithInteger:_artistId] forKey:@"artistId"];
        }
        if (_minPrice ) {
            [queryParam setObject:_minPrice forKey:@"minPrice"];
        }
        if (_maxPrice ) {
            [queryParam setObject:_maxPrice forKey:@"maxPrice"];
        }
    }
    _requestId = [net asynRequest:interfaceArtWorkSearch with:queryParam needSSL:NO target:self action:@selector(dealPictures:result:)];
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
    /*
    if (_dataLoaded && (_resultArray.count == 0)) {
        return [NSString stringWithFormat:@"没找到%@...", _infoStr];
    }*/
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
        label.text = @"未找到相关作品，请拨打咨询电话";
        label.font = [UIFont systemFontOfSize:14.0];
        [header addSubview:label];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(30, 46, 260, 32)];
        [btn setTitle:@"联系我们：4008-988-518" forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_bg_brown.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(callButtonDown:) forControlEvents:UIControlEventTouchUpInside];
        [header addSubview:btn];
        return header;
    }
    return nil;
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *dic = [_resultArray objectAtIndex:indexPath.row];
    NSInteger pictureType = [[dic objectForKey:@"type"] integerValue];
    if (_groupType == 1) {
        cell.nameLabel.text = [NSString stringWithFormat:@"作    者:%@", [dic objectForKey:@"artist"]];
        cell.sizeLabel.text = [NSString stringWithFormat:@"名    称:%@", [dic objectForKey:@"name"]];
        cell.timeLabel.text = [NSString stringWithFormat:@"尺    寸:%@", [dic objectForKey:@"size"]];
        cell.categoryLabel.text = [NSString stringWithFormat:@"创作时间:%@", [dic objectForKey:@"createDate"]];
        
        NSString *price = [HMUtility getPrice:[dic objectForKey:@"price"] pictureType:_pictureType];
        if (price.length > 0 ) {
            cell.priceLabel.hidden = NO;
            if (pictureType == 2) {
                cell.categoryLabel.text = [NSString stringWithFormat:@"售出价格:%@", price];
            }else {
                cell.categoryLabel.text = [NSString stringWithFormat:@"价    格:%@", price];
            }
        }else{
            cell.priceLabel.hidden = YES;
        }
        cell.picImage.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [dic objectForKey:@"image"]];
        [cell.picImage load];
    }else{
        cell.nameLabel.text = [NSString stringWithFormat:@"名    称:%@", [dic objectForKey:@"name"]];
        cell.sizeLabel.text = [NSString stringWithFormat:@"尺    寸:%@", [dic objectForKey:@"size"]];
        NSString *price = [HMUtility getPrice:[dic objectForKey:@"price"] pictureType:_pictureType];
        if (price.length > 0 ) {
            cell.categoryLabel.hidden = NO;
            if (pictureType == 2) {
                cell.categoryLabel.text = [NSString stringWithFormat:@"售出价格:%@", price];
            }else {
                cell.categoryLabel.text = [NSString stringWithFormat:@"价    格:%@", price];
            }
        }else{
            cell.categoryLabel.hidden = YES;
        }
        cell.priceLabel.hidden = YES;
        cell.timeLabel.text = [NSString stringWithFormat:@"创作时间:%@", [dic objectForKey:@"createDate"]];
        cell.picImage.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [dic objectForKey:@"image"]];
        [cell.picImage load];
    }
    
      return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [_resultArray objectAtIndex:indexPath.row];
    HMPaintingDetail *ctrl = [[HMPaintingDetail alloc] initWithNibName:nil bundle:nil];
    ctrl.title = [dic objectForKey:@"name"];
    ctrl.paintingId = [[dic objectForKey:@"id"] integerValue];
    ctrl.source = 1;
    if (_pictureType) {
        if (_pictureType == 1 || _pictureType == 2| _pictureType == 3) {
            ctrl.source = 2;
        }
    }
    [self.navigationController pushViewController:ctrl animated:YES];
    
//    HMPicture *info = [[HMPicture alloc] initWithNibName:nil bundle:nil];
//    info.pictureType = _pictureType;
//    info.picId = [[dic objectForKey:@"id"] integerValue];
//    [self.navigationController pushViewController:info animated:YES];
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

- (void)callButtonDown:(id)sender {
    NSString *name = [NSString stringWithFormat:@"致电我们-%@ ？", HM_SYS_CUSTOM_SERVICE_PHONE];
    LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:name phone:HM_SYS_CUSTOM_SERVICE_PHONE type:0 name:@"更多服务" cancelButtonTitle:@"取消" okButtonTitle:@"确定"];
    [actionSheet showPhonecall:self.tabBarController.tabBar];
    
}

@end
