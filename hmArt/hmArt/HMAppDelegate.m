//
//  HMAppDelegate.m
//  hmArt
//
//  Created by wangyong on 13-6-16.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import "HMAppDelegate.h"
#import "HMUtility.h"
#import "HMGlobal.h"
#import "LCGlobalDeviceInfo.h"
#import "AdvertiseView.h"
#import "XGPush.h"
#import "XGSetting.h"
#import <UserNotifications/UserNotifications.h>

//com.hmqqw.artexchange
#define NAVI_TEST_BUNDLE_ID @"com.hmqqw.artexchange"  //sdk自测bundle ID
#define NAVI_TEST_APP_KEY   @"igTqzZHB9ARxWqYq5Ca538bY4ATF7Roe"  //sdk自测APP KEY

@interface HMAppDelegate()
{
    NSNotificationCenter *notificationCenter;
}

@end

@implementation HMAppDelegate
@synthesize rootController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    _currentIndex = -1;
    [[NSBundle mainBundle] loadNibNamed:@"mainform" owner:self options:nil];
    self.window.backgroundColor = [UIColor whiteColor];
   
    [HMUtility readUserInfo];
    
    [LCGlobalDeviceInfo getDeviceInfo];

    [self genRandomString];
    [self autoLogin];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"home_bg.png"] forBarMetrics:UIBarMetricsDefault];
    if (IOS7) {
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
        NSDictionary *textAttr = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
        [[UINavigationBar appearance] setTitleTextAttributes:textAttr];
        
        [[UITabBar appearance] setTintColor:[UIColor redColor]];
        //[[UITabBar appearance] setBarTintColor:[UIColor redColor]];
    }
    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"tabbar_white_bg.png"]];

    [self setBarItemImage];
    [self.window addSubview:rootController.view];
    self.window.rootViewController = rootController;
    [self.window makeKeyAndVisible];
    
    _inBackground = NO;
    
    /** 信鸽推送初始化 ***/
    [[XGSetting getInstance] enableDebug:YES];
    [XGPush startApp:2200255844 appKey:@"I3RX48ER43JR"];
    
    [XGPush isPushOn:^(BOOL isPushOn) {
        NSLog(@"[XGDemo] Push Is %@", isPushOn ? @"ON" : @"OFF");
    }];
    
    [self registerAPNS];
    
    [XGPush handleLaunching:launchOptions successCallback:^{
        NSLog(@"[XGDemo] Handle launching success");
    } errorCallback:^{
        NSLog(@"[XGDemo] Handle launching error");
    }];
    
//    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)]) {
//        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
//        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
//        [[UIApplication sharedApplication] registerForRemoteNotifications];
//    }else{
//        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
//    }
    
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        [self dealRemoteUserInfo:userInfo isLaunch:YES];
    }

    //构造shareSDK
    [ShareSDK registerApp:kShareSDKKey];
    
    //添加微信好友/朋友圈
    [ShareSDK connectWeChatSessionWithAppId:kWeChatAppKey wechatCls:[WXApi class]];
    [ShareSDK connectWeChatTimelineWithAppId:kWeChatAppKey wechatCls:[WXApi class]];
    
    //添加新浪微博
//    [ShareSDK connectSinaWeiboWithAppKey:kSinaWeiboAppKey appSecret:kSinaWeiboAppSecret redirectUri:kSinaWeiboAppRedirectURI];
    //添加腾讯微博
    [ShareSDK connectTencentWeiboWithAppKey:kTencentWeiboAppKey
                                  appSecret:kTencentWeiboAppSecret
                                redirectUri:kTencentWeiboAppRedirectURI
                                   wbApiCls:[WeiboApi class]];
    
    //添加QQ空间应用  注册网址  http://connect.qq.com/intro/login/
    [ShareSDK connectQZoneWithAppKey:kQQZoneAppKey
                           appSecret:kQQZoneAppSecret
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];
    
    [ShareSDK connectQQWithQZoneAppKey:kQQZoneAppKey
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
    
    //添加短信
    [ShareSDK connectSMS];
    
    /** 微信支付注册 **/
    BOOL b = [WXApi registerApp:kWeChatAppKey withDescription:@"demo 2.0"];
    NSLog(@"bool:%i",b);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSearch:) name:@"HMShowSearchViewAtHome" object:nil];
    
    [LCGlobalDeviceInfo submitAppLaunch];
    
