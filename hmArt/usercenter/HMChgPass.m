//
//  HMChgPass.m
//  hmArt
//
//  Created by wangyong on 14-8-13.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.  
//

#import "HMChgPass.h"

@interface HMChgPass ()

@end

@implementation HMChgPass

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"修改密码";
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
    [HMUtility navBar:self.navigationController.navigationBar backImage:@"home_bg.png" backTag:HM_SYS_NAVIBARBG_TAG];
    self.tabBarController.tabBar.hidden=YES;
    
    _formView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _formView.layer.borderWidth = 1.0;
    
    CGRect rect = _scrollView.frame;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - HM_SYS_VIEW_OFFSET;
    _scrollView.frame = rect;
    
    [_scrollView setContentSize:CGSizeMake(rect.size.width, 240)];
    self.inputform = _scrollView;
    [self addInput:_oldPwdText sequence:0 name:@"旧密码"];
    [self addInput:_pwdText sequence:1 name:@"新密码"];
    [self addInput:_confirmPwd sequence:2 name:@"确认密码"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ButtonClick:(id)sender {
    
    HMGlobalParams *params = [HMGlobalParams sharedInstance];
    if (!params) {
        [HMUtility alert:@"对不起您还没有登录！" title:@"提示"];
        //登录后  跳到修改密码的页面 待实现
        return;
    }
    NSString *userName = params.mobile;
    NSString *oldpwd=_oldPwdText.text;
    NSString *pwd=_pwdText.text;
    NSString *confirmPwd=_confirmPwd.text;
   
    if ([HMTextChecker checkIsEmpty:oldpwd]) {
        [HMUtility alert:@"旧密码不能为空!" title:@"提示"];
        return;
    }
    if ([HMTextChecker checkIsEmpty:pwd]){
        [HMUtility alert:@"新密码不能为空" title:@"提示"];
        return;
    }
    if ([HMTextChecker checkIsEmpty:confirmPwd]){
        [HMUtility alert:@"确认密码不能为空" title:@"提示"];
        return;
    }
    if ([oldpwd isEqualToString:pwd]) {
        [HMUtility alert:@"新密码不能与旧密码相同!" title:@"提示"];
        return;
    }
    if (![pwd isEqualToString:confirmPwd]) {
        [HMUtility alert:@"两次密码不一致！" title:@"提示"];
        return;
    }
    
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 4];
    [queryParam setValue:userName forKey:@"username"];
    [queryParam setValue:oldpwd forKeyPath:@"password"];
    [queryParam setValue:pwd forKeyPath:@"newPwd"];
 
    _requestId = [net asynRequest:interfaceUserUpdatePwd with:queryParam needSSL:NO target:self action:@selector(procUpPwd:result:)];
    
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    [_activity startAnimating];
    
}

-(void) procUpPwd: (NSString *) serviceName result:(LCInterfaceResult *) result{
    
    [_activity stopAnimating];
    _requestId=0;
    [HMUtility dismissModalView: _activity];
    if(result.result == HM_SYS_INTERFACE_SUCCESS){
        [HMUtility alert:@"您已成功修改密码,请重新登录" title:@"提示"];
        //保存方便下次登录
        HMGlobalParams *gParams = [HMGlobalParams sharedInstance];
        gParams.anonymous = YES;
        [self.navigationController popToRootViewControllerAnimated:NO];
    }else{
        if ([result.message length] > 0) {
            [HMUtility alert:result.message title:@"提示"];
        }else{
            [HMUtility alert:@"密码修改失败！" title:@"提示"];
        }
        
    }

}
@end
