//
//  HMLoginEx.m
//  hmArt
//
//  Created by wangyong on 14-8-13.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMLoginEx.h"

@interface HMLoginEx ()

@end

@implementation HMLoginEx

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"登录";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"view_bg.png"]];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    
//    _formView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    _formView.layer.borderWidth = 1.0;

    _registView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _registView.layer.borderWidth = 0.3;

//    _adImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    _adImageView.layer.borderWidth = 1.0;
    
    CGRect rect = _scrollView.frame;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - HM_SYS_VIEW_OFFSET;
    _scrollView.frame = rect;
    
    [_scrollView setContentSize:CGSizeMake(rect.size.width, 340)];
    self.inputform = _scrollView;
    [self addInput:_mobileText sequence:0 name:@"手机号码"];
    [self addInput:_pwdText sequence:1 name:@"密码"];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRegist:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    _registView.userInteractionEnabled = YES;
    [_registView addGestureRecognizer:tap];
    
    self.navigationItem.hidesBackButton = _hideBackButton;

    [self queryAds];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [HMUtility navBar:self.navigationController.navigationBar backImage:@"home_bg.png" backTag:HM_SYS_NAVIBARBG_TAG];
    self.navigationController.navigationBarHidden = NO;
    if (![HMGlobalParams sharedInstance].anonymous) {
        [self.navigationController popViewControllerAnimated:NO];
    }
    
}

#pragma mark -
#pragma mark event handler
- (IBAction)loginButtonDown:(id)sender {
    NSString *mobile=_mobileText.text;
    _pass =_pwdText.text;
    if ([HMTextChecker checkIsEmpty:mobile]) {
        [HMUtility alert:@"请输入手机号码!" title:@"提示"];
        return;
    }
    if (![HMTextChecker checkIsMobile:mobile]){
        [HMUtility alert:@"手机号码不正确!" title:@"提示"];
        return;
    }
    if ([HMTextChecker checkIsEmpty:_pass]){
        [HMUtility alert:@"请输入登录密码" title:@"提示"];
        return;
    }
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 4];
    [queryParam setValue:mobile forKey:@"username"];
    [queryParam setValue:_pass forKeyPath:@"password"];
    [queryParam setValue:[NSNumber numberWithInteger:0] forKey:@"type"];
     HMGlobalParams *params = [HMGlobalParams sharedInstance];
    [queryParam setValue:params.serialNumber forKey:@"deviceId"];
    if (params.deviceToken4Push) {
        [queryParam setValue:params.deviceToken4Push forKey:@"deviceToken"];
    }
    
    _requestId = [net asynRequest:interfaceUserLogin with:queryParam needSSL:NO target:self action:@selector(procLogin:result:)];
    
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    [_activity startAnimating];
    
    
}
- (void)procLogin:(NSString *)serviceName result:(LCInterfaceResult *)result{
    [_activity stopAnimating];
    _requestId=0;
    [HMUtility dismissModalView:_activity];
    if (result.result==HM_SYS_INTERFACE_SUCCESS) {
        NSDictionary *ret = [result.value objectForKey:@"obj"];
        HMGlobalParams *params = [HMGlobalParams sharedInstance];
        params.anonymous = NO;
        params.password = _pass;
        params.uid = [[ret objectForKey:@"id"] integerValue];//后台 没有返回id
        params.mobile = [ret objectForKey:@"mobile"];
        params.loginToken = [ret objectForKey:@"loginToken"];
        params.name = [HMUtility getString:[ret objectForKey:@"name"]];
        params.sex = [[ret objectForKey:@"sex"] integerValue];
        params.vip = [[ret objectForKey:@"vip"] integerValue];

        //数据存到手机上
        [HMUtility writeUserInfo];
        
        if (self.delegate) {
            [self.delegate loginResult:YES func:self.func];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
               
    }else{
        [HMUtility alert:result.message  title:@"提示"];
        
    }
        
        
}


- (IBAction)forgetButtonDown:(id)sender {
    HMFindPassword *ctrl = [[HMFindPassword alloc] initWithNibName:nil bundle:nil];
    ctrl.mobileNumber = _mobileText.text;
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (void)tapRegist:(UITapGestureRecognizer *)tap
{
    HMRegistEx *ctrl = [[HMRegistEx alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:ctrl animated:YES];
}
#pragma mark -
#pragma mark query ads
- (void)queryAds
{
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestAdId != 0) {
        [net cancelRequest:_requestAdId];
    }
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity:1];
    [queryParam setValue:kAD_POS_CODE_LOGIN forKey:@"adPos"];
    
    _requestAdId = [net asynRequest:interfaceAds with:queryParam needSSL:NO target:self action:@selector(dealAds:withResult:)];
}

- (void)dealAds:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    _requestAdId = 0;
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSLog(@"%@", result.value);
        NSArray *adList = [result.value objectForKey:@"obj"];
        for (NSDictionary *ad in adList) {
            [_adImageView addItem:ad];
        }
        [_adImageView startSwitch];
    }
}

@end
