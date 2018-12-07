//
//  HMJSBaseView.m
//  hmArt
//
//  Created by 刘学 on 16/1/25.
//  Copyright © 2016年 hanmoqianqiu. All rights reserved.
//

#import "HMJSBaseView.h"
#import "NSString+URL.h"
#import "HMWebPay.h"
#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>
#import "LCJsonUtil.h"

@implementation HMJSBaseView

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 左侧返回按钮，便于处理定时器
    UIBarButtonItem *backButton =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back.png"] style:UIBarButtonItemStyleDone target:self action:@selector(backButtonDown:)];
    backButton.style = UIBarButtonItemStyleDone;
    self.navigationItem.leftBarButtonItem = backButton;
//    CGRect rectView = self.view.bounds;
//    NSLog(@"width: %f height: %f", rectView.size.width, rectView.size.height);
//    NSLog(@"width: %f height: %f", [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    
    _agentWeb = [[EasyJSWebView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    
    [self dealUserAgent];
    
    _agentWeb.delegate = self;
    _agentWeb.opaque = NO;
//    [_agentWeb setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"view_bg.png"]]];
    [_agentWeb setBackgroundColor:[UIColor whiteColor]];
    _agentWeb.dataDetectorTypes = UIDataDetectorTypeNone;
    [self.view addSubview:_agentWeb];
    
    LCJsInterface* interface = [LCJsInterface new];
    interface.jsWebView = _agentWeb;
    interface.delegate = self;
    [_agentWeb addJavascriptInterfaces:interface WithName:@"HMARTJsObj"];
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_agentWeb stringByEvaluatingJavaScriptFromString:@"javascript:pageWillRefresh()"];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backButtonDown:(id)sender
{
    //HTML APP 上一页
    if([_agentWeb canGoBack]){
        [_agentWeb goBack];
    }else{
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark load web page
- (void)loadFromUrl:(NSString *)toUrl inWeb:(UIWebView *)webView
{
    _webUrl = toUrl;
    //    if (_agentWeb == nil) {
    //        _agentWeb = webView;
    //        [self dealUserAgent];
    //    }
    [self loadHomePage];
    
}

- (void)loadHomePage
{
    NSURL *reqUrl = nil;
    if([_webUrl hasPrefix:@"http://localhost/"] || [_webUrl hasPrefix:@"https://localhost/"]){
        NSString *httpUrl = _webUrl;
        httpUrl = [[httpUrl componentsSeparatedByString:@"?"] objectAtIndex:0];
        if([_webUrl hasPrefix:@"http://localhost/"]){
            httpUrl = [httpUrl stringByReplacingOccurrencesOfString:@"http://localhost/" withString:@""];
            
        }else {
            httpUrl = [httpUrl stringByReplacingOccurrencesOfString:@"https://localhost/" withString:@""];
            
        }
        NSString *filePath = [[NSBundle mainBundle] pathForResource:httpUrl ofType:nil];
        reqUrl = [NSURL fileURLWithPath:filePath];
    }else{
        NSString *sUrl;
        NSRange searchResult = [_webUrl rangeOfString:@"?"];
        if (searchResult.location == NSNotFound) {
            sUrl = [NSString stringWithFormat:@"%@?random=%f", _webUrl, [[NSDate date] timeIntervalSinceNow]];
        }else{
            sUrl = [NSString stringWithFormat:@"%@&random=%f", _webUrl, [[NSDate date] timeIntervalSinceNow]];
        }
        
        NSString *encodedString=[sUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        reqUrl = [NSURL URLWithString:encodedString];
        
    }
    
    [_agentWeb loadRequest:[NSURLRequest requestWithURL:reqUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5.0]];
}



- (void)refreshPage
{
    if ([_agentWeb canGoBack]) {
        [_agentWeb reload];
    }else{
        [self loadHomePage];
    }
}

- (void)loadFromCode:(NSString *)serviceCode withParams:(NSString *)urlParams inWeb:(UIWebView *)webView
{
    if (_agentWeb == nil) {
        _agentWeb = webView;
        [self dealUserAgent];
    }
    if (urlParams && urlParams.length > 0) {
        _urlParams = urlParams;
    }else{
        _urlParams = nil;
    }
    _appEntrance = serviceCode;
    //[self query];
    
}

- (void)dealUserAgent
{
    if (![HMGlobalParams sharedInstance].appendUserAgentSuffix) {
        [HMGlobalParams sharedInstance].appendUserAgentSuffix = YES;
        
        NSDictionary *dictAppInfo = [[NSBundle mainBundle] infoDictionary];
        NSString *appVerNum = [dictAppInfo objectForKey:@"CFBundleShortVersionString"];
        
        NSString *oldAgent = [_agentWeb stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        //NSLog(@"old agent :%@", oldAgent);
        
        //add my info to the new agent
        NSString *newAgent = [oldAgent stringByAppendingString:[NSString stringWithFormat:@" HMQQ_APP_IOS/%@", appVerNum]];
        //NSLog(@"new agent :%@", newAgent);
        
        //regist the new agent
        NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    }
}


- (void)goHomePage
{
    NSURL *reqUrl = [NSURL URLWithString:_webUrl];
    
    [_agentWeb loadRequest:[NSURLRequest requestWithURL:reqUrl]];
}



#pragma mark -
#pragma mark JsInterface delegate - category user
-(void) login:(EasyJSDataFunction*)func{
    self.tabBarController.tabBar.hidden = YES;
    HMLoginEx *ctrl = [[HMLoginEx alloc] initWithNibName:nil bundle:nil];
    ctrl.delegate = self;
    ctrl.func = func;
    ctrl.navigationItem.hidesBackButton = YES;
    [self.navigationController pushViewController:ctrl animated:YES];
}

#pragma mark -
#pragma mark HMLoginEn delegate
-(void) loginResult:(BOOL) result func:(EasyJSDataFunction*) func{
    
    if(func){
        NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity: 7];
        [ret setValue:@"1" forKey:@"result"];
        [ret setValue:@"" forKey:@"message"];
        if (!result) {
            [ret setValue:@"0" forKey:@"loginStatus"];
        }else{
            [ret setValue:@"1" forKey:@"loginStatus"];
            HMGlobalParams *gParams = [HMGlobalParams sharedInstance];
            if(gParams.loginToken) [ret setValue:gParams.loginToken forKey:@"loginToken"];
            [ret setValue:gParams.name forKey:@"name"];
            [ret setValue:gParams.mobile forKey:@"mobile"];
        }
        [func executeWithParam:[ret JSONString]];
    }
}

-(void)signout:(NSString*) backurl{
    if ([backurl isEqualToString:@"1"]) {
        //HTML APP 首页
        while([_agentWeb canGoBack]){
            [_agentWeb goBack];
        }
    }else if ([backurl isEqualToString:@"2"]) {
        //HTML APP 上一页
        if([_agentWeb canGoBack]){
            [_agentWeb goBack];
        }
    }
}


#pragma mark -
#pragma mark gui interface
-(void) hideTabBar:(NSString*) hide{
    if ([hide isEqualToString:@"1"]) {
        [self makeTabBarHidden:YES];
        
    }else{
        [self makeTabBarHidden:NO];
        
    }
}


- (void)setHeaderColorRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b
{
    UIColor *color = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
    if (IOS7) {
        [self.navigationController.navigationBar setBarTintColor:color];
        
    }else{
        [self.navigationController.navigationBar setTintColor:color];
    }
    [HMUtility navBar:self.navigationController.navigationBar backImage:@"" backTag:110];
    
}

- (void)setHeaderTitle:(NSString *)title
{
    self.title = title;
}

- (void)makeTabBarHidden:(BOOL)hide
{
//    if ( [self.tabBarController.view.subviews count] < 2 )
//    {
//        return;
//    }
//    UIView *contentView;
//    
//    if ( [[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]] )
//    {
//        contentView = [self.tabBarController.view.subviews objectAtIndex:1];
//    }
//    else
//    {
//        contentView = [self.tabBarController.view.subviews objectAtIndex:0];
//    }
//    //    [UIView beginAnimations:@"TabbarHide" context:nil];
//    if ( hide )
//    {
//        contentView.frame = self.tabBarController.view.bounds;
//    }
//    else
//    {
//        contentView.frame = CGRectMake(self.tabBarController.view.bounds.origin.x,
//                                       self.tabBarController.view.bounds.origin.y,
//                                       self.tabBarController.view.bounds.size.width,
//                                       self.tabBarController.view.bounds.size.height - self.tabBarController.tabBar.frame.size.height);
//    }
//    CGRect rect = _agentWeb.frame;
//    CGFloat offset = hide ? 44 : 93;
//    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - offset;
//    _agentWeb.frame = rect;
//    
    _tabBarHidden = hide;
//    self.tabBarController.tabBar.hidden = hide;
    self.navigationController.navigationBarHidden = hide;
    if(hide){
        
    }else{
//        [HMUtility navBar:self.navigationController.navigationBar backImage:@"home_bg.png" backTag:HM_SYS_NAVIBARBG_TAG];
    }
}


#pragma mark -
#pragma mark shake motion event
-(void)shakeMotion:(EasyJSDataFunction*) func
{
    _isShaking = YES;
    _shakeMotionFunc = func;
}
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (!_isShaking) {
        return;
    }
    SystemSoundID soundId2;
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"shake_sound" ofType:@"mp3"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path2], &soundId2);
    AudioServicesPlaySystemSound (soundId2);
    
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(reportShake:) userInfo:nil repeats:YES];
    
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (!_isShaking) {
        return;
    }
    if (_timer) {
        [_timer invalidate];
    }
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(invokeShakeEvent:)
                                   userInfo:@"shakeDetected"
                                    repeats:NO];
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (_timer) {
        [_timer invalidate];
    }
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(invokeShakeEvent:)
                                   userInfo:@"shakeCanceled"
                                    repeats:NO];
}

