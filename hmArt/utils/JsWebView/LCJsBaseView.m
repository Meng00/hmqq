//
//  LCJsBaseView.m
//  vip
//
//  Created by wangyong on 15/9/16.
//  Copyright (c) 2015年 Beijing Unicom. All rights reserved.
//

#import "LCJsBaseView.h"
#import "NSString+URL.h"

@interface LCJsBaseView ()

@end

@implementation LCJsBaseView

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect rectView = self.view.bounds;
    NSLog(@"y1= %f",rectView.origin.y);

//    topView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, rectView.size.width, 60)];
//    [topView setPaddingTop:20 paddingBottom:5 paddingLeft:5 paddingRight:5];
//    topView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:topView];
//    
//    //UIImageView *back = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
//    
//    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
//    back.frame = CGRectMake(0, 0, 20, 20);
//    back.tag = 1001;
//    [back setBackgroundImage:[UIImage imageNamed:@"right_arrow.png"] forState:UIControlStateNormal];
//    back.userInteractionEnabled = YES;
//    [back addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagPayment:)]];
//    [topView addCustomSubview:back intervalLeft:0];
//    
//    [topView resize];
    
    // 左侧返回按钮，便于处理定时器
    UIBarButtonItem *backButton =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back.png"] style:UIBarButtonItemStyleDone target:self action:@selector(backButtonDown:)];
    backButton.style = UIBarButtonItemStyleDone;
    self.navigationItem.leftBarButtonItem = backButton;
    
    
    _agentWeb = [[EasyJSWebView alloc] initWithFrame:CGRectMake(0, rectView.origin.y, rectView.size.width, rectView.size.height)];
    _agentWeb.delegate = self;
    _agentWeb.opaque = NO;
    [_agentWeb setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"view_bg.png"]]];
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

    CGRect agentFrame = _agentWeb.frame;
    CGRect rectView = self.view.bounds;
    NSLog(@"y= %f",rectView.origin.y);
    if(rectView.origin.y == 0){
        if(self.navigationController.navigationBarHidden == NO){
            agentFrame.origin.y = 64;
        }else{
            agentFrame.origin.y = 0;
        }
        if(self.tabBarController.tabBar.hidden == NO){
            agentFrame.size.height = rectView.size.height - agentFrame.origin.y;
        }else{
            agentFrame.size.height = rectView.size.height - agentFrame.origin.y;
        }

    }else{
        agentFrame = rectView;
    }
    _agentWeb.frame = agentFrame;
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
    NSString *sUrl;
    NSRange searchResult = [_webUrl rangeOfString:@"?"];
    if (searchResult.location == NSNotFound) {
        sUrl = [NSString stringWithFormat:@"%@?random=%f", [_webUrl URLEncodedString], [[NSDate date] timeIntervalSinceNow]];
    }else{
        sUrl = [NSString stringWithFormat:@"%@&random=%f", [_webUrl URLEncodedString], [[NSDate date] timeIntervalSinceNow]];
    }
    
    NSString *encodedString=[sUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *reqUrl = [NSURL URLWithString:encodedString];
    [_agentWeb loadRequest:[NSURLRequest requestWithURL:reqUrl]];
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
//    if (_agentWeb == nil) {
//        _agentWeb = webView;
//        [self dealUserAgent];
//    }
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
        NSString *selfAgent = [_agentWeb stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        NSDictionary *dictAppInfo = [[NSBundle mainBundle] infoDictionary];
        NSString *appVerNum = [dictAppInfo objectForKey:@"CFBundleShortVersionString"];
        NSString *newAgent = [NSString stringWithFormat:@"%@ bju-uservice/%@", selfAgent, appVerNum];
        //        NSLog(@"user agent:%@", newAgent);
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
        [HMGlobalParams sharedInstance].appendUserAgentSuffix = YES;
    }
}
//- (void)query
//{
//    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
//    
//    if (_requestWebAppId != 0) {
//        [net cancelRequest:_requestWebAppId];
//    }
//    
//    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 1];
//    
//#ifndef APPTEST
//    [queryParam setObject:_appEntrance forKey:@"code"];
//#else
//    [queryParam setObject:[NSString stringWithFormat:@"%@%@", _appEntrance, APPTEST] forKey:@"code"];
//#endif
//    
//    _requestWebAppId = [net asynRequest:@"" with:queryParam needSSL:NO target:self action:@selector(dealAppInfo:result:)];
//}