//    // 1.判断沙盒中是否存在广告图片，如果存在，直接显示
//    NSString *filePath = [self getFilePathWithImageName:[kUserDefaults valueForKey:adImageName]];
//    
//    BOOL isExist = [self isFileExistWithFilePath:filePath];
//    if (isExist) {// 图片存在
//        
//        AdvertiseView *advertiseView = [[AdvertiseView alloc] initWithFrame:self.window.bounds];
//        advertiseView.filePath = filePath;
//        [advertiseView show];
//        
//    }
//    
//    // 2.无论沙盒中是否存在广告图片，都需要重新调用广告接口，判断广告是否更新
//    [self getAdvertisingImage];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    _inBackground = YES;
    [application setApplicationIconBadgeNumber:[HMGlobalParams sharedInstance].newsCount];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HMShowSearchViewAtHome" object:nil];

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSearch:) name:@"HMShowSearchViewAtHome" object:nil];

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    _inBackground = NO;

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSString *dt = [NSString stringWithFormat:@"%@", deviceToken];
    NSString *token = [[[dt stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
    HMGlobalParams *gparam = [HMGlobalParams sharedInstance];
    gparam.deviceToken4Push = token;
    
    NSString *deviceTokenStr = [XGPush registerDevice:deviceToken account:gparam.mobile successCallback:^{
        NSLog(@"+++++++++++++++++++++++++++++++++++++++++++[XGDemo] register push success");
    } errorCallback:^{
        NSLog(@"+++++++++++++++++++++++++++++++++++++++++++[XGDemo] register push error");
    }];
    NSLog(@"+++++++++++++++++++++++++++++++++++++++++++[XGDemo] device token is %@", deviceTokenStr);
    
    [LCGlobalDeviceInfo submitDeviceToken4Push];
    
    
    
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSString *sErr = [NSString stringWithFormat:@"Error:%@", error.description];
     NSLog(@"err:%@", sErr);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self dealRemoteUserInfo:userInfo isLaunch:NO];
}

#pragma mark -
#pragma mark TableBarController Delegate Methods
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (tabBarController.selectedIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HMArtTabBarClickedAtIndexZero" object:nil];
    }else if (tabBarController.selectedIndex == 2){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HMArtTabBarClickedAtIndexSecond" object:nil];
    }else if (tabBarController.selectedIndex == 1){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HMArtTabBarClickedAtIndexFirst" object:nil];
    }
    // 如果是当前项，则忽略动画
    if (tabBarController.selectedIndex == _currentIndex) {
        return;
    } else {
        _currentIndex = tabBarController.selectedIndex;
    }
//    // 添加转换视图的动画效果
//    CATransition *ani = [CATransition animation];
//    [ani setDuration:0.3f];
//    [ani setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
//    [ani setType:kCATransitionMoveIn];
//    [ani setSubtype:kCATransitionFromTop];
//    //[ani setSubtype:kCATransitionFromRight];
//    [tabBarController.view.layer addAnimation:ani forKey:@"switch"];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    
    if ([viewController isKindOfClass:[UINavigationController class]]){
        
        UIViewController *ctrl = [viewController.childViewControllers objectAtIndex:0];
        if ([ctrl isKindOfClass:[HMUserCenter class]]) {
            NSInteger count = viewController.childViewControllers.count;
            if (count > 1 && _currentIndex == 3) {
                return ![HMGlobalParams sharedInstance].anonymous;
            }
        }else if ([ctrl isKindOfClass:[HMAuctionRecords class]]) {
            NSInteger count = viewController.childViewControllers.count;
            if (count > 1 && _currentIndex == 2) {
                return ![HMGlobalParams sharedInstance].anonymous;
            }
        }else if ([ctrl isKindOfClass:[HMStore class]]) {
            
            HMViewController *webVC = [HMViewController new];
            webVC.urlString = @"http://47.95.67.213/pitaya/api/authorize.htm";
            //webVC.urlString = @"http://39.106.100.222/pitaya/api/authorize.htm";
            //webVC.urlString = @"http://192.168.1.106:8090/pitaya/api/authorize.htm";
            
            UINavigationController *navController = (UINavigationController *)self.rootController.selectedViewController;
            UIViewController *ctrl =navController.topViewController;
            [ctrl.navigationController pushViewController:webVC animated:YES];
                
            return NO;
        }
    }
    return YES;
}