-(void)reportShake:(NSTimer *)theTimer
{
    if (_shakeMotionFunc) {
        NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity: 7];
        [ret setValue:@"1" forKey:@"result"];
        [ret setValue:@"success" forKey:@"message"];
        [ret setValue:@"1" forKey:@"status"];
        [_shakeMotionFunc executeWithParam:[ret JSONString]];
    }
}

-(void)invokeShakeEvent:(NSTimer *)theTimer
{
    
    NSString *type = (NSString *)[theTimer userInfo];
    NSString *status;
    if ([type isEqualToString:@"shakeCanceled"]) {
        status = @"3";
    }else{
        status = @"2";
        SystemSoundID soundId2;
        NSString *path2 = [[NSBundle mainBundle] pathForResource:@"shake_sound2" ofType:@"mp3"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path2], &soundId2);
        AudioServicesPlaySystemSound (soundId2);
    }
    if (_shakeMotionFunc) {
        _isShaking = NO;
        NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity: 7];
        [ret setValue:@"1" forKey:@"result"];
        [ret setValue:@"success" forKey:@"message"];
        [ret setValue:status forKey:@"status"];
        [_shakeMotionFunc executeWithParam:[ret JSONString]];
    }
    
}



#pragma mark -
#pragma mark open url with safari, make a phonecall, send sms
- (void)openUrl:(NSString *)url inAPP:(BOOL)isIn
{
    if (isIn) {
        //
    }else{
        NSURL *candidateURL = [NSURL URLWithString:url];
        // 如果是URL, 则用浏览器访问
        if (candidateURL) {
            
            UIApplication *myApp = [UIApplication sharedApplication];
            [myApp openURL:candidateURL];
        }
    }
    
}