//- (void)dealAppInfo:(NSString *)serviceName result:(LCInterfaceResult *)result
//{
//    _requestWebAppId = 0;
//    
//    NSDictionary *ret = result.value;
//    id appInfo = [ret objectForKey:@"obj"];
//    if (appInfo && [appInfo isKindOfClass:[NSDictionary class]]){
//        self.title = [appInfo objectForKey:@"appName"];
//        
//        NSString *sUrl = [appInfo objectForKey:@"appUrl"];
//        if (_urlParams && _urlParams.length > 0) {
//            NSRange searchResult = [sUrl rangeOfString:@"?"];
//            if (searchResult.location == NSNotFound) {
//                _webUrl = [NSString stringWithFormat:@"%@?%@", [sUrl URLEncodedString], [_urlParams URLEncodedString]];
//            }else{
//                _webUrl = [NSString stringWithFormat:@"%@&%@", [sUrl URLEncodedString], [_urlParams URLEncodedString]];
//            }
//        }else{
//            _webUrl = [sUrl URLEncodedString];
//        }
//        
//        
//         [self loadHomePage];
//        
//    }else{
//        [LCAlertView showWithTitle:nil message:@"页面地址下载失败" buttonTitle:@"确定"];
//    }    
//}


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
-(void) hideTabBar{
    [self makeTabBarHidden:YES];
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
    if ( [self.tabBarController.view.subviews count] < 2 )
    {
        return;
    }
    UIView *contentView;
    
    if ( [[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]] )
    {
        contentView = [self.tabBarController.view.subviews objectAtIndex:1];
    }
    else
    {
        contentView = [self.tabBarController.view.subviews objectAtIndex:0];
    }
    //    [UIView beginAnimations:@"TabbarHide" context:nil];
    if ( hide )
    {
        contentView.frame = self.tabBarController.view.bounds;
    }
    else
    {
        contentView.frame = CGRectMake(self.tabBarController.view.bounds.origin.x,
                                       self.tabBarController.view.bounds.origin.y,
                                       self.tabBarController.view.bounds.size.width,
                                       self.tabBarController.view.bounds.size.height - self.tabBarController.tabBar.frame.size.height);
    }
    CGRect rect = _agentWeb.frame;
    CGFloat offset = hide ? 44 : 93;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - offset;
    _agentWeb.frame = rect;
    
    _tabBarHidden = hide;
    self.tabBarController.tabBar.hidden = hide;
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
        self.navigationController.navigationBarHidden = YES;
    }else{
        [LCAlertView showWithTitle:@"提示" message:@"该设备不支持短信功能！" buttonTitle:@"确定"];
    }
}

/**
 *APP分享
 **/
