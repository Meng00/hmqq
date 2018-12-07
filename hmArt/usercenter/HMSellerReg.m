//
//  HMSellerReg.m
//  hmArt
//
//  Created by 刘学 on 15/9/9.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import "HMSellerReg.h"
#import "HMAppDelegate.h"
#import "NSString+URL.h"

@interface HMSellerReg ()

@end

@implementation HMSellerReg

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"商家签约入驻";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"view_bg.png"]];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    
    CGRect rect = _webView.frame;
    if (IOS7) {
        rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - 29;
    }else{
        rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - 49;
    }
    _webView.frame = rect;
    
    HMAppDelegate *app = (HMAppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *ran = [app getRandomString];
    NSURL *reqUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@&random=%@" ,kUrlSellerRegNotice, ran]];
    [_webView loadRequest:[NSURLRequest requestWithURL:reqUrl]];
    
    
    _reg = [[LCView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    UIView *line01 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
    [_reg addCustomSubview:line01 intervalTop:0];
    line01.backgroundColor = [UIColor grayColor];
    [_reg setPaddingTop:0 paddingBottom:10 paddingLeft:5 paddingRight:5];
    
    [self.view addSubview:_reg];
    _reg.backgroundColor = [UIColor whiteColor];
    
    [self query];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void) query{
    
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 1];
    [queryParam setValue:[HMGlobalParams sharedInstance].mobile forKey:@"username"];
    
    _requestId = [net asynRequest:interfaceSellerRegReq with:queryParam needSSL:NO target:self action:@selector(dealQuery:result:)];
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
}

- (void)dealQuery:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestId = 0;
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *ret = result.value;
        NSDictionary *obj = [ret objectForKey:@"obj"];
        NSInteger status = [[obj objectForKey:@"status"] integerValue];
        if(status == 9 || status == 2 ){
            UIButton *paybut = [UIButton buttonWithType:UIButtonTypeCustom];
            paybut.frame = CGRectMake(10, 0, 300, 25);
            paybut.tag = 1001;
            [paybut setTitle:@"我要申请" forState:UIControlStateNormal];
            [paybut setBackgroundImage:[UIImage imageNamed:@"btn_bg_brown.png"] forState:UIControlStateNormal];
            paybut.userInteractionEnabled = YES;
            [paybut addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagPayment:)]];
            [_reg addCustomSubview:paybut intervalTop:10];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _reg.frame.size.width, 0)];
            label.text = @"点击“我要申请”视为同意《商家入驻协议》";
            label.textColor = [UIColor grayColor];
            label.textAlignment = NSTextAlignmentCenter;
            [_reg addCustomSublabel:label intervalTop:5];
            
            

        }else if(status == 0){
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _reg.frame.size.width, 0)];
            label.text = @"您的请求已提交，平台工作人员将会与您联系。请保持手机通信畅通。";
            label.textColor = [UIColor grayColor];
            label.textAlignment = NSTextAlignmentCenter;
            [_reg addCustomSublabel:label intervalTop:5];
            
        }else if(status == 1){
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _reg.frame.size.width, 0)];
            label.text = @"您已是签约商家";
            label.textColor = [UIColor grayColor];
            label.textAlignment = NSTextAlignmentCenter;
            [_reg addCustomSublabel:label intervalTop:5];

        }
        
        [_reg resize];
        
        CGRect frame = _webView.frame;
        frame.size.height = frame.size.height - _reg.frame.size.height - 5;
        _webView.frame = frame;
        
        CGRect frame1 = _reg.frame;
        frame1.origin.y = _webView.frame.origin.y +_webView.frame.size.height + 5;
        _reg.frame = frame1;
    } else {
        [HMUtility alert:@"支付失败!" title:@"提示"];
        [HMUtility tap2Action:@"重新支付" on:self.view target:self action:@selector(tagPayment:)];
    }
}

-(void) tagPayment:(id)sender{
    
    
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 1];
    [queryParam setValue:[HMGlobalParams sharedInstance].mobile forKey:@"username"];
    
    _requestId = [net asynRequest:interfaceSellerRegSubmit with:queryParam needSSL:NO target:self action:@selector(dealPayments:result:)];
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
}

- (void)dealPayments:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestId = 0;
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        [HMUtility alert:@"申请成功!" title:@"提示"];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [HMUtility alert:@"申请失败!" title:@"提示"];
    }
}




@end
