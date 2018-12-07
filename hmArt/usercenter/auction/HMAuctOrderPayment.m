//
//  HMAuctOrderPayment.m
//  hmArt
//
//  Created by 刘学 on 15/7/12.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import "HMAuctOrderPayment.h"

@interface HMAuctOrderPayment ()

@end

@implementation HMAuctOrderPayment

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"订单支付";
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
    dic = nil;
    
}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(dic == nil){
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
    _requestId = [net asynRequest:interfaceMemberAuctOrderPayment with:queryParam needSSL:NO target:self action:@selector(dealPictures:result:)];
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
        
        [_topView removeFromSuperview];
        _topView = [[LCView alloc] initWithFrame:CGRectMake(0, 2, 320, 0)];
        [_scrollView addSubview:_topView];
        _topView.backgroundColor = [UIColor clearColor];
        
        LCView *orderView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, _topView.frame.size.width, 0)];
        [orderView setPaddingTop:6 paddingBottom:6 paddingLeft:10 paddingRight:10];
        [_topView addCustomSubview:orderView intervalTop:0];
        orderView.backgroundColor = [UIColor whiteColor];
        
        if([dic objectForKey:@"voucher"]){
            UILabel *totalAmount = [[UILabel alloc] init];
            totalAmount.text = [NSString stringWithFormat:@"总金额: ￥%@", [dic objectForKey:@"amount"]];
            [orderView addCustomSublabel:totalAmount intervalTop:10];
            
            NSDictionary *voucher = [dic objectForKey:@"voucher"];
            UILabel *voucherAmount = [[UILabel alloc] init];
            voucherAmount.text = [NSString stringWithFormat:@"代金券抵用: ￥%@", [voucher objectForKey:@"price"]];
            [orderView addCustomSublabel:voucherAmount intervalTop:10];
            
            UILabel *auctionPrice = [[UILabel alloc] init];
            auctionPrice.text = [NSString stringWithFormat:@"需在线支付: ￥%@", [dic objectForKey:@"payAmount"]];
            [orderView addCustomSublabel:auctionPrice intervalTop:10];
            
        }else{
            UILabel *auctionPrice = [[UILabel alloc] init];
            auctionPrice.text = [NSString stringWithFormat:@"支付金额: ￥%@", [dic objectForKey:@"amount"]];
            [orderView addCustomSublabel:auctionPrice intervalTop:10];
            
        }
        
        
        UILabel *paymentType = [[UILabel alloc] init];
        paymentType.text = [NSString stringWithFormat:@"支付方式: "];
        [orderView addCustomSublabel:paymentType intervalTop:10];
        
        UIView *line00 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
        [orderView addCustomSubview:line00 intervalTop:10];
        line00.backgroundColor = [UIColor grayColor];
        
        /*******银联支付********/
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
        
        
        /************ 支付宝支付 **********/
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
        
        /*******线下支付********/
        UIView *line03 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
        [orderView addCustomSubview:line03 intervalTop:10];
        line03.backgroundColor = [UIColor grayColor];
        
        LCView *offlineView = [[LCView alloc] init];
        offlineView.tag = 2004;
        offlineView.userInteractionEnabled = YES;
        [offlineView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagPayType:)]];
        [orderView addCustomSubview:offlineView intervalTop:5];
        
        UIImageView *offLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 32)];
        offLogo.image = [UIImage imageNamed:@"pay_4.png"];
        [offlineView addCustomSubview:offLogo intervalLeft:10];
        
        UILabel *offLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 32)];
        offLabel.text = [NSString stringWithFormat:@"线下支付"];
        [offlineView addCustomSublabel:offLabel intervalLeft:15];
        
        offlineSelect = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        offlineSelect.image = [UIImage imageNamed:@"global_selector_uncheck.png"];
        [offlineView addCustomSubview:offlineSelect intervalLeft:15];
        
        /******  收货信息 * ******/
        LCView *contactsView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, _topView.frame.size.width, 0)];
        [contactsView setPaddingTop:6 paddingBottom:6 paddingLeft:10 paddingRight:10];
        [_topView addCustomSubview:contactsView intervalTop:10];
        contactsView.backgroundColor = [UIColor whiteColor];
        
        UILabel *payLabel = [[UILabel alloc] init];
        payLabel.text = @"收货地址";
        [contactsView addCustomSublabel:payLabel intervalTop:0];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
        [contactsView addCustomSubview:line1 intervalTop:0];
        
        LCView *mobileView = [[LCView alloc] init];
        [mobileView setPaddingTop:10 paddingBottom:10 paddingLeft:0 paddingRight:0];
        [contactsView addCustomSubview:mobileView intervalTop:0];
        
        UILabel *mobileTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 0)];
        mobileTitle.text = @"联系人手机：";
        [mobileView addCustomSublabel:mobileTitle intervalLeft:0];
        
        _mobileField = [[UITextField alloc]  initWithFrame:CGRectMake(0, 0, 0, 20)];
        _mobileField.borderStyle = UITextBorderStyleNone;
        _mobileField.text = [dic objectForKey:@"phone"];
        _mobileField.delegate = self;
        _mobileField.keyboardType = UIKeyboardTypeNumberPad;
        _mobileField.placeholder = @"--请输入--";
        _mobileField.tag = 1003;
        //_mobileField.enabled = NO;
        [mobileView addCustomSubview:_mobileField intervalLeft:5];
        [self addInput:_mobileField sequence:1 name:nil];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
        [contactsView addCustomSubview:line2 intervalTop:0];
        line2.backgroundColor = [UIColor grayColor];
        
        LCView *userNameView = [[LCView alloc] init];
        [userNameView setPaddingTop:10 paddingBottom:10 paddingLeft:0 paddingRight:0];
        [contactsView addCustomSubview:userNameView intervalTop:0];
        UILabel *userNameTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 0)];
        userNameTitle.text = @"联系人姓名：";
        [userNameView addCustomSublabel:userNameTitle intervalLeft:0];
        _userNameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
        _userNameField.borderStyle = UITextBorderStyleNone;
        _userNameField.text = [dic objectForKey:@"contacts"];
        _userNameField.delegate = self;
        _userNameField.placeholder = @"--请输入--";
        _userNameField.tag = 1004;
        [userNameView addCustomSubview:_userNameField intervalLeft:5];
        [self addInput:_userNameField sequence:2 name:nil];
        
        UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
        [contactsView addCustomSubview:line3 intervalTop:0];
        line3.backgroundColor = [UIColor grayColor];
        
        LCView *addrView = [[LCView alloc] init];
        [addrView setPaddingTop:10 paddingBottom:10 paddingLeft:0 paddingRight:0];
        [contactsView addCustomSubview:addrView intervalTop:0];
        UILabel *addrTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 0)];
        addrTitle.text = @"邮 寄 地 址：";
        [addrView addCustomSublabel:addrTitle intervalLeft:0];
        _addrField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
        _addrField.borderStyle = UITextBorderStyleNone;
        _addrField.text = [dic objectForKey:@"address"];
        _addrField.delegate = self;
        _addrField.placeholder = @"--请输入--";
        _addrField.tag = 1006;
        [addrView addCustomSubview:_addrField intervalLeft:5];
        [self addInput:_addrField sequence:3 name:nil];
        
        UIButton *paybut = [UIButton buttonWithType:UIButtonTypeCustom];
        paybut.frame = CGRectMake(10, 0, 300, 30);
        paybut.tag = 1001;
        [paybut setTitle:@"去支付" forState:UIControlStateNormal];
        [paybut setBackgroundImage:[UIImage imageNamed:@"btn_bg_brown.png"] forState:UIControlStateNormal];
        paybut.userInteractionEnabled = YES;
        [paybut addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagPayment:)]];
        [_topView addCustomSubview:paybut intervalTop:10];
        
        [_topView resize];
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _topView.frame.origin.y +_topView.frame.size.height + 100);
    } else {
        [HMUtility alert:@"下载失败!" title:@"提示"];
        [HMUtility tap2Action:@"重新加载" on:self.view target:self action:@selector(query)];
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
    if([[dic objectForKey:@"amount"] integerValue] <= 0){
        return;
    }
    if (![HMTextChecker checkIsMobile:_mobileField.text]) {
        [HMUtility alert:@"手机号码格式不正确" title:@"提示"];
        return;
    }if (_userNameField.text.length == 0) {
        [HMUtility showTipInView:self.view withText:@"请输入联系人姓名"];
        return;
    }if (_addrField.text.length == 0) {
        [HMUtility showTipInView:self.view withText:@"请输入收货地址"];
        return;
    }
    
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 1];
    [queryParam setValue:[HMGlobalParams sharedInstance].mobile forKey:@"username"];
    [queryParam setValue:[dic objectForKey:@"orderIds"] forKey:@"orderIds"];
    [queryParam setValue:[dic objectForKey:@"amount"] forKey:@"amount"];
    [queryParam setValue:[NSNumber numberWithInteger:_payType] forKey:@"type"];
    [queryParam setValue:_userNameField.text forKey:@"contacts"];
    [queryParam setValue:_mobileField.text forKey:@"phone"];
    [queryParam setValue:_addrField.text forKey:@"address"];
    if([dic objectForKey:@"voucher"]){
        NSDictionary *voucher = [dic objectForKey:@"voucher"];
        [queryParam setValue:[voucher objectForKey:@"id"] forKey:@"vouchersId"];
        [queryParam setValue:[voucher objectForKey:@"price"] forKey:@"vouchersVaule"];
    }
    
    _requestId = [net asynRequest:interfaceMemberAuctOrderToPay with:queryParam needSSL:NO target:self action:@selector(dealPayments:result:)];
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
        NSLog(@"%@", ret);
        data = [ret objectForKey:@"obj"];
        if(_payType == 1 || _payType == 3){
            [self appPay:[data objectForKey:@"payOrderNo"]];
            
        }else{
            HMWebPay *ctrl = [[HMWebPay alloc] initWithNibName:nil bundle:nil];
            ctrl.type = [[data objectForKey:@"type"] integerValue];
            ctrl.payOrderSerial = [data objectForKey:@"payOrderNo"];
            [self.navigationController pushViewController:ctrl animated:YES];
            
        }
    } else {
        [HMUtility alert:@"支付失败!" title:@"提示"];
        //[HMUtility tap2Action:@"重新支付" on:self.view target:self action:@selector(tagPayment:)];
    }
}