- (void)fenxiang:(NSString *)content Image:(NSString *)image Url:(NSString *)url
{
    //[self enableKeyboardObserve:NO];
    
//    id<ISSContent> publishContent = [ShareSDK content:content
//                                       defaultContent:content
//                                                image:[ShareSDK imageWithUrl:image]
//                                                title:content
//                                                  url:url
//                                          description:content
//                                            mediaType:SSPublishContentMediaTypeNews];
//    
//    [ShareSDK showShareActionSheet:nil shareList:nil content:publishContent statusBarTips:YES authOptions:nil shareOptions:nil result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end){
//        //[self enableKeyboardObserve:YES];
//        if (state == SSResponseStateSuccess) {
//            [LCAlertView showWithTitle:nil message:@"分享成功！" buttonTitle:@"确认"];
//        }
//        else if (state == SSResponseStateFail){
//            
//            [LCAlertView showWithTitle:@"分享失败" message:[NSString stringWithFormat:@"错误码:%ld, 错误描述:%@", (long)[error errorCode], [error errorDescription]] buttonTitle:@"确认"];
//        }
//    }
//     ];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    self.navigationController.navigationBarHidden = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark qrcode scan
-(void) scanQrcode:(EasyJSDataFunction*) func
{
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        if ([[AVCaptureDevice class] respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
//            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//            if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
//                [LCAlertView showWithTitle:nil message:@"未获得摄像头使用授权，请修改隐私设置" buttonTitle:@"确认"];
//                return;
//            }
//        }
//    }else{
//        [LCAlertView showWithTitle:nil message:@"该设备不支持摄像头" buttonTitle:@"确认"];
//        return;
//    }
//    
//    _scanQrcodeFunc = func;
//    [HMUtility showTip:@"打开二维码识别器" inView:self.view];
//    
//    ZBarReaderViewController *reader = [ZBarReaderViewController new];
//    reader.readerDelegate = self;
//    
//    ZBarImageScanner *scanner = reader.scanner;
//    
//    // EXAMPLE: disable rarely used I2/5 to improve performance
//    [scanner setSymbology: ZBAR_I25
//                   config: ZBAR_CFG_ENABLE
//                       to: 0];
//    
//    // present and release the controller
//    [self presentViewController:reader animated:YES completion:nil];
}

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    id<NSFastEnumeration> results =
//    [info objectForKey: ZBarReaderControllerResults];
//    ZBarSymbol *symbol = nil;
//    for(symbol in results)
//        // EXAMPLE: just grab the first barcode
//        break;
//    
//    [picker dismissViewControllerAnimated:YES completion:nil];
//    if (_scanQrcodeFunc) {
//        NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity: 7];
//        [ret setValue:@"1" forKey:@"result"];
//        [ret setValue:@"success" forKey:@"message"];
//        [ret setValue:symbol.data forKey:@"qrcode"];
//        [_scanQrcodeFunc executeWithParam:[ret JSONString]];
//    }
//}

#pragma mark -
#pragma mark Baidu Map Location method
//-(void) locate:(NSNumber *)reverseGeo func:(EasyJSDataFunction *)func
//{
//    BOOL reverse = NO;
//    if (reverseGeo && (reverseGeo.integerValue == 1)) {
//        reverse = YES;
//    }
//    _locService = [LCMapLocate sharedInstance];
//    _locService.delegate = self;
//    _locService.needReverse = reverse;
//    _locateFunc = func;
//    [_locService startLocate];
//}

//- (void)didUpdateLocation:(LCMapLocationResult *)result
//{
//    [_locService stopLocate];
//    _locService.delegate = nil;
//    if (_locateFunc) {
//        NSInteger locResult = result.result;
//        NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity: 7];
//        if (locResult == 0) {
//            [ret setValue:@"1" forKey:@"result"];
//            [ret setValue:@"定位成功" forKey:@"message"];
//            [ret setValue:[NSNumber numberWithDouble:result.pt.longitude] forKey:@"longitude"];
//            [ret setValue:[NSNumber numberWithDouble:result.pt.latitude] forKey:@"latitude"];
//            [ret setValue:result.city forKey:@"city"];
//            [ret setValue:result.address forKey:@"address"];
//        }else{
//            if (locResult == 1) {//未开启定位
//                [ret setValue:@"0" forKey:@"result"];
//            }else if (locResult == 2){//反向定位失败
//                [ret setValue:@"-2" forKey:@"result"];
//                [ret setValue:[NSNumber numberWithDouble:result.pt.longitude] forKey:@"longitude"];
//                [ret setValue:[NSNumber numberWithDouble:result.pt.latitude] forKey:@"latitude"];
//            }else{
//                [ret setValue:@"-1" forKey:@"result"];
//            }
//            [ret setValue:@"" forKey:@"city"];
//            [ret setValue:@"" forKey:@"address"];
//            [ret setValue:result.errMessage forKey:@"message"];
//        }
//        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:_locateFunc, @"func", [ret JSONString], @"param", nil];
//        [self performSelector:@selector(locateNotify:) withObject:userInfo afterDelay:0.2f];
//    }
//}
//
//- (void)locateNotify:(NSDictionary *)userInfo
//{
//    EasyJSDataFunction *func = (EasyJSDataFunction *)[userInfo objectForKey:@"func"];
//    [func executeWithParam:[userInfo objectForKey:@"param"]];
//}


@end

