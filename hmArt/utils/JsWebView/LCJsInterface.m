//
//  LCJsInterface.m
//  lifeassistant
//
//  Created by 刘学 on 14-11-14.
//
//

#import "LCJsInterface.h"
#import "LCDESCoder.h"
#import "HMUtility.h"
#import <CoreLocation/CoreLocation.h>


@interface LCJsInterface ()<CLLocationManagerDelegate>
{
    CLLocationManager * _locationmanager;
    NSString * _locationCallback;
}
@end

@implementation LCJsInterface

@synthesize jsWebView;

- (void) test{
	NSLog(@"test called");
}

/**
 *检查登录接口
 **/
-(NSString*) check:(NSString*) require Login:(NSString*) callback{
    NSString *result = @"{result:\"1\",message:\"\"}";
    
    BOOL anonymous = [HMGlobalParams sharedInstance].anonymous;
    EasyJSDataFunction* func = nil;
    if (callback) {
        func = [[EasyJSDataFunction alloc] initWithWebView:self.jsWebView];
        func.funcID = callback;
    }
    if ([require isEqualToString:@"0"]) {
        
    }else if ([require isEqualToString:@"1"]) {
        if (anonymous) {
            [self.delegate login:func];
            return result;
        }
    }else if ([require isEqualToString:@"2"]) {
        [self.delegate login:func];
        return result;
    }
    
    if(func){
        NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity: 7];
        [ret setValue:@"1" forKey:@"result"];
        [ret setValue:@"" forKey:@"message"];
        
        if (anonymous) {
            [ret setValue:@"0" forKey:@"loginStatus"];
        }else{
            [ret setValue:@"1" forKey:@"loginStatus"];
            HMGlobalParams *gParams = [HMGlobalParams sharedInstance];
            if(gParams.loginToken) [ret setValue:gParams.loginToken forKey:@"loginToken"];
            [ret setValue:gParams.name forKey:@"name"];
            [ret setValue:gParams.mobile forKey:@"mobile"];
            [ret setValue:[NSNumber numberWithInteger:gParams.vip] forKey:@"vip"];
        }
        [func executeWithParam:[ret JSONString]];
    }
    return result;
}

/**
 *注销登录
 **/
-(NSString*) sign:(NSString*) backurl out:(NSString*) callback{
    NSString *result = @"{result:\"1\",message:\"\"}";
    
    HMGlobalParams *params = [HMGlobalParams sharedInstance];
    params.anonymous = YES;
    params.mobile = nil;
    params.password = nil;
    params.loginToken = nil;
    
    [HMUtility resetUserInfo];
    
    if (callback) {
        EasyJSDataFunction* func = [[EasyJSDataFunction alloc] initWithWebView:self.jsWebView];
        func.funcID = callback;
        NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity: 7];
        [ret setValue:@"1" forKey:@"result"];
        [ret setValue:@"" forKey:@"message"];
        [func executeWithParam:[ret JSONString]];
    }
    return result;
}

/**
 *客户端信息
 **/
-(NSString*) getAppInfo:(NSString*) callback{
    NSString *result = @"{result:\"1\",message:\"\"}";
    if (callback) {
        EasyJSDataFunction* func = [[EasyJSDataFunction alloc] initWithWebView:self.jsWebView];
        func.funcID = callback;
        NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity: 7];
        [ret setValue:@"1" forKey:@"result"];
        [ret setValue:@"" forKey:@"message"];
        [ret setValue:@"0" forKey:@"osType"];
        NSDictionary *dictAppInfo = [[NSBundle mainBundle] infoDictionary];
        NSString *appVer = [NSString stringWithFormat:@"%@", [dictAppInfo objectForKey:@"CFBundleShortVersionString"]];
        
        [ret setValue:appVer forKey:@"version"];
        [func executeWithParam:[ret JSONString]];
    }
    
    
    
    return result;
}

/**
 *手机信息
 **/
-(NSString*) getHardwareInfo:(NSString*) callback
{
    NSString *result = @"{result:\"1\",message:\"\"}";
    if (callback) {
        EasyJSDataFunction* func = [[EasyJSDataFunction alloc] initWithWebView:self.jsWebView];
        func.funcID = callback;
        NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity: 7];
        [ret setValue:@"1" forKey:@"result"];
        [ret setValue:@"" forKey:@"message"];
        [ret setValue:[HMGlobalParams sharedInstance].vendorName forKey:@"vendor"];
        [ret setValue:[HMGlobalParams sharedInstance].serialNumber forKey:@"deviceId"];
        [ret setValue:[HMGlobalParams sharedInstance].model forKey:@"model"];
        [ret setValue:[HMGlobalParams sharedInstance].osVersion forKey:@"osVersion"];
        [ret setValue:[HMGlobalParams sharedInstance].osName forKey:@"osName"];
        [func executeWithParam:[ret JSONString]];
    }
    return result;
}


/**
 *隐藏底部状态条
 **/
-(void) hideCtrlBar:(NSString*) hide
{
    [self.delegate hideTabBar:hide];
}