- (void)call:(NSString *)phone serviceName:(NSString *)service tips:(NSString *)title showNumber:(BOOL)show
{
    //    LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:title phone:phone showPhoneNumber:show type:LC_CLIENT_VISIT_TYPE_HOME name:service cancelButtonTitle:@"取消" okButtonTitle:@"确定"];
    //    [actionSheet showPhonecall:self.tabBarController.tabBar];
    
    LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:title phone:phone showPhoneNumber:show  type:service name:service cancelButtonTitle:@"取消" okButtonTitle:@"确定"];
    [actionSheet showPhonecall:self.view];
    
    
}

-(void) sendSms:(NSString *)content toMobile:(NSString *)mobile
{
    [self sendSmsContent:content toMobile:mobile];
}

- (void)sendSmsContent:(NSString *)content toMobile:(NSString *)mobile
{
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.messageComposeDelegate = self;
        controller.body = content;
        controller.recipients = [NSArray arrayWithObjects:mobile, nil];
        [self presentViewController:controller animated:YES completion:nil];
        //self.navigationController.navigationBarHidden = YES;
    }else{
        [LCAlertView showWithTitle:@"提示" message:@"该设备不支持短信功能！" buttonTitle:@"确定"];
    }
}

/**
 *APP分享
 **/
- (void)fenxiangTitle:(NSString *)title Content:(NSString *)content ImageUrl:(NSString *)image SiteUrl:(NSString *)url
{
    //[self enableKeyboardObserve:NO];
    
        id<ISSContent> publishContent = [ShareSDK content:content
                                           defaultContent:content
                                                    image:[ShareSDK imageWithUrl:image]
                                                    title:title
                                                      url:url
                                              description:content
                                                mediaType:SSPublishContentMediaTypeNews];
    
        [ShareSDK showShareActionSheet:nil shareList:nil content:publishContent statusBarTips:YES authOptions:nil shareOptions:nil result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end){
            //[self enableKeyboardObserve:YES];
            if (state == SSResponseStateSuccess) {
                [LCAlertView showWithTitle:nil message:@"分享成功！" buttonTitle:@"确认"];
            }
            else if (state == SSResponseStateFail){
    
                [LCAlertView showWithTitle:@"分享失败" message:[NSString stringWithFormat:@"错误码:%ld, 错误描述:%@", (long)[error errorCode], [error errorDescription]] buttonTitle:@"确认"];
            }
        }
    ];
    
}