- (void)setBarItemImage
{
    NSInteger tag;
    for (UITabBarItem *bi in rootController.tabBar.items) {
        tag = bi.tag;
        NSString *fsi = [NSString stringWithFormat:@"tab_ico_%ldOn.png", (long)tag];
       // NSString *fusi = [NSString stringWithFormat:@"tab_ico_%ld.png", (long)tag];
        [bi setFinishedSelectedImage:[UIImage imageNamed:fsi] withFinishedUnselectedImage:nil];
    }
}

- (void)setBadgeValue:(NSString *)val toTag:(NSInteger)tag
{
    UITabBarItem *bi = [rootController.tabBar.items objectAtIndex:tag];
    bi.badgeValue = val;
}

- (void)showSearch:(NSNotification *)noticatication
{
    NSUInteger index = rootController.selectedIndex;
    if (index == 1) {
        UINavigationController *navController = (UINavigationController *)self.rootController.selectedViewController;
        UIViewController *ctrl =navController.topViewController;
        [ctrl.navigationController popToRootViewControllerAnimated:NO];
    }
}


#pragma mark -
#pragma mark auto login
- (void)autoLogin
{
    HMGlobalParams *params = [HMGlobalParams sharedInstance];
    if (params.mobile && params.password) {
        LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
        if (_requestLoginId != 0) {
            [net cancelRequest:_requestLoginId];
        }
        
        NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity:3];
        [queryParam setObject:params.mobile forKey:@"username"];
        [queryParam setObject:params.password forKey:@"password"];
        [queryParam setValue:[NSNumber numberWithInteger:0] forKey:@"type"];
        [queryParam setValue:params.serialNumber forKey:@"deviceId"];
        if (params.deviceToken4Push) {
            [queryParam setValue:params.deviceToken4Push forKey:@"deviceToken"];
        }
        _requestLoginId = [net asynRequest:interfaceUserLogin with:queryParam needSSL:NO target:self action:@selector(dealLogin:withResult:)];
    }else{
        params.anonymous = YES;
    }
}

- (void)dealLogin:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    _requestLoginId = 0;
    HMGlobalParams *params = [HMGlobalParams sharedInstance];
    if (result.result == HM_SYS_INTERFACE_SUCCESS) {
        NSDictionary *ret = [result.value objectForKey:@"obj"];
        params.anonymous = NO;
        params.mobile = [ret objectForKey:@"mobile"];
        params.loginToken = [ret objectForKey:@"loginToken"];
        params.name = [HMUtility getString:[ret objectForKey:@"name"]];
        params.sex = [[ret objectForKey:@"id"] integerValue];
        params.vip = [[ret objectForKey:@"vip"] integerValue];
        
        //数据存到手机上
        [HMUtility writeUserInfo];
        
    } else {
        params.anonymous = YES;
    }
    
}

#pragma mark -
#pragma mark apns
- (void)dealRemoteUserInfo:(NSDictionary *)userInfo isLaunch:(BOOL)launch
{
    //NSLog(@"%@", userInfo);
    NSDictionary *apns = [userInfo objectForKey:@"aps"];
//    NSDictionary *msg = [apns objectForKey:@"data"];
    NSNumber *badge = [apns objectForKey:@"badge"];
    NSInteger num;
    if (badge) {
        num = [badge integerValue];
    }else{
        num = 0;
    }
    [self dealNewsBadgeNumber:num];

    UINavigationController *navController = (UINavigationController *)self.rootController.selectedViewController;
    UIViewController *ctrl =navController.topViewController;
    if ([ctrl isKindOfClass:[HMPushMessages class]]) {
        [LCAlertView showWithTitle:nil message:[apns objectForKey:@"alert"] buttonTitle:@"确定"];
        if (!launch) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LCReceiveRemoteNotification" object:nil];
        }
    }else{
        HMPushMessages *push = [[HMPushMessages alloc] initWithNibName:nil bundle:nil];
        [ctrl.navigationController pushViewController:push animated:YES];
//        [LCAlertView showWithTitle:nil message:[apns objectForKey:@"alert"] cancelTitle:@"知道了" cancelBlock:nil otherTitle:@"去消息中心" otherBlock:^{
//            HMPushMessages *push = [[HMPushMessages alloc] initWithNibName:nil bundle:nil];
//            [ctrl.navigationController pushViewController:push animated:YES];
//        }];
    }

    
}