/**
 *设置APP头部颜色
 **/
- (NSString *)setPageColor:(NSString *)color
{
    NSString *result = @"{result:\"1\",message:\"\"}";
    if (color && color.length > 0) {
        NSArray *ca = [color componentsSeparatedByString:@","];
        if (ca.count == 3) {
            NSString *sRed = [ca objectAtIndex:0];
            NSString *sGreen = [ca objectAtIndex:1];
            NSString *sBlue = [ca objectAtIndex:2];
            [self.delegate setHeaderColorRed:sRed.floatValue green:sGreen.floatValue blue:sBlue.floatValue];
        }
    }
    return result;
}

/**
 *设置APP标题
 **/
- (NSString *)setPageTitle:(NSString *)title{
    NSString *result = @"{result:\"1\",message:\"\"}";
    if (title && title.length > 0) {
        [self.delegate setHeaderTitle:title];
    }
    return result;
}


/**
 *摇一摇事件监测
 **/
- (NSString *)shake:(NSString *)callback
{
    NSString *result = @"{result:\"1\",message:\"\"}";
    if (callback) {
        EasyJSDataFunction* func = [[EasyJSDataFunction alloc] initWithWebView:self.jsWebView];
        func.funcID = callback;
        [self.delegate shakeMotion:func];
    }
    return result;
}

/**
 *手机位置信息
 **/
- (NSString *)myLocation:(NSString *)callback
{
//    [self.delegate location:callback];
    
//    if ([CLLocationManager locationServicesEnabled]) {
//        _locationmanager = [[CLLocationManager alloc]init];
//        _locationmanager.delegate = self;
//        [_locationmanager requestAlwaysAuthorization];
//        [_locationmanager requestWhenInUseAuthorization];
//
//        //设置寻址精度
//        _locationmanager.desiredAccuracy = kCLLocationAccuracyBest;
//        _locationmanager.distanceFilter = 5.0;
//        [_locationmanager startUpdatingLocation];
//
//        _locationCallback = callback;
//
//    }else{
//        //提示用户 打开定位
//
//
//    }

    NSString *result = @"{result:\"1\",message:\"\"}";
    
    return result;
}

/**
 *开启二维码扫描
 **/
//- (NSString *)qrcodeScan:(NSString *)callback
//{
//    NSString *result = @"{result:\"1\",message:\"\"}";
//    if (callback) {
//        EasyJSDataFunction* func = [[EasyJSDataFunction alloc] initWithWebView:self.jsWebView];
//        func.funcID = callback;
//        [self.delegate scanQrcode:func];
//    }
//    return result;
//}

/**
 *发送短信
 **/
-(NSString*)send:(NSString*)content Sms:(NSString *)mobile
{
    NSString *result = @"{result:\"1\",message:\"\"}";
    [self.delegate sendSms:content toMobile:mobile];
    return result;
}


/**
 *呼叫
 **/
- (NSString *)phone:(NSString *)title Call:(NSString *)service By:(NSString *)phone App:(NSString *)show
{
    NSString *result = @"{result:\"1\",message:\"\"}";
    if (phone && phone.length > 0) {
        BOOL showPhone = NO;
        if ([show isEqualToString:@"1"]) {
            showPhone = YES;
        }
        NSString *tips = title.length > 0 ? title : @"致电";
        NSString *serviceName = service.length > 0 ? service : @"首页";
        [self.delegate call:phone serviceName:serviceName tips:tips showNumber:showPhone];
    }
    return result;
}

/**
 *使用外部浏览器打开指定网址
 **/
- (NSString *)openUrl:(NSString *)url
{
    NSString *result = @"{result:\"1\",message:\"\"}";
    [self.delegate openUrl:url inAPP:NO];
    return result;
}

- (NSString *)openUrlInApp:(NSString *)url
{
    NSString *result = @"{result:\"1\",message:\"\"}";
    [self.delegate openUrl:url inAPP:YES];
    return result;
    
}

/**
 *加密json字符串
 **/
- (NSString *)encrypt:(NSString *)json Params:(NSString *)callback
{
    NSData *jsonData;
    if (json && json.length > 0) {
        jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    }else{
        NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithCapacity:1];
        NSError *error = nil;
        jsonData = [NSJSONSerialization dataWithJSONObject:param options:0 error:&error];
//        jsonData = [[LCJsonUtil sharedInstance] dataWithJSONObject:param];
    }
    NSString *desStr = [LCDESCoder h5Base64StringFromText:jsonData];
    NSLog(@"json:%@", json);
    NSLog(@"des str:%@", desStr);
    if (callback) {
        EasyJSDataFunction* func = [[EasyJSDataFunction alloc] initWithWebView:self.jsWebView];
        func.funcID = callback;
        NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity: 2];
        [ret setValue:@"1" forKey:@"result"];
        [ret setValue:@"" forKey:@"message"];
        [ret setValue:desStr forKey:@"desStr"];
         NSMutableDictionary *headers = [[NSMutableDictionary alloc] initWithCapacity: 2];
        [headers setValue:@"H5001" forKey:@"reqId"];
        [headers setValue:@"01" forKey:@"reqVersion"];
        [headers setValue:[HMGlobalParams sharedInstance].mobile forKey:@"mobile"];
        [ret setValue:headers forKey:@"headers"];
        [func executeWithParam:[ret JSONString]];
    }
    NSString *result = @"{result:\"1\",message:\"\"}" ;
    return result;
}

