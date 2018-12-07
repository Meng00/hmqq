//
//  HMUserInfo.m
//  hmArt
//
//  Created by wangyong on 14-8-13.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMUserInfo.h"

@interface HMUserInfo ()

@end

@implementation HMUserInfo

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"修改信息";
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
 
    
    _changeMobileView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _changeMobileView.layer.borderWidth = 1.0;
    
    _changePwdView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _changePwdView.layer.borderWidth = 1.0;

    CGRect rect = _scrollView.frame;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - HM_SYS_VIEW_OFFSET;
    _scrollView.frame = rect;
    
    _cityLabel.adjustsFontSizeToFitWidth = YES;
    
    
    _birthDate = nil;
    
//    _requestId = 0;
    _requestCityId = 0;
    _requesUserInfotId=0;
    _selectedCityRow = 0;
    _selectedProvinceRow = 0;
    _tmpProvinceRow = 0;
    
    [_scrollView setContentSize:CGSizeMake(rect.size.width, 390)];
    self.inputform = _scrollView;
    [self addInput:_nameText sequence:0 name:@"姓名"];
    [self addInput:_genderSwitch sequence:1 name:@"性别"];
//    [self addInput:_birthText sequence:2 name:@"生日"];
    [self addInput:_workText sequence:2 name:@"职业"];
    [self addInput:_addressText sequence:3 name:@"地址"];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMobile:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    _changeMobileView.userInteractionEnabled = YES;
    [_changeMobileView addGestureRecognizer:tap];

    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPassword:)];
    tap1.numberOfTapsRequired = 1;
    tap1.numberOfTouchesRequired = 1;
    _changePwdView.userInteractionEnabled = YES;
    [_changePwdView addGestureRecognizer:tap1];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCity:)];
    tap2.numberOfTapsRequired = 1;
    tap2.numberOfTouchesRequired = 1;
    _cityLabel.userInteractionEnabled = YES;
    [_cityLabel addGestureRecognizer:tap2];
    UITapGestureRecognizer *tap22 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCity:)];
    tap22.numberOfTapsRequired = 1;
    tap22.numberOfTouchesRequired = 1;
    _cityArrow.userInteractionEnabled = YES;
    [_cityArrow addGestureRecognizer:tap22];

    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBirth:)];
    tap3.numberOfTapsRequired = 1;
    tap3.numberOfTouchesRequired = 1;
    _birthLabel.userInteractionEnabled = YES;
    [_birthLabel addGestureRecognizer:tap3];
    UITapGestureRecognizer *tap33 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBirth:)];
    tap33.numberOfTapsRequired = 1;
    tap33.numberOfTouchesRequired = 1;
    _birthArrow.userInteractionEnabled = YES;
    [_birthArrow addGestureRecognizer:tap33];

    params =[HMGlobalParams sharedInstance];
    _genderSwitch.onText = @"男";
    _genderSwitch.offText = @"女";
    _genderSwitch.on = YES;
    _genderSwitch.onTintColor = [UIColor orangeColor];
    _genderSwitch.offTintColor = [UIColor orangeColor];
    //获取登录信息 回显用户信息
    [self queryUserInfo];
    //加载省市
    [self queryCity];
    
    
}
- (void)viewDidAppear:(BOOL)animated
{
     [super viewDidAppear:animated];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark event handler
- (void)tapMobile:(UITapGestureRecognizer *)tap
{
    HMChgMobile *ctrl = [[HMChgMobile alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (void)tapPassword:(UITapGestureRecognizer *)tap
{
    HMChgPass *ctrl = [[HMChgPass alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (void)tapBirth:(UITapGestureRecognizer *)tap
{

    NSDate *minD = [HMUtility dateFrom:@"1900-01-01" withFormat:@"yyyy-MM-dd" timeZone:nil];
    NSDate *currD;
    NSDate *now = [NSDate date];
    if (_birthDate) {
        currD = _birthDate;
    }else {
        currD = now;
    }

    [HMUtility showCalendarInView:self.view target:self currDate:currD minimumDate:minD maximumDate:now hideYear:NO];

}


- (void)calendarViewDidSelectDay:(ITTCalendarView *)calendarView calDay:(ITTCalDay *)calDay
{
    _birthDate = calendarView.selectedDate;
    _birthLabel.text = [HMUtility stringFromDate:_birthDate withFormat:@"yyyy-MM-dd" timeZone:nil];

}

- (IBAction)buttonClick:(id)sender {
    NSString *realName = _nameText.text;
    NSString *email = @" ";
    NSInteger sex;
    if([_genderSwitch isOn]){//如果开关状态为ON
        sex = 0;//男
    }else{
        sex = 1;
    }
//    NSString *birthday = _birthLabel.text;
    NSString *job = _workText.text;
   
    HMGlobalParams *gParams = [HMGlobalParams sharedInstance];
    NSString *addr = _addressText.text;
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 3];
    [queryParam setValue:gParams.mobile forKey:@"username"];
    [queryParam setValue:email forKey:@"email"];
    [queryParam setValue:[NSNumber numberWithInteger:sex] forKey:@"sex"];
    [queryParam setValue:realName forKey:@"realName"];
    if (_birthDate) {
        [queryParam setValue:_birthLabel.text forKey:@"birthday"];
    }
    [queryParam setValue:job forKey:@"job"];
    [queryParam setValue:_province forKey:@"province"];
    [queryParam setValue:_city forKey:@"city"];
    [queryParam setValue:addr forKey:@"addr"];
    
    _requestId = [net asynRequest:interfaceUserUpdateInfo with:queryParam needSSL:NO target:self action:@selector(procUpInfo:result:)];
    
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    [_activity startAnimating];
    
}

-(void)procUpInfo:(NSString *) serviceName result:(LCInterfaceResult *) result
{
    [_activity stopAnimating];
    _requestId =0;
    [HMUtility dismissModalView:_activity];
    if (result.result == HM_SYS_INTERFACE_SUCCESS) {
        [HMUtility alert:@"信息修改成功" title:@"提示"];

        params.anonymous = NO;
        NSInteger sex;
        if([_genderSwitch isOn]){//如果开关状态为ON
            sex = 0;//男
        }else{
            sex = 1;
        }
         params.name = _nameText.text;
         params.sex = sex;
         params.addr = _addressText.text;
         params.city = _cityLabel.text;
         params.job = _workText.text;
         params.birth = _birthLabel.text;
        
        //数据存到手机上
        [HMUtility writeUserInfo];
        [self.navigationController popViewControllerAnimated:YES];

                
    }else{
        [HMUtility showTip:result.message inView:self.view];
        [HMUtility alert:result.message title:@"提示"];
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
    [_activity startAnimating];
    
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
            _selectedCityRow = 0;
            _selectedProvinceRow = 0;
//            [self dealCityChange];
        }
    }else {
        [HMUtility tap2Action:[NSString stringWithFormat:@"查询错误, 重新加载"] on:self.view target:self action:@selector(queryCity)];
    }
}

- (void)queryUserInfo
{
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requesUserInfotId != 0) {
        [net cancelRequest:_requesUserInfotId];
    }
    NSMutableDictionary *queryParams = [[NSMutableDictionary alloc] initWithCapacity:1];
    [queryParams setValue:params.mobile forKeyPath:@"username"];
    _requesUserInfotId = [net asynRequest:interfaceUserGetInfo with:queryParams needSSL:NO target:self action:@selector(queryShow:result:)];
    [_activity startAnimating];
    
}
- (void)queryShow:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    _requesUserInfotId = 0;
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    if (result.result == HM_SYS_INTERFACE_SUCCESS) {
        NSDictionary *ret = result.value;
        NSDictionary *userInfo = [ret objectForKey:@"obj"];
        _nameText.text = params.name;
        BOOL sex = ![[userInfo objectForKey:@"sex"] boolValue];
        [_genderSwitch setOn:sex];
        NSString *birth = [HMUtility getString:[userInfo objectForKey:@"birthday"]];
        if ((birth.length == 0)) {
            _birthLabel.text =  @"请选择生日";
            _birthDate = nil;
        }else{
            _birthLabel.text =  birth;
            _birthDate = [HMUtility dateFrom:birth withFormat:@"yyyy-MM-dd" timeZone:nil];
        }
        
        _workText.text = [userInfo objectForKey:@"job"];
        _addressText.text = [userInfo objectForKey:@"addr"];
        _province = [userInfo objectForKey:@"province"];
        _city = [userInfo objectForKey:@"city"];
    if (![HMTextChecker checkIsEmpty:[userInfo objectForKey:@"city"]] && ![HMTextChecker checkIsEmpty:[userInfo objectForKey:@"province"]]) {
            if ([[userInfo objectForKey:@"city"] hasPrefix:[userInfo objectForKey:@"province"]]) {
                _cityLabel.text = [userInfo objectForKey:@"city"];
            }else{
                _cityLabel.text =[NSString stringWithFormat:@"%@%@", [userInfo objectForKey:@"province"], [userInfo objectForKey:@"city"]];
            }
     }else{
          _cityLabel.text = @"请选择省市";
     }
      
        
    }
}

- (void)dealCityChange
{
    NSDictionary *province = [_cityArray objectAtIndex:_selectedProvinceRow];
    _province = [province objectForKey:@"name"];
    NSArray *cityList = [province objectForKey:@"citys"];
    if (cityList.count == 0) {
        _city = _province;
    }else{
        _city = [[cityList objectAtIndex:_selectedCityRow] objectForKey:@"name"];
    }
    if ([_city hasPrefix:_province]) {
        _cityLabel.text = _city;
    }else{
        _cityLabel.text = [NSString stringWithFormat:@"%@%@", _province, _city];
    }
//    _cityId = [[[cityList objectAtIndex:_selCityIndex] objectForKey:@"id" ] integerValue];
//    _cityName = cityName;
    
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
        return  _cityArray.count;
    }else{
        NSDictionary *curProvince = [_cityArray objectAtIndex:_tmpProvinceRow ];
        NSArray *cityList = [curProvince objectForKey:@"citys"];
        return   cityList.count;
    }
}

- (NSDictionary *)dictionaryForRow:(NSInteger)row withTag:(NSInteger)tag
{
    NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:1];
    NSString *name;
    if (tag == 2) {
        NSDictionary *curProvince = [_cityArray objectAtIndex:_tmpProvinceRow];
        NSArray *cityList = [curProvince objectForKey:@"citys"];
        NSDictionary *city = [cityList objectAtIndex:row];
        name = [city objectForKey:@"name"];
    }else{
        NSDictionary *province = [_cityArray objectAtIndex:row];
        name =  [province objectForKey:@"name"];
    }
    [item setObject:name forKey:@"name"];
    return item;
}

- (void)tableView:(UITableView *)tableView didSelectAtRow:(NSInteger)row otherTable:(UITableView *)other
{
    if (tableView.tag == 1) {
        _tmpProvinceRow = row;
        NSDictionary *curProvince = [_cityArray objectAtIndex:_tmpProvinceRow];
        NSArray *cityList = [curProvince objectForKey:@"citys"];
        if (cityList.count > 0) {
            [other reloadData];
        }else{
            [self changeProvince:_tmpProvinceRow withCity:0];
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