#pragma mark -
#pragma mark App控件支付（微信，或支付宝）
-(void) appPay:(NSString *)payOrderNo{
    
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_appPayRequestId != 0) {
        [net cancelRequest:_requestId];
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


-(void)tagPayType:(id)sender
{
    UIView *view = [sender view];
    NSInteger tag = view.tag;
    if (tag == 2001) {
        acpSelect.image = [UIImage imageNamed:@"global_selector_checked.png"];
        alipaySelect.image = [UIImage imageNamed:@"global_selector_uncheck.png"];
        weixinSelect.image = [UIImage imageNamed:@"global_selector_uncheck.png"];
        offlineSelect.image = [UIImage imageNamed:@"global_selector_uncheck.png"];
        _payType = 2;
    }else if(tag == 2002){
        alipaySelect.image = [UIImage imageNamed:@"global_selector_checked.png"];
        acpSelect.image = [UIImage imageNamed:@"global_selector_uncheck.png"];
        weixinSelect.image = [UIImage imageNamed:@"global_selector_uncheck.png"];
        offlineSelect.image = [UIImage imageNamed:@"global_selector_uncheck.png"];
        _payType = 1;
    }else if(tag == 2003){
        alipaySelect.image = [UIImage imageNamed:@"global_selector_uncheck.png"];
        acpSelect.image = [UIImage imageNamed:@"global_selector_uncheck.png"];
        weixinSelect.image = [UIImage imageNamed:@"global_selector_checked.png"];
        offlineSelect.image = [UIImage imageNamed:@"global_selector_uncheck.png"];
        _payType = 3;
    }else if(tag == 2004){
        alipaySelect.image = [UIImage imageNamed:@"global_selector_uncheck.png"];
        acpSelect.image = [UIImage imageNamed:@"global_selector_uncheck.png"];
        weixinSelect.image = [UIImage imageNamed:@"global_selector_uncheck.png"];
        offlineSelect.image = [UIImage imageNamed:@"global_selector_checked.png"];
        _payType = 4;
    }
}

@end
