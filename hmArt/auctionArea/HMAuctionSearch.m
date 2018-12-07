//
//  HMAuctionSearch.m
//  hmArt
//
//  Created by wangyong on 14-8-15.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMAuctionSearch.h"

@interface HMAuctionSearch ()

@end

@implementation HMAuctionSearch


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
    
    _formView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _formView.layer.borderWidth = 1.0;

    _fromDateView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _fromDateView.layer.borderWidth = 1.0;
    _toDateView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _toDateView.layer.borderWidth = 1.0;
    _cityView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _cityView.layer.borderWidth = 1.0;

    
     _cityLabel.adjustsFontSizeToFitWidth = YES;
        
    _requestCityId = 0;
    
    CGRect rect = _scrollView.frame;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - HM_SYS_VIEW_OFFSET;
    _scrollView.frame = rect;
    
    [_scrollView setContentSize:CGSizeMake(rect.size.width, 320)];
    self.inputform = _scrollView;
    [self addInput:_paintingNameText sequence:0 name:@"作品名称"];
    [self addInput:_authorNameText sequence:1 name:@"作者姓名"];
    [self addInput:_areaNameText sequence:2 name:@"竞买号"];
    
    _selectedCity = @"";
    _fromDate = nil;
    _toDate = nil;
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCity:)];
    tap2.numberOfTapsRequired = 1;
    tap2.numberOfTouchesRequired = 1;
    _citySelectLabel.userInteractionEnabled = YES;
    [_citySelectLabel addGestureRecognizer:tap2];
    [self queryCity];
    _cityLabel.text =@"不限省市";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    
}
- (void)dealCity:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    _requestCityId = 0;
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
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
        _selectedCity = _cityLabel.text;
   }
}
//
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

#pragma mark -
#pragma mark pickView
- (IBAction)toSearch:(id)sender {
    
    if (_delegate) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:1];
        NSString *authorName = _authorNameText.text;
        if (authorName.length > 0) {
            [params setObject:authorName forKey:@"artist"];
        }
        NSString *artName = _paintingNameText.text;
        if (artName.length > 0) {
            [params setObject:artName forKey:@"artName"];
        }
        NSString *codeName = _areaNameText.text;
        if (codeName.length > 0) {
            [params setObject:codeName forKey:@"code"];
        }
        if (_selectedProvinceRow > 0) {
            [params setObject:_selectedCity forKey:@"area"];
        }
        if (_fromDate) {
            [params setObject:_fromDateLabel.text forKey:@"startTime"];
        }
        if (_toDate) {
            [params setObject:_toDateLabel.text forKey:@"endTime"];
        }
        [params setObject:[NSNumber numberWithInteger:2] forKey:@"type"];
        [_delegate auctionsDidSearch:params];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (IBAction)showDateView:(id)sender{
    _currentDateTag  = [sender tag];

    NSDate *minD;
    NSDate *currD;
    NSDate *now = [NSDate date];
    if (_currentDateTag ==12 ) {
        minD = [NSDate dateWithTimeIntervalSinceNow:-1*60*60*24*30*12];
        
        if (_fromDate) {
            currD = _fromDate;
        }else{
            currD = now;
        }
    }else if (_currentDateTag == 13){
        if (_fromDate) {
            minD = _fromDate;
        }else{
            minD = [NSDate dateWithTimeIntervalSinceNow:-1*60*60*24*30*12];
        }
        if (_toDate) {
            currD = _toDate;
        }else{
            currD = now;
        }
    }
    [HMUtility showCalendarInView:self.view target:self currDate:currD minimumDate:minD maximumDate:now hideYear:YES];

}

- (void)calendarViewDidSelectDay:(ITTCalendarView *)calendarView calDay:(ITTCalDay *)calDay
{
    if (_currentDateTag == 12) {
        _fromDate = calendarView.selectedDate;
        _fromDateLabel.text = [HMUtility stringFromDate:_fromDate withFormat:@"yyyy-MM-dd" timeZone:nil];
        if (_fromDate && _toDate) {
            if ([[_fromDate laterDate:_toDate] isEqual:_fromDate]) {
                _toDate =  _fromDate;
                _toDateLabel.text = [HMUtility stringFromDate:_toDate withFormat:@"yyyy-MM-dd" timeZone:nil];
            }
        }
    }else{
        NSDate *tmp = calendarView.selectedDate;
        if (_fromDate) {
            NSComparisonResult cm = [tmp compare:_fromDate];
            if (cm == NSOrderedAscending) {
                [HMUtility showTip:@"截至日期不能早于开始日期!" inView:self.view];
                return;
            }
        }
        _toDate = tmp;
        _toDateLabel.text = [HMUtility stringFromDate:_toDate withFormat:@"yyyy-MM-dd" timeZone:nil];
        
    }
}
@end
