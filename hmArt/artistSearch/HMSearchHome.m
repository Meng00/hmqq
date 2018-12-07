//
//  HMSearchHome.m
//  hmArt
//
//  Created by wangyong on 14-8-17.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMSearchHome.h"

@interface HMSearchHome ()

@end

@implementation HMSearchHome

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"我要搜索";
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
    self.tabBarController.tabBar.hidden=YES;
    
    _formView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _formView.layer.borderWidth = 1.0;
    _nameView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _nameView.layer.borderWidth = 1.0;
    _priceView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _priceView.layer.borderWidth = 1.0;
    _cityView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _cityView.layer.borderWidth = 1.0;
    _artistView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _artistView.layer.borderWidth = 1.0;
    _paintingView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _paintingView.layer.borderWidth = 1.0;
    
    _cityLabel.adjustsFontSizeToFitWidth = YES;
        
    //    _requestId = 0;
    _requestCityId = 0;
    
    _cityLabel.text =@"请选择出生地";


    CGRect rect = _scrollView.frame;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - HM_SYS_VIEW_OFFSET;
    _scrollView.frame = rect;
    [_scrollView setContentSize:CGSizeMake(rect.size.width, 390)];
    self.inputform = _scrollView;
    [self addInput:_nameText sequence:0 name:@"name"];

    _searchType = [NSArray arrayWithObjects:@"在售作品", @"已售作品", @"艺术名家", nil];
    _curSearchType = 0;
    _searchTypeLabel.text = [NSString stringWithFormat:@"%@  >", [_searchType objectAtIndex:_curSearchType]];
    _nameText.placeholder = @"请输入作品名称";
    _cityView.hidden = YES;
    _priceView.hidden = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSearchType:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    _searchTypeLabel.userInteractionEnabled = YES;
    [_searchTypeLabel addGestureRecognizer:tap];

    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPrice:)];
    tap1.numberOfTapsRequired = 1;
    tap1.numberOfTouchesRequired = 1;
    _priceSelectLabel.userInteractionEnabled = YES;
    [_priceSelectLabel addGestureRecognizer:tap1];

    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCity:)];
    tap2.numberOfTapsRequired = 1;
    tap2.numberOfTouchesRequired = 1;
    _citySelectLabel.userInteractionEnabled = YES;
    [_citySelectLabel addGestureRecognizer:tap2];
    
    _priceItems = [NSArray arrayWithObjects:@"不限", @"0-1000元", @"1001-5000元", @"5001-10000元", @"10001-100000元", @"10万元以上", nil];
    _curPriceIndex = 0;
  
    
    _artistRecItems = [[NSMutableArray alloc] init];
    _artWorkRecItems = [[NSMutableArray alloc] init];
    _artDataLoad = NO;
    _paintDataLoad = NO;
    [self queryArtist];
    [self queryArtWork];
    [self queryCity];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [HMUtility navBar:self.navigationController.navigationBar backImage:@"home_bg.png" backTag:HM_SYS_NAVIBARBG_TAG];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ClickTabBar:) name:@"HMArtTabBarClickedAtIndexFirst" object:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HMArtTabBarClickedAtIndexFirst" object:nil];
    [super viewWillDisappear:animated];
}

- (void)ClickTabBar:(NSNotification *)noticatication
{
    [self queryArtist];
    [self queryArtWork];
}