- (void)dealNewsBadgeNumber:(NSInteger)num
{
    HMGlobalParams *gparam = [HMGlobalParams sharedInstance];
    gparam.newsCount = num;
    if (gparam.newsCount > 0) {
        [self setBadgeValue:[NSString stringWithFormat:@"%ld", (long)gparam.newsCount] toTag:4];
        
    } else {
        [self setBadgeValue:nil toTag:4];
    }
}

#pragma mark -
#pragma mark share SDK微信腾讯微博分享
- (BOOL)application:(UIApplication *)application  handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    
    
    if ([url.host isEqualToString:@"safepay"]) {
        
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                standbyCallback:^(NSDictionary *resultDic) {
                    NSLog(@"result11 = %@",resultDic);
                    NSString *resultStr = resultDic[@"result"];
                                             
                }];
//        [[AlipaySDK defaultService] processAuth_V2Result:url
//                                         standbyCallback:^(NSDictionary *resultDic) {
//                                             NSLog(@"result = %@",resultDic);
//                                             NSString *resultStr = resultDic[@"result"];
//                                             
//                                         }];
        
    }
    
    
    NSString *scheme = [url scheme];
    if([scheme isEqualToString:@"hmqq-jsweb"]){
        NSString *httpUrl=[url absoluteString];
        HMJsViewController *web = [[HMJsViewController alloc] initWithNibName:nil bundle:nil];
//        httpUrl = [httpUrl stringByReplacingOccurrencesOfString:@"app.4008988518.com" withString:@"192.168.1.103:8080"];
        web.url = [httpUrl stringByReplacingOccurrencesOfString:@"hmqq-jsweb" withString: HM_SYS_SERVER_scheme];
        UINavigationController *navController = (UINavigationController *)self.rootController.selectedViewController;
        [navController pushViewController:web animated:YES];
        
    }else if([scheme isEqualToString:@"hmqq-mui"]){
        NSString *httpUrl=[url absoluteString];
        NSString *host = [url host];
        if([host isEqualToString:@"goBack"]){
            UINavigationController *navController = (UINavigationController *)self.rootController.selectedViewController;
            [navController popViewControllerAnimated:YES];
        }else{
            HMViewController *webVC = [HMViewController new];
            //webVC.urlString = @"http://47.95.67.213/pitaya/api/authorize.htm";
            webVC.urlString =[httpUrl stringByReplacingOccurrencesOfString:@"hmqq-mui" withString: HM_SYS_SERVER_scheme];
            UINavigationController *navController = (UINavigationController *)self.rootController.selectedViewController;
            [navController pushViewController:webVC animated:YES];
        }
        
    }if([scheme isEqualToString:@"hmqq-remote"]){
        NSString *httpUrl=[url absoluteString];
        
        WYWebController *web = [WYWebController new];
        NSString * str = [NSString stringWithFormat:@"%@://%@", HM_SYS_SERVER_scheme, HM_SYS_SERVER_URL];
        web.url = [httpUrl stringByReplacingOccurrencesOfString:@"hmqq-remote://" withString:str];
        UINavigationController *navController = (UINavigationController *)self.rootController.selectedViewController;
        [navController pushViewController:web animated:YES];
        
    }else if([scheme isEqualToString:@"hmqq-app"]){
        NSDictionary *classNames = [HMGlobalParams sharedInstance].classNames;
        NSString *localClass = [classNames objectForKey:[url host]];
        
        NSString *params = [url query];
        
        if(params){
            id controller = [[NSClassFromString(localClass) alloc] init];
            if (controller != nil) {
                if ([controller respondsToSelector:@selector(setParams:)]) {
                    [controller performSelector:@selector(setParams:) withObject:params];
                }
                UINavigationController *navController = (UINavigationController *)self.rootController.selectedViewController;
                navController.navigationBarHidden = NO;
                [navController pushViewController:controller animated:true];
            }
            
        }else{
            id controller = [[NSClassFromString(localClass) alloc] init];
            if (controller != nil) {
                UINavigationController *navController = (UINavigationController *)self.rootController.selectedViewController;
                navController.navigationBarHidden = NO;
                [navController pushViewController:controller animated:true];
            }

        }
        
        
        //return YES;
    }else{
        
    }
    
    
    
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}

