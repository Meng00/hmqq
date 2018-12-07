//
//  HMUpgradeVIP.m
//  hmArt
//
//  Created by 刘学 on 15/7/14.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import "HMUpgradeVIP.h"

@interface HMUpgradeVIP ()

@end

@implementation HMUpgradeVIP
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"升级VIP会员";
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
    
    CGRect rect = _scrollView.frame;
    //rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - HM_SYS_VIEW_OFFSET;
    _scrollView.frame = rect;
    
    _topView = [[LCView alloc] initWithFrame:CGRectMake(0, 1, 320, 0)];
    [_scrollView addSubview:_topView];
    _topView.backgroundColor = [UIColor clearColor];
    data = nil;
    [self query];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(data == nil){
        [self query];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark query methods
- (void)query
{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 1];
    [queryParam setValue:[HMGlobalParams sharedInstance].mobile forKey:@"username"];
    _requestId = [net asynRequest:interfaceMemberVIPReq with:queryParam needSSL:NO target:self action:@selector(dealPictures:result:)];
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
        
        dic = [ret objectForKey:@"obj"];
        
        
        [self initPage];
        
        
    } else {
        [HMUtility alert:[NSString stringWithFormat:@"%@",result.message] title:@"提示"];
        //[HMUtility tap2Action:@"重新加载" on:self.view target:self action:@selector(query)];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)initPage
{
    if(_topView){
        [_topView removeFromSuperview];
    }
    _topView = [[LCView alloc] initWithFrame:CGRectMake(0, 1, 320, 0)];
    [_scrollView addSubview:_topView];
    _topView.backgroundColor = [UIColor clearColor];
    
    LCView *titleView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, _topView.frame.size.width, 0)];
    [titleView setPaddingTop:16 paddingBottom:6 paddingLeft:10 paddingRight:10];
    [_topView addCustomSubview:titleView intervalTop:0];
    titleView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *incoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"misc_help.png"]];
    [titleView addCustomSubview:incoImage intervalLeft:0];
    
    UILabel *remark = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 0)];
    remark.text = @">> 查看VIP升级须知";
    remark.tag = 100;
    remark.textColor = [UIColor redColor];
    remark.userInteractionEnabled = YES;
    [remark addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagPayType:)]];
    [titleView addCustomSublabel:remark intervalLeft:10];
    
    LCView *orderView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, _topView.frame.size.width, 0)];
    [orderView setPaddingTop:6 paddingBottom:6 paddingLeft:10 paddingRight:10];
    [_topView addCustomSubview:orderView intervalTop:0];
    orderView.backgroundColor = [UIColor whiteColor];
    
    UILabel *auctionPrice = [[UILabel alloc] init];
    auctionPrice.text = [NSString stringWithFormat:@"支付金额: ￥%@", [dic objectForKey:@"amount"]];
    [orderView addCustomSublabel:auctionPrice intervalTop:10];
    
    UILabel *paymentType = [[UILabel alloc] init];
    paymentType.text = [NSString stringWithFormat:@"支付方式: "];
    [orderView addCustomSublabel:paymentType intervalTop:10];
    
    /***** 银联支付 *******/
    UIView *line00 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
    [orderView addCustomSubview:line00 intervalTop:10];
    line00.backgroundColor = [UIColor grayColor];
    
    LCView *acpView = [[LCView alloc] init];
    acpView.tag = 2001;
    acpView.userInteractionEnabled = YES;
    [acpView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagPayType:)]];
    [orderView addCustomSubview:acpView intervalTop:5];
    _payType = 2;
    
    UIImageView *acpLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 32)];
    acpLogo.image = [UIImage imageNamed:@"pay_2.png"];
    [acpView addCustomSubview:acpLogo intervalLeft:10];
    
    UILabel *acpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 32)];
    acpLabel.text = [NSString stringWithFormat:@"中国银联"];
    [acpView addCustomSublabel:acpLabel intervalLeft:15];
    
    acpSelect = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    acpSelect.image = [UIImage imageNamed:@"global_selector_checked.png"];
    [acpView addCustomSubview:acpSelect intervalLeft:15];
    
    /****** 支付宝支付 ******/
    UIView *line01 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
    [orderView addCustomSubview:line01 intervalTop:10];
    line01.backgroundColor = [UIColor grayColor];
    
    LCView *alipayView = [[LCView alloc] init];
    alipayView.tag = 2002;
    alipayView.userInteractionEnabled = YES;
    [alipayView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagPayType:)]];
    [orderView addCustomSubview:alipayView intervalTop:5];
    
    UIImageView *alipayLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 32)];
    alipayLogo.image = [UIImage imageNamed:@"pay_1.png"];
    [alipayView addCustomSubview:alipayLogo intervalLeft:10];
    
    UILabel *alipayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 32)];
    alipayLabel.text = [NSString stringWithFormat:@"支付宝"];
    [alipayView addCustomSublabel:alipayLabel intervalLeft:15];
    
    alipaySelect = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    alipaySelect.image = [UIImage imageNamed:@"global_selector_uncheck.png"];
    [alipayView addCustomSubview:alipaySelect intervalLeft:15];
    
    /*********** 微信支付 *************/
    UIView *line02 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
    [orderView addCustomSubview:line02 intervalTop:10];
    line02.backgroundColor = [UIColor grayColor];
    
    LCView *weixinView = [[LCView alloc] init];
    weixinView.tag = 2003;
    weixinView.userInteractionEnabled = YES;
    [weixinView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagPayType:)]];
    [orderView addCustomSubview:weixinView intervalTop:5];
    
    UIImageView *weixinLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    weixinLogo.image = [UIImage imageNamed:@"icon32_wx_logo.png"];
    [weixinView addCustomSubview:weixinLogo intervalLeft:25];
    
    UILabel *weixinLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 32)];
    weixinLabel.text = [NSString stringWithFormat:@"微信支付"];
    [weixinView addCustomSublabel:weixinLabel intervalLeft:28];
    
    weixinSelect = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    weixinSelect.image = [UIImage imageNamed:@"global_selector_uncheck.png"];
    [weixinView addCustomSubview:weixinSelect intervalLeft:15];
    
    
    UIButton *paybut = [UIButton buttonWithType:UIButtonTypeCustom];
    paybut.frame = CGRectMake(10, 0, 300, 25);
    paybut.tag = 1001;
    [paybut setTitle:@"去支付" forState:UIControlStateNormal];
    [paybut setBackgroundImage:[UIImage imageNamed:@"btn_bg_brown.png"] forState:UIControlStateNormal];
    paybut.userInteractionEnabled = YES;
    [paybut addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagPayment:)]];
    [_topView addCustomSubview:paybut intervalTop:10];
    
    [_topView resize];
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _topView.frame.origin.y +_topView.frame.size.height+10);

}