- (void)goBack{
    //HTML APP 上一页
    if([_agentWeb canGoBack]){
        [_agentWeb goBack];
    }else{
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)popToRootView{
    //HTML APP 上一页
    if([_agentWeb canGoBack]){
        [_agentWeb goBack];
    }else{
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)toPay:(NSString*)type Data:(NSString*)data
{
    if([type isEqualToString:@"1"]){
        
        [[AlipaySDK defaultService] payOrder:data fromScheme:kAlipayAppKey callback:^(NSDictionary *resultDic) {
            //NSLog(@"reslut = %@",resultDic);
            if([[resultDic objectForKey:@"resultStatus"] isEqualToString:@"9000"]){
                NSRange foundObj=[[resultDic objectForKey:@"result"] rangeOfString:@"success=true" options:NSCaseInsensitiveSearch];
                if(foundObj.length>0) {
                    //[HMUtility alert:@"支付成功!" title:@"提示"];
                    //[self.delegate.navigationController popViewControllerAnimated:YES];
                    //[self goBack];
                }
            }
            
        }];
    }else if([type isEqualToString:@"3"]){
        NSDictionary *weiData = [[LCJsonUtil sharedInstance] dictionaryWithData:[data dataUsingEncoding: NSUTF8StringEncoding]];
        
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
        
    }else if([type isEqualToString:@"2"]){
        HMWebPay *ctrl = [[HMWebPay alloc] initWithNibName:nil bundle:nil];
        ctrl.type = 2;
        ctrl.payOrderSerial = data;
        [self.navigationController pushViewController:ctrl animated:YES];
    }else if([type isEqualToString:@"5"]){
        HMWebPay *ctrl = [[HMWebPay alloc] initWithNibName:nil bundle:nil];
        ctrl.type = 1;
        ctrl.payOrderSerial = data;
        [self.navigationController pushViewController:ctrl animated:YES];
    }
}


- (void)saveImage:(NSString*)imgUrl{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]];
    UIImage *image = [UIImage imageWithData:data];
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
}



- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    //self.navigationController.navigationBarHidden = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}   

@end