/**
 *APP分享
 **/
- (NSString *)fenxiangTitle:(NSString *)title Content:(NSString *)content ImageUrl:(NSString *)image SiteUrl:(NSString *)url
{
    NSString *result = @"{result:\"1\",message:\"\"}";
    [self.delegate fenxiangTitle:title Content:content ImageUrl:image SiteUrl:url];
    return result;
}

- (NSString *)fenxiangTitle:(NSString *)title Content:(NSString *)content ImageUrl:(NSString *)image SiteUrl:(NSString *)url Type:(NSString *) type Id:(NSString *)id{
    NSString *result = @"{result:\"1\",message:\"\"}";
    [self.delegate fenxiangTitle:title Content:content ImageUrl:image SiteUrl:url];
    return result;
}


/**
 *返回上一页
 */
- (void)goBack
{
    [self.delegate goBack];
}

- (void)popToRootView
{
    [self.delegate popToRootView];
}
/**
 *支付
 */
- (void)toPay:(NSString*)type Data:(NSString*)data
{
    [self.delegate toPay:type Data:data];
}

/**
 *验证是否支持某函数
 **/
- (NSString *)canPerform:(NSString *)funcName Callback:(NSString *)callback
{
    BOOL match = NO;
    if ([funcName isEqualToString:@"hideCtrlBar"]) {
        match = YES;
    }else if ([funcName isEqualToString:@"setPageTitle"]) {
        match = YES;
    }else if ([funcName isEqualToString:@"getLocation"]) {
        match = NO;
    }else  if ([funcName isEqualToString:@"getHardwareInfo"]) {
        match = YES;
    }else if ([funcName isEqualToString:@"getAppInfo"]) {
        match = YES;
    }else if ([funcName isEqualToString:@"signout"]) {
        match = YES;
    }else if ([funcName isEqualToString:@"sendSms"]) {
        match = YES;
    }else if ([funcName isEqualToString:@"qrcodeScan"]) {
        match = NO;
    }else if ([funcName isEqualToString:@"shake"]) {
        match = YES;
    }else if ([funcName isEqualToString:@"openUrl"]) {
        match = YES;
    }else if ([funcName isEqualToString:@"setPageColor"]) {
        match = YES;
    }else if ([funcName isEqualToString:@"phoneCallByApp"]) {
        match = YES;
    }else if ([funcName isEqualToString:@"encryptParams"]) {
        match = YES;
    }
    NSString *result = match ? @"{result:\"1\",message:\"\"}" : @"{result:\"0\",message:\"\"}";
    if (callback) {
        EasyJSDataFunction* func = [[EasyJSDataFunction alloc] initWithWebView:self.jsWebView];
        func.funcID = callback;
        NSString *retMatch = match ? @"1" : @"0";
        NSString *message = match ? @"" : @"不支持此函数，请升级最新版本";
        NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity: 2];
        [ret setValue:retMatch forKey:@"result"];
        [ret setValue:message forKey:@"message"];
        [func executeWithParam:[ret JSONString]];
    }
    
    return result;
    
}

- (void)start:(NSString *)log N:(NSString *)lat a:(NSString *)log0 vi:(NSString *)lat0;
{
    [self.delegate start:log Navi:lat];
}

- (void)save:(NSString*)imgUrl Image:(NSString *)callback{
    [self.delegate saveImage:imgUrl];
    
    if (callback) {
        EasyJSDataFunction* func = [[EasyJSDataFunction alloc] initWithWebView:self.jsWebView];
        func.funcID = callback;
        [func executeWithParam:@"true"];
    }
}
//#pragma MARK CLLocationManagerDelegate Methods
//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
//
//    CLLocation *currLocation = [locations lastObject];
//    NSLog(@"经度=%f 纬度=%f 高度=%f", currLocation.coordinate.latitude, currLocation.coordinate.longitude, currLocation.altitude);
//
//    if (_locationCallback) {
//        EasyJSDataFunction* func = [[EasyJSDataFunction alloc] initWithWebView:self.jsWebView];
//        func.funcID = _locationCallback;
//
//        NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity: 2];
//        [ret setValue:@"1" forKey:@"result"];
//        [ret setValue:@"" forKey:@"message"];
//        [ret setValue:@(currLocation.coordinate.longitude) forKey:@"longitude"];
//        [ret setValue:@(currLocation.coordinate.latitude) forKey:@"latitude"];
//
//        [func executeWithParam:[ret JSONString]];
//    }
//}
//- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//    //定位失败 查看原因
//}
@end