#pragma mark -
#pragma mark event handle
- (void)tapSearchType:(UITapGestureRecognizer *)tap
{
    LCGlobalSelector *ctrl = [[LCGlobalSelector alloc] initWithNibName:nil bundle:nil];
    ctrl.title = @"选择搜索类型";
    ctrl.selectedIndex = _curSearchType;
    ctrl.dataSource = self;
    ctrl.delegate = self;
    _curSelector = 1;
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (void)tapPrice:(UITapGestureRecognizer *)tap
{
    LCGlobalSelector *ctrl = [[LCGlobalSelector alloc] initWithNibName:nil bundle:nil];
    ctrl.title = @"选择价格区间";
    ctrl.selectedIndex = _curPriceIndex;
    ctrl.dataSource = self;
    ctrl.delegate = self;
    _curSelector = 2;
    [self.navigationController pushViewController:ctrl animated:YES];
}


- (IBAction)searchButtonDown:(id)sender {
    if (_curSearchType == 2) {
        HMArtistList *ctrl =[[HMArtistList alloc] initWithNibName:nil bundle:nil];
        ctrl.keyword = _nameText.text;
        if (_selectedProvinceRow > 0) {
            ctrl.area = _cityLabel.text;
        }
     [self.navigationController pushViewController:ctrl animated:YES];
    }else{
        HMPictureList *ctrl = [[HMPictureList alloc] initWithNibName:nil bundle:nil];
        ctrl.keyword = _nameText.text;
        ctrl.pictureType = _curSearchType+1;
        if (_curPriceIndex > 0 && _curPriceIndex < 5) {
            NSString *priceRange = [_priceItems objectAtIndex:_curPriceIndex];
            NSArray  *array= [ [priceRange substringToIndex:[priceRange length] - 1] componentsSeparatedByString:@"-"];
            ctrl.minPrice = [array objectAtIndex: 0];
            ctrl.maxPrice = [array objectAtIndex: 1];
        } else if (_curPriceIndex == 5){
            ctrl.minPrice = @"100000";
        }
        [self.navigationController pushViewController:ctrl animated:YES];
    }
    
    
}

- (void)tapArtist:(UITapGestureRecognizer *)tap
{
    NSInteger tag = [tap.view tag] - 100;
    if (tag < 0 || tag > 3) {
        return;
    }
    NSDictionary *artist = [_artistRecItems objectAtIndex:tag];
    HMArtistDetail *artistDetail = [[HMArtistDetail alloc] initWithNibName:nil bundle:nil];
    artistDetail.title = [artist objectForKey:@"name"];
    artistDetail.artistId = [[artist objectForKey:@"id"] integerValue];
    [self.navigationController pushViewController:artistDetail animated:YES];
}

- (void)tapArtwork:(UITapGestureRecognizer *)tap
{
    NSInteger tag = [tap.view tag] - 200;
    if (tag < 0 || tag > 3) {
        return;
    }
    NSDictionary *artWork = [_artWorkRecItems objectAtIndex:tag];

    HMPaintingDetail *ctrl = [[HMPaintingDetail alloc] initWithNibName:nil bundle:nil];
    ctrl.title = [artWork objectForKey:@"name"];
    ctrl.paintingId = [[artWork objectForKey:@"id"] integerValue];
    ctrl.source = 2;
    [self.navigationController pushViewController:ctrl animated:YES];
}


#pragma mark -
#pragma mark global selector
- (NSString *)titleForRow:(NSInteger)row
{
    if (_curSelector == 1) {
        return [_searchType objectAtIndex:row];
    } else if (_curSelector == 2){
        return [_priceItems objectAtIndex:row];
    }
    return @"";
}

- (NSInteger)numberOfRows
{
    if (_curSelector == 1) {
        return _searchType.count;
    } else if (_curSelector == 2){
        return _priceItems.count;
    }
    return 0;
    
}

- (void)selectorDidSelect:(NSInteger)row
{
    if (_curSelector == 1) {
        if (_curSearchType != row) {
            _curSearchType = row;
            _searchTypeLabel.text = [NSString stringWithFormat:@"%@  >", [_searchType objectAtIndex:_curSearchType]];
            if (_curSearchType == 2) {
                _nameText.placeholder = @"请输入艺术家姓名";
                _cityView.hidden = NO;
                _priceView.hidden = YES;
            }else{
                _nameText.placeholder = @"请输入艺术品名称";
                _cityView.hidden = YES;
                _priceView.hidden = NO;
            }
        }
    } else if (_curSelector == 2){
        _curPriceIndex = row;
        _priceLabel.text = [_priceItems objectAtIndex:row];
    }
    
}

#pragma mark -
#pragma mark query methods
- (void)queryArtist
{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestArtistId != 0) {
        [net cancelRequest:_requestArtistId];
    }
    
    NSMutableDictionary *queryParams = [[NSMutableDictionary alloc] initWithCapacity:3];
    [queryParams setObject:[NSNumber numberWithInteger:1] forKey:@"rec"];
    [queryParams setObject:[NSNumber numberWithInteger:4] forKey:@"pageSize"];
    [queryParams setObject:[NSNumber numberWithInteger:1] forKey:@"pageIndex"];
    
    _requestArtistId = [net asynRequest:interfaceArtistSearch with:queryParams needSSL:NO target:self action:@selector(dealArtistRecommend:withResult:)];
}

