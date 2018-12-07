//
//  HMRecharge.m
//  hmArt
//
//  Created by 刘学 on 15/7/27.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import "HMRecharge.h"

@interface HMRecharge ()

@end

@implementation HMRecharge


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"在线充值";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"view_bg.png"]];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    
    CGRect rect = _scrollView.frame;
    if (IOS7) {
        rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - 29;
    }else{
        rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - 49;
    }
    _scrollView.frame = rect;
    _scrollView.backgroundColor = [UIColor clearColor];
    self.inputform = _scrollView;
    
    _topView = [[LCView alloc] initWithFrame:CGRectMake(0, 2, 320, 0)];
    [_scrollView addSubview:_topView];
    _topView.backgroundColor = [UIColor clearColor];
    
    [self initPage];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initPage
{
    
//    LCView *titleView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, _topView.frame.size.width, 0)];
//    [titleView setPaddingTop:16 paddingBottom:6 paddingLeft:10 paddingRight:10];
//    [_topView addCustomSubview:titleView intervalTop:0];
//    titleView.backgroundColor = [UIColor whiteColor];
//    
//    UIImageView *incoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"misc_help.png"]];
//    [titleView addCustomSubview:incoImage intervalLeft:0];
//    
//    UILabel *remark = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 0)];
//    remark.text = @"查看二次销售须知";
//    remark.tag = 1001;
//    remark.textColor = [UIColor redColor];
//    remark.userInteractionEnabled = YES;
//    [remark addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagRecharge:)]];
//    [titleView addCustomSublabel:remark intervalLeft:10];
    
    LCView *orderView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, _topView.frame.size.width, 0)];
    [orderView setPaddingTop:6 paddingBottom:6 paddingLeft:10 paddingRight:10];
    [_topView addCustomSubview:orderView intervalTop:0];
    orderView.backgroundColor = [UIColor whiteColor];
    
    LCView *initPriceView = [[LCView alloc] init];
    [initPriceView setPaddingTop:10 paddingBottom:10 paddingLeft:0 paddingRight:0];
    [orderView addCustomSubview:initPriceView intervalTop:0];
    UILabel *initPriceTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 0)];
    initPriceTitle.text = @"充值金额：";
    [initPriceView addCustomSublabel:initPriceTitle intervalLeft:0];
    _amountField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
    _amountField.borderStyle = UITextBorderStyleNone;
    _amountField.keyboardType = UIKeyboardTypeNumberPad;
    _amountField.delegate = self;
    _amountField.placeholder = @"--请输入充值金额--";
    _amountField.tag = 1004;
    [orderView addCustomSubview:_amountField intervalTop:10];
    [self addInput:_amountField sequence:1 name:nil];
    
    UILabel *paymentType = [[UILabel alloc] init];
    paymentType.text = [NSString stringWithFormat:@"支付方式: "];
    [orderView addCustomSublabel:paymentType intervalTop:10];
    
    
    /*** 银联支付 ***/
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
    
    
    /*** 支付宝支付 ***/
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

-(void) tagPayment:(id)sender{
    
    if (_amountField.text.length == 0) {
        [HMUtility showTipInView:self.view withText:@"请输入充值金额"];
        return;
    }
    
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 1];
    [queryParam setValue:[HMGlobalParams sharedInstance].mobile forKey:@"username"];
    [queryParam setValue:[NSNumber numberWithInteger:_payType] forKey:@"type"];
    [queryParam setValue:[NSNumber numberWithDouble:[_amountField.text doubleValue]] forKey:@"amount"];
    
    _requestId = [net asynRequest:interfaceMemberAccountRecharge with:queryParam needSSL:NO target:self action:@selector(dealPayments:result:)];
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
        NSDictionary *obj = [ret objectForKey:@"obj"];
        if(_payType == 1 || _payType == 3){
            //向微信注册
            //[WXApi registerApp:kWeChatAppKey withDescription:@"demo 2.0"];
            [self appPay:[obj objectForKey:@"payOrderNo"]];
            
        }else{
            HMWebPay *ctrl = [[HMWebPay alloc] initWithNibName:nil bundle:nil];
            ctrl.type = [[obj objectForKey:@"type"] integerValue];
            ctrl.payOrderSerial = [obj objectForKey:@"payOrderNo"];
            [self.navigationController pushViewController:ctrl animated:YES];
            
        }
    } else {
        [HMUtility alert:@"支付失败!" title:@"提示"];
        //[HMUtility tap2Action:@"重新支付" on:self.view target:self action:@selector(tagPayment:)];
    }
}


-(void)tagPayType:(id)sender
{
    UIView *view = [sender view];
    NSInteger tag = view.tag;
    if (tag == 2001) {
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

#pragma mark -
#pragma mark App控件支付（微信，或支付宝）
-(void) appPay:(NSString *)payOrderNo{
    
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 1];
    [queryParam setValue:[HMGlobalParams sharedInstance].mobile forKey:@"username"];
    [queryParam setValue:payOrderNo forKey:@"paySerialNo"];
    [queryParam setValue:[NSNumber numberWithInteger:_payType] forKey:@"payType"];
    
    _requestId = [net asynRequest:interfaceAppToPay with:queryParam needSSL:NO target:self action:@selector(dealAppPay:result:)];
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
}

- (void)dealAppPay:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestId = 0;
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *ret = result.value;
       // NSLog(@"%@", ret);
        NSDictionary *obj = [ret objectForKey:@"obj"];
        
        NSInteger payType = [[obj objectForKey:@"payType"] integerValue];
        
        if(payType == 1){
            //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
            NSString *appScheme = kAlipayAppKey;
            [[AlipaySDK defaultService] payOrder:[obj objectForKey:@"data"] fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                //NSLog(@"reslut = %@",resultDic);
                if([[resultDic objectForKey:@"resultStatus"] isEqualToString:@"9000"]){
                    NSRange foundObj=[[resultDic objectForKey:@"result"] rangeOfString:@"success=true" options:NSCaseInsensitiveSearch];
                    if(foundObj.length>0) {
                        [HMUtility alert:@"充值成功!" title:@"提示"];
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
            [WXApi sendReq:req];
            //[WXApi safeSendReq:req];
        }
    }
}

@end
