//
//  HMRegistEx.m
//  hmArt
//
//  Created by wangyong on 14-8-13.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMRegistEx.h"

@interface HMRegistEx ()


@end

@implementation HMRegistEx

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"注册";
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
    
//    _formView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    _formView.layer.borderWidth = 1.0;
    
    CGRect rect = _scrollView.frame;
//    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - HM_SYS_VIEW_OFFSET;
//    _scrollView.frame = rect;
    
    [_scrollView setContentSize:CGSizeMake(rect.size.width, 200)];
    self.inputform = _scrollView;
    [self addInput:_mobileText sequence:0 name:@"手机号码"];
    [self addInput:_pwdText sequence:1 name:@"密码"];
    [self addInput:_proxyCodeText sequence:2 name:@"区域代码"];
    
    _canSendAuthCode = YES;
    _stopCountDown = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
    if (_requestId != 0) {
        [[LCNetworkInterface sharedInstance] cancelRequest:_requestId];
    }
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark event handler
- (IBAction)registButtonDown:(id)sender {
    NSString *mobile=_mobileText.text;
    NSString *pwd=_pwdText.text;
    NSString *proxycode = _proxyCodeText.text;
    if ([HMTextChecker checkIsEmpty:mobile]) {
        [HMUtility alert:@"请输入手机号码!" title:@"提示"];
        return;
    }
    if (![HMTextChecker checkIsMobile:mobile]){
        [HMUtility alert:@"手机号码不正确!" title:@"提示"];
        return;
    }
    if ([HMTextChecker checkIsEmpty:pwd]){
        [HMUtility alert:@"请输入手机密码" title:@"提示"];
        return;
    }
    if (proxycode.length!=4 ||![HMTextChecker checkIsNumber:proxycode]) {
        [HMUtility alert:@"请输入正确的区域代码（4位数字）" title:@"提示"];
        return;
    }
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }

    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 3];
    [queryParam setValue:mobile forKey:@"mobile"];
    [queryParam setValue:pwd forKeyPath:@"password"];
    [queryParam setValue:proxycode forKeyPath:@"proxyCode"];
    _pass = pwd;
    _mobile = mobile;
    _proCodes = proxycode;
    [queryParam setValue:[NSNumber numberWithInteger:0] forKey:@"type"];
    HMGlobalParams *params = [HMGlobalParams sharedInstance];
    [queryParam setValue:params.serialNumber forKey:@"deviceId"];
    if (params.deviceToken4Push) {
        [queryParam setValue:params.deviceToken4Push forKey:@"deviceToken"];
    }

    _requestId = [net asynRequest:interfaceUserRegist with:queryParam needSSL:NO target:self action:@selector(procRegister:result:)];
    
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    [_activity startAnimating];
    
    
}

- (void)procRegister:(NSString *)serviceName result:(LCInterfaceResult *)result{
    [_activity stopAnimating];
    _requestId=0;
    [HMUtility dismissModalView:_activity];
    if (result.result == HM_SYS_INTERFACE_SUCCESS) {
        [HMUtility alert:result.message title:@"提示"];
        HMGlobalParams *params = [HMGlobalParams sharedInstance];
        params.anonymous = NO;
        params.password = _pass;
        params.mobile = _mobile;
        params.vip = 0;
        //数据存到手机上
//        [HMUtility writeUserInfo];
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        if ([result.message length] > 0) {
            [HMUtility alert:result.message title:@"提示"];
        }else{
            [HMUtility alert:@"注册失败！" title:@"提示"];
        }
        _stopCountDown = YES;
    }



}


- (IBAction)smsButtonDown:(id)sender {
    if (!_canSendAuthCode) {
        [HMUtility alert:@"发送间隔1分钟!" title:@"提示"];
        return;
    }
    NSString *mobile=_mobileText.text;
    if ([HMTextChecker checkIsEmpty:mobile]) {
        [HMUtility alert:@"请输入手机号码!" title:@"提示"];
        return;
    }
    if (![HMTextChecker checkIsMobile:mobile]){
        [HMUtility alert:@"手机号码不正确!" title:@"提示"];
        return;
    }
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    _authSerial = @"";
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 3];
    [queryParam setValue:mobile forKey:@"mobile"];
    [queryParam setValue:[NSNumber numberWithInteger:1] forKeyPath:@"type"];
    
    _requestId = [net asynRequest:interfaceUserSendAuth with:queryParam needSSL:NO target:self action:@selector(procSendSms:result:)];
    
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    [_activity startAnimating];
    _canSendAuthCode = NO;

}

- (void)procSendSms:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    _requestId = 0;
    [HMUtility dismissModalView:_activity];
    if (result.result == HM_SYS_INTERFACE_SUCCESS) {
        [HMUtility alert:@"手机密码已发送到您的手机请注意查收" title:@"提示"];
        _sentDate = [NSDate date];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(resetSendSms) userInfo:nil repeats:YES];
        _canSendAuthCode = NO;
        
    }else{
        _canSendAuthCode = YES;
        [HMUtility showTip:result.message inView:self.view];
    }
}


- (void)resetSendSms
{
    NSDate *curDate = [NSDate date];
    int tPast = [[NSString stringWithFormat:@"%f", [curDate timeIntervalSinceDate:_sentDate]] intValue];
    int tShow = 60-tPast;

    if (_stopCountDown || tShow <= 0)  {
        _canSendAuthCode = YES;
        [_smsButton setTitle:@"获取短信密码" forState:UIControlStateNormal];
        if ([_timer isValid]) {
            [_timer invalidate];
            _timer = nil;
        }
    }else{
        [_smsButton setTitle:[NSString stringWithFormat:@"剩余(%d)", tShow] forState:UIControlStateNormal];
        _canSendAuthCode =NO;
    }
}

@end