- (void)dealArtistRecommend:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    _requestArtistId = 0;
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        _artDataLoad = YES;
        NSArray *artList = [result.value objectForKey:@"obj"];
        for (int i = 0; i < artList.count; i++) {
            NSDictionary *item = [artList objectAtIndex:i];
            [_artistRecItems addObject:item];
            HMNetImageView *iv = [_artistItems objectAtIndex:i];
            iv.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [item objectForKey:@"photos"]];
            [iv load];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapArtist:)];
            tap.numberOfTapsRequired = 1;
            tap.numberOfTouchesRequired = 1;
            iv.tag = i + 100;
            iv.userInteractionEnabled = YES;
            [iv addGestureRecognizer:tap];
        }
    }else{
        _artDataLoad = NO;
    }
}

- (void)queryArtWork
{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestArtWorkId != 0) {
        [net cancelRequest:_requestArtWorkId];
    }
    
    NSMutableDictionary *queryParams = [[NSMutableDictionary alloc] initWithCapacity:3];
    [queryParams setObject:[NSNumber numberWithInteger:1] forKey:@"rec"];
    [queryParams setObject:[NSNumber numberWithInteger:4] forKey:@"pageSize"];
    [queryParams setObject:[NSNumber numberWithInteger:1] forKey:@"pageIndex"];
    
    _requestArtWorkId = [net asynRequest:interfaceArtWorkSearch with:queryParams needSSL:NO target:self action:@selector(dealArtWorkRecommend:withResult:)];
}

- (void)dealArtWorkRecommend:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    _requestArtWorkId = 0;
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        _paintDataLoad = YES;
        NSArray *artList = [result.value objectForKey:@"obj"];
        for (int i = 0; i < artList.count; i++) {
            NSDictionary *item = [artList objectAtIndex:i];
            [_artWorkRecItems addObject:item];
            HMNetImageView *iv = [_paintingItems objectAtIndex:i];
            iv.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [item objectForKey:@"image"]];
            [iv load];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapArtwork:)];
            tap.numberOfTapsRequired = 1;
            tap.numberOfTouchesRequired = 1;
            iv.tag = i + 200;
            iv.userInteractionEnabled = YES;
            [iv addGestureRecognizer:tap];
        }

    }else{
        _paintDataLoad = NO;
    }
}

#pragma mark -
#pragma mark query methods
- (void)queryCity
{
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestCityId != 0) {
        [net cancelRequest:_requestCityId];
    }
    NSMutableDictionary *queryParams = [[NSMutableDictionary alloc] initWithCapacity:1];
    [queryParams setValue:[NSNumber numberWithInteger:0] forKeyPath:@"type"];
    _requestCityId = [net asynRequest:interfaceAddr with:queryParams needSSL:NO target:self action:@selector(dealCity:result:)];
}
- (void)dealCity:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    _requestCityId = 0;
    if (result.result == HM_SYS_INTERFACE_SUCCESS) {
        NSDictionary *ret = result.value;
        _cityArray = [ret objectForKey:@"obj"];
        if (_cityArray.count > 0) {
            _selectedProvinceRow = 0;
            _selectedCityRow = 0;
            [self dealCityChange];
        }
    }else {
        [HMUtility tap2Action:[NSString stringWithFormat:@"查询错误, 重新加载"] on:self.view target:self action:@selector(queryCity)];
    }
}