-(void)tagPayType:(id)sender
{
    UIView *view = [sender view];
    NSInteger tag = view.tag;
    if(tag == 100){
        LCWebView *web = [[LCWebView alloc] initWithNibName:nil bundle:nil];
        web.url = kUrlVIPNotice;
        web.title = @"VIP须知";
        [self.navigationController pushViewController:web animated:YES];
    }else if (tag == 2001) {
        acpSelect.image = [UIImage imageNamed:@"global_selector_checked.png"];
        alipaySelect.image = [UIImage imageNamed:@"global_selector_uncheck.png"];
        weixinSelect.image = [UIImage imageNamed:@"global_selector_uncheck.png"];
        _payType = 2;
    }else if(tag == 2002){
        alipaySelect.image = [UIImage imageNamed:@"global_selector_checked.png"];
        acpSelect.image = [UIImage imageNamed:@"global_selector_uncheck.png"];
        weixinSelect.image = [UIImage imageNamed:@"global_selector_uncheck.png"];
        _payType = 1;
    }else if(tag == 2003){
        alipaySelect.image = [UIImage imageNamed:@"global_selector_uncheck.png"];
        acpSelect.image = [UIImage imageNamed:@"global_selector_uncheck.png"];
        weixinSelect.image = [UIImage imageNamed:@"global_selector_checked.png"];
        _payType = 3;
    }
}

