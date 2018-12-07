//
//  HMChgMobile.m
//  hmArt
//
//  Created by wangyong on 14-8-13.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMChgMobile.h"

@interface HMChgMobile ()

@end

@implementation HMChgMobile

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"会员中心";
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
    
    CGRect rect = _scrollView.frame;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - HM_SYS_VIEW_OFFSET;
    _scrollView.frame = rect;
    
    [_scrollView setContentSize:CGSizeMake(rect.size.width, 240)];
    self.inputform = _scrollView;
    [self addInput:_pwdText sequence:0 name:@"登录密码"];
    [self addInput:_mobileText sequence:1 name:@"手机号码"];
    [self addInput:_verifyCodeText sequence:2 name:@"短信验证码"];
    
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
- (IBAction)buttonClick:(id)sender {
    
    HMGlobalParams *params = [HMGlobalParams sharedInstance];
    if (params.anonymous) {
        [HMUtility alert:@"对不起,您还没有登录！" title:@"提示"];
        return;
    }
    NSString *userName = params.mobile;
    _newMobile = _mobileText.text;
    NSString *pwd = _pwdText.text;
    NSString *verifyCode = _verifyCodeText.text;
    if ([HMTextChecker checkIsEmpty:pwd]) {
        [HMUtility alert:@"密码不能为空!" title:@"提示"];
        return;
    }
    if ([HMTextChecker checkIsEmpty:_newMobile]) {
        [HMUtility alert:@"请输入手机号码!" title:@"提示"];
        return;
    }
    if (![HMTextChecker checkIsMobile:_newMobile]){
        [HMUtility alert:@"手机号码不正确!" title:@"提示"];
        return;
    }
    if ([HMTextChecker checkIsEmpty:verifyCode]) {
        [HMUtility alert:@"验证码不能为空!" title:@"提示"];
        return;
    }
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 3];
    [queryParam setValue:_newMobile forKey:@"newMobile"];
    [queryParam setValue:userName forKey:@"username"];
    [queryParam setValue:pwd forKeyPath:@"password"];
    [queryParam setValue:verifyCode forKeyPath:@"code"];
    
    _requestId = [net asynRequest:interfaceUserUpdateMobile with:queryParam needSSL:NO target:self action:@selector(procUpMob:result:)];
    
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    [_activity startAnimating];

    
    
}

-(void)procUpMob:(NSString *) serviceName result: (LCInterfaceResult *) result
{
    [_activity stopAnimating];
    _requestId = 0;
    [HMUtility dismissModalView:_activity];
    if (result.result == HM_SYS_INTERFACE_SUCCESS) {
        HMGlobalParams *gParams = [HMGlobalParams sharedInstance];
        gParams.mobile = _newMobile;
        gParams.anonymous = YES;
        [HMUtility writeUserInfo];
        [HMUtility alert:@"您已成功修改手机号码,请重新登录" title:@"提示"];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }else{
        _canSendAuthCode = YES;
        _stopCountDown = YES;
        if ([result.message length] > 0) {
            [HMUtility alert:result.message title:@"提示"];
        }else{
            [HMUtility alert:@"手机号修改失败！" title:@"提示"];
        }
    }

}
 - (IBAction)resetSendSms:(id)sender {
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
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 3];
    [queryParam setValue:mobile forKey:@"mobile"];
    [queryParam setValue:[NSNumber numberWithInteger:4] forKeyPath:@"type"];
    
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
        NSLog(@"%@", result.value);
        [HMUtility alert:@"手机密码已发送到您的手机请注意查收" title:@"提示"];
        
        _sentDate = [NSDate date];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(resetSendSms) userInfo:nil repeats:YES];
        _canSendAuthCode = NO;
    }else{
        _canSendAuthCode = YES;
        if ([result.message length] > 0) {
            [HMUtility alert:result.message title:@"提示"];
        }else{
            [HMUtility alert:@"验证码发送失败！" title:@"提示"];
        }
    }
}

- (void)resetSendSms
{
    NSDate *curDate = [NSDate date];
    int tPast = [[NSString stringWithFormat:@"%f", [curDate timeIntervalSinceDate:_sentDate]] intValue];
    int tShow = 60-tPast;
    
    if (_stopCountDown || tShow <= 0)  {
        _canSendAuthCode = YES;
        [_smsButton setTitle:@"短信验证码" forState:UIControlStateNormal];
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