- (void)dealCityChange
{
    if (_selectedProvinceRow == 0) {
        _cityLabel.text =@"不限省市";
    }else{
        NSDictionary *province = [_cityArray objectAtIndex:_selectedProvinceRow - 1];
        NSString *provinceName = [province objectForKey:@"name"];
        if (_selectedCityRow == 0) {
            _cityLabel.text = provinceName;
        }else{
            NSArray *cityList = [province objectForKey:@"citys"];
            NSString *cityName = [[cityList objectAtIndex:_selectedCityRow-1] objectForKey:@"name"];
            if ([cityName hasPrefix:provinceName]) {
                _cityLabel.text = cityName;
            }else{
                _cityLabel.text = [NSString stringWithFormat:@"%@%@", provinceName, cityName];
            }
        }
    }
}

- (void)tapCity:(UITapGestureRecognizer *)tap
{
    LCUniverseSelector *selector = [[LCUniverseSelector alloc] initWithNibName:nil bundle:nil];
    selector.dataSource = self;
    selector.delegate = self;
    selector.title = @"选择地区";
    [self.navigationController pushViewController:selector animated:YES];
}


- (NSInteger)numberOfRowsInTableView:(NSInteger)tableTag
{
    if (tableTag == 1) {
        return  _cityArray.count + 1;
    }else{
        if (_tmpProvinceRow == 0) {
            return 1;
        }
        NSDictionary *curProvince = [_cityArray objectAtIndex:_tmpProvinceRow - 1];
        NSArray *cityList = [curProvince objectForKey:@"citys"];
        return   cityList.count + 1;
    }
}

- (NSDictionary *)dictionaryForRow:(NSInteger)row withTag:(NSInteger)tag
{
    NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:1];
    NSString *name;
    if (tag == 2) {
        if (row == 0) {
            name =  @"不限地区";
        }else {
            NSDictionary *curProvince = [_cityArray objectAtIndex:_tmpProvinceRow - 1];
            NSArray *cityList = [curProvince objectForKey:@"citys"];
            NSDictionary *city = [cityList objectAtIndex:row-1];
            name = [city objectForKey:@"name"];
        }
    }else{
        if (row == 0) {
            name = @"不限省份";
        }else {
            NSDictionary *province = [_cityArray objectAtIndex:row-1];
            name =  [province objectForKey:@"name"];
        }
    }
    [item setObject:name forKey:@"name"];
    return item;
}

- (void)tableView:(UITableView *)tableView didSelectAtRow:(NSInteger)row otherTable:(UITableView *)other
{
    if (tableView.tag == 1) {
        _tmpProvinceRow = row;
        if (_tmpProvinceRow == 0) {
            [self changeProvince:0 withCity:0];
        }else{
            NSDictionary *curProvince = [_cityArray objectAtIndex:_tmpProvinceRow - 1];
            NSArray *cityList = [curProvince objectForKey:@"citys"];
            if (cityList.count > 1) {
                [other reloadData];
            }else{
                [self changeProvince:_tmpProvinceRow withCity:0];
            }
        }
    }else{
        [self changeProvince:_tmpProvinceRow withCity:row];
    }
}

- (void)changeProvince:(NSUInteger)prov withCity:(NSUInteger)city
{
    [self.navigationController popViewControllerAnimated:YES];
    _selectedProvinceRow = prov;
    _selectedCityRow = city;
    [self dealCityChange];
    
}


@end