-(void) onResp:(BaseResp*)resp
{
    //启动微信支付的response
    NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        switch (resp.errCode) {
            case 0:
                strMsg = @"支付成功！";
                break;
            case -1:
                strMsg = @"支付失败！";
                break;
            case -2:
                strMsg = @"您已退出支付！";
                break;
            default:
                strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
                break;
        }
        [HMUtility alert:strMsg title:@"提示"];
    }
    
}

- (void)genRandomString
{
    NSMutableString *nms = [[NSMutableString alloc] initWithCapacity:6];
    for (int i = 0; i < 6; i++) {
        int x = arc4random() % 10;
        [nms appendFormat:@"%d", x];
    }
    _gRandom = nms;
}

- (NSString *)getRandomString
{
    return _gRandom;
}



/**
 *  判断文件是否存在
 */
- (BOOL)isFileExistWithFilePath:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = FALSE;
    return [fileManager fileExistsAtPath:filePath isDirectory:&isDirectory];
}

/**
 *  初始化广告页面
 */
- (void)getAdvertisingImage
{
    
    // TODO 请求广告接口
    
    // 这里原本采用美团的广告接口，现在了一些固定的图片url代替
    NSArray *imageArray = @[@"http://imgsrc.baidu.com/forum/pic/item/9213b07eca80653846dc8fab97dda144ad348257.jpg", @"http://pic.paopaoche.net/up/2012-2/20122220201612322865.png", @"http://img5.pcpop.com/ArticleImages/picshow/0x0/20110801/2011080114495843125.jpg", @"http://www.mangowed.com/uploads/allimg/130410/1-130410215449417.jpg"];
    NSString *imageUrl = imageArray[arc4random() % imageArray.count];
    
    // 获取图片名:43-130P5122Z60-50.jpg
    NSArray *stringArr = [imageUrl componentsSeparatedByString:@"/"];
    NSString *imageName = stringArr.lastObject;
    
    // 拼接沙盒路径
    NSString *filePath = [self getFilePathWithImageName:imageName];
    BOOL isExist = [self isFileExistWithFilePath:filePath];
    if (!isExist){// 如果该图片不存在，则删除老图片，下载新图片
        
        [self downloadAdImageWithUrl:imageUrl imageName:imageName];
        
    }
    
}

/**
 *  下载新图片
 */
- (void)downloadAdImageWithUrl:(NSString *)imageUrl imageName:(NSString *)imageName
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        UIImage *image = [UIImage imageWithData:data];
        
        NSString *filePath = [self getFilePathWithImageName:imageName]; // 保存文件的名称
        
        if ([UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES]) {// 保存成功
            NSLog(@"保存成功");
            [self deleteOldImage];
            [kUserDefaults setValue:imageName forKey:adImageName];
            [kUserDefaults synchronize];
            // 如果有广告链接，将广告链接也保存下来
        }else{
            NSLog(@"保存失败");
        }
        
    });
}

/**
 *  删除旧图片
 */
- (void)deleteOldImage
{
    NSString *imageName = [kUserDefaults valueForKey:adImageName];
    if (imageName) {
        NSString *filePath = [self getFilePathWithImageName:imageName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:filePath error:nil];
    }
}

/**
 *  根据图片名拼接文件路径
 */
- (NSString *)getFilePathWithImageName:(NSString *)imageName
{
    if (imageName) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:imageName];
        
        return filePath;
    }
    
    return nil;
}


/***
 * 信鸽注册
 */
- (void)registerAPNS {
    float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    if (sysVer >= 10) {
        // iOS 10
        [self registerPush10];
    } else if (sysVer >= 8) {
        // iOS 8-9
        [self registerPush8to9];
    } else {
        // before iOS 8
        [self registerPushBefore8];
    }
#else
    if (sysVer < 8) {
        // before iOS 8
        [self registerPushBefore8];
    } else {
        // iOS 8-9
        [self registerPush8to9];
    }
#endif
}

- (void)registerPush10{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    
    
    [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
        }
    }];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
}

- (void)registerPush8to9{
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)registerPushBefore8{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

@end