-(void) tagPayment:(id)sender{
    if (data == nil) {
        [self payQuery];
    }else{
        if(_payType == 1 || _payType == 3){
            
            [self appPay:[data objectForKey:@"payOrderNo"]];
            
        }else{
            HMWebPay *ctrl = [[HMWebPay alloc] initWithNibName:nil bundle:nil];
            ctrl.type = [[data objectForKey:@"type"] integerValue];
            ctrl.payOrderSerial = [data objectForKey:@"payOrderNo"];
            [self.navigationController pushViewController:ctrl animated:YES];
            
        }
    }
}

-(void)payQuery
{
    
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 1];
    [queryParam setValue:[HMGlobalParams sharedInstance].mobile forKey:@"username"];
    [queryParam setValue:[NSNumber numberWithInteger:_payType] forKey:@"type"];
    
    _requestId = [net asynRequest:interfaceMemberVIPRecharge with:queryParam needSSL:NO target:self action:@selector(dealPayments:result:)];
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
}



- (void)dealPayments:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestId = 0;
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *ret = result.value;
        data = [ret objectForKey:@"obj"];
        
        if(_payType == 1 || _payType == 3){
            //向微信注册
            [WXApi registerApp:kWeChatAppKey withDescription:@"demo 2.0"];
            [self appPay:[data objectForKey:@"payOrderNo"]];
            
        }else{
            HMWebPay *ctrl = [[HMWebPay alloc] initWithNibName:nil bundle:nil];
            ctrl.type = [[data objectForKey:@"type"] integerValue];
            ctrl.payOrderSerial = [data objectForKey:@"payOrderNo"];
            [self.navigationController pushViewController:ctrl animated:YES];
            
        }
        
    } else {
        if(result.message) [HMUtility alert:result.message title:@"提示"];
        else [HMUtility alert:@"支付失败!" title:@"提示"];
        //[HMUtility tap2Action:@"重新支付" on:self.view target:self action:@selector(tagPayment:)];
    }
}

#pragma mark -
#pragma mark App控件支付（微信，或支付宝）
-(void) appPay:(NSString *)payOrderNo{
    
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_appPayRequestId != 0) {
        [net cancelRequest:_appPayRequestId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 1];
    [queryParam setValue:[HMGlobalParams sharedInstance].mobile forKey:@"username"];
    [queryParam setValue:payOrderNo forKey:@"paySerialNo"];
    [queryParam setValue:[NSNumber numberWithInteger:_payType] forKey:@"payType"];
    
    _appPayRequestId = [net asynRequest:interfaceAppToPay with:queryParam needSSL:NO target:self action:@selector(dealAppPay:result:)];
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
}

- (void)dealAppPay:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _appPayRequestId = 0;
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *ret = result.value;
        // NSLog(@"%@", ret);
        NSDictionary *obj = [ret objectForKey:@"obj"];
        
        NSInteger payType = [[obj objectForKey:@"payType"] integerValue];
        
        if(payType == 1){
            NSString *appScheme = kAlipayAppKey;
            
            [[AlipaySDK defaultService] payOrder:[obj objectForKey:@"data"] fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                //NSLog(@"reslut = %@",resultDic);
                if([[resultDic objectForKey:@"resultStatus"] isEqualToString:@"9000"]){
                    NSRange foundObj=[[resultDic objectForKey:@"result"] rangeOfString:@"success=true" options:NSCaseInsensitiveSearch];
                    if(foundObj.length>0) {
                        [HMUtility alert:@"支付成功!" title:@"提示"];
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
                
            }];
            
        }else if(payType == 3){
            NSDictionary *weiData = [obj objectForKey:@"data"];
            NSMutableString *stamp  = [weiData objectForKey:@"timestamp"];
            //调起微信支付
            PayReq* req             = [[PayReq alloc] init];
            //req.openID              = [weiData objectForKey:@"appid"];
            req.partnerId           = [weiData objectForKey:@"partnerid"];
            req.prepayId            = [weiData objectForKey:@"prepayid"];
            req.nonceStr            = [weiData objectForKey:@"noncestr"];
            req.timeStamp           = stamp.intValue;
            req.package             = [weiData objectForKey:@"package"];
            req.sign                = [weiData objectForKey:@"sign"];
            BOOL b = [WXApi sendReq:req];
            //[WXApi safeSendReq:req];
            NSLog(@"%i",b);
        }
        data = nil;
    }
}


@end
