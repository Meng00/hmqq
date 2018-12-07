//
//  HMFindPassword.m
//  hmArt
//
//  Created by wangyong on 14-8-13.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMFindPassword.h"

@interface HMFindPassword ()

@end

@implementation HMFindPassword

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"找回密码";
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
    
    [_scrollView setContentSize:CGSizeMake(rect.size.width, 310)];
    self.inputform = _scrollView;
    [self addInput:_mobileText sequence:0 name:@"手机号码"];
    [self addInput:_smsText sequence:1 name:@"短信验证码"];
    [self addInput:_pwdText sequence:2 name:@"新密码"];
    [self addInput:_confirmText sequence:3 name:@"确认密码"];
    
    _mobileText.text = _mobileNumber;
    _canSendAuthCode=YES;
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

    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 3];
    [queryParam setValue:mobile forKey:@"mobile"];
    [queryParam setValue:[NSNumber numberWithInteger:3] forKeyPath:@"type"];
    
    _requestId = [net asynRequest:interfaceUserSendAuth with:queryParam needSSL:NO target:self action:@selector(procSendSms:result:)];
    
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    [_activity startAnimating];
    _mobileNumber=_mobileText.text;
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

- (IBAction)findButtonDown:(id)sender {
        
    NSString *mobile = _mobileText.text;
    NSString *smsCode =_smsText.text;
    NSString *newPwd = _pwdText.text;
    NSString *confirm = _confirmText.text;
    
    if ([HMTextChecker checkIsEmpty:mobile]) {
        [HMUtility alert:@"请输入手机号码!" title:@"提示"];
        return;
    }
    if (![HMTextChecker checkIsMobile:mobile]){
        [HMUtility alert:@"手机号码不正确!" title:@"提示"];
        return;
    }
    
    if ([HMTextChecker checkIsEmpty:smsCode]) {
        [HMUtility alert:@"验证码不能为空" title:@"提示"];
        return;
    }
    if ([HMTextChecker checkIsEmpty:newPwd]) {
        [HMUtility alert:@"新密码不能为空" title:@"提示"];
        return;
    }
    
    if (![newPwd isEqualToString:confirm]) {
        [HMUtility alert:@"两次密码不一致" title:@"提示"];
        return;
    }

    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 3];
    [queryParam setValue:mobile forKey:@"username"];
    [queryParam setValue:smsCode forKeyPath:@"code"];
    [queryParam setValue:newPwd forKeyPath:@"password"];
    
    _requestId = [net asynRequest:interfaceUserRePwd with:queryParam needSSL:NO target:self action:@selector(procRepwd:result:)];
    
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    [_activity startAnimating];
    
}

- (void)procRepwd:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    _requestId = 0;
    [HMUtility dismissModalView:_activity];
    if (result.result == HM_SYS_INTERFACE_SUCCESS) {
        [HMUtility alert:@"重置密码成功" title:@"提示"];
        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        _canSendAuthCode = YES;
        _stopCountDown = YES;
        if ([result.message length] > 0) {
            [HMUtility alert:result.message title:@"提示"];
        }else{
            [HMUtility alert:@"重置密码失败！" title:@"提示"];
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
