//
//  LCGlobalDeviceInfo.m
//  uni114
//
//  Created by wangyong on 13-1-24.
//
//

#import "LCGlobalDeviceInfo.h"
#import "HMGlobalParams.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import "LCNetworkInterface.h"
#import "HMUtility.h"
#import "KeychainItemWrapper.h"

struct CTServerConnection *sc=NULL;
struct CTResult result;
void callback(){}
extern NSString* CTSettingCopyMyPhoneNumber();

@implementation LCGlobalDeviceInfo

+ (void)getDeviceInfo
{
    HMGlobalParams *single = [HMGlobalParams sharedInstance];
    single.osName = [[UIDevice currentDevice] systemName];
    single.osVersion = [[UIDevice currentDevice] systemVersion];
    NSDictionary *dictAppInfo = [[NSBundle mainBundle] infoDictionary];
    single.appVersion = [dictAppInfo objectForKey:@"CFBundleShortVersionString"];

    
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc]
                                         initWithIdentifier:@"BjUnicom114LifeAssistantUUID"
                                         accessGroup:nil];
    NSString *strUUID = [keychainItem objectForKey:(__bridge id)kSecValueData];
    if ([strUUID isEqualToString:@""])
    {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
        CFRelease(uuidRef);
        [keychainItem setObject:@"com.114menhu.lifeassistant" forKey:(__bridge id)(kSecAttrAccount)];
        [keychainItem setObject:strUUID forKey:(__bridge id)kSecValueData];
    }
    single.serialNumber = strUUID;
    
    single.vendorName = @"Apple";
    single.scale = [NSNumber numberWithFloat:[[UIScreen mainScreen] scale]];
    single.screenHeight = [NSNumber numberWithFloat: ([[UIScreen mainScreen] bounds].size.height * [[UIScreen mainScreen] scale])];
    single.screenWidth = [NSNumber numberWithFloat: ([[UIScreen mainScreen] bounds].size.width * [[UIScreen mainScreen] scale])];
    single.screen = [NSString stringWithFormat:@"%@*%@", single.screenWidth, single.screenHeight];
    //single.model = [[UIDevice currentDevice] model];
    
    CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = netInfo.subscriberCellularProvider;
    
    single.carrier = carrier.carrierName;
    
    
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    single.model = platform;
    
    
}
/*
//广告
+ (void)submitDeviceInfoForAd:(NSString *)serviceName withType:(NSString *)serviceType
{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    HMGlobalParams *gParams = [HMGlobalParams sharedInstance];
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 11];
    [queryParam setObject:gParams.screenWidth  forKey:@"screenSizeWidth"];
    [queryParam setObject:gParams.screenHeight  forKey:@"screenSizeHeight"];
    [queryParam setObject:serviceName  forKey:@"businessName"];
    [queryParam setObject:serviceType  forKey:@"businessType"];
    if (gParams.carrier) {
        [queryParam setObject:gParams.carrier  forKey:@"operators"];
    }
    if (gParams.model) {
        [queryParam setObject:gParams.model  forKey:@"model"];
    }
    [queryParam setObject:gParams.osName  forKey:@"system"];
    [queryParam setObject:gParams.osVersion  forKey:@"systemVer"];
    [queryParam setObject:gParams.vendorName  forKey:@"manufacturers"];
    [queryParam setObject:gParams.serialNumber  forKey:@"deviceID"];
    if (!gParams.anonymous) {
        [queryParam setObject:gParams.mobile  forKey:@"userMobile"];
    } else {
        [queryParam setObject:@""  forKey:@"username"];
        [queryParam setObject:@""  forKey:@"userMobile"];
    }
    
    [queryParam setObject:@"" forKey:@"calledPhone"];
    //增加客户端版本号
    [queryParam setObject:gParams.appVersion forKey:@"clientVersion"];
//    [net asynRequest:interfaceClientVisitRecord with:queryParam needSSL:NO target:nil action:nil];
}
//业务
+ (void)submitDeviceInfo:(NSString *)serviceName withType:(NSString *)serviceType
{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    HMGlobalParams *gParams = [HMGlobalParams sharedInstance];
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 11];
    [queryParam setObject:gParams.screenWidth  forKey:@"screenSizeWidth"];
    [queryParam setObject:gParams.screenHeight  forKey:@"screenSizeHeight"];
    [queryParam setObject:serviceName  forKey:@"businessName"];
    [queryParam setObject:serviceType  forKey:@"businessType"];
    if (gParams.carrier) {
        [queryParam setObject:gParams.carrier  forKey:@"operators"];
    }
    if (gParams.model) {
        [queryParam setObject:gParams.model  forKey:@"model"];
    }
    [queryParam setObject:gParams.osName  forKey:@"system"];
    [queryParam setObject:gParams.osVersion  forKey:@"systemVer"];
    [queryParam setObject:gParams.vendorName  forKey:@"manufacturers"];
    [queryParam setObject:gParams.serialNumber  forKey:@"deviceID"];
    if (!gParams.anonymous) {
        [queryParam setObject:gParams.mobile  forKey:@"userMobile"];
    } else {
        [queryParam setObject:@""  forKey:@"username"];
        [queryParam setObject:@""  forKey:@"userMobile"];
    }
    
    [queryParam setObject:@"" forKey:@"calledPhone"];
    //增加客户端版本号
    [queryParam setObject:gParams.appVersion forKey:@"clientVersion"];
//    [net asynRequest:interfaceClientVisitRecord with:queryParam needSSL:NO target:nil action:nil];
}
+ (void)submitPhoneCallLog:(NSString *)serviceName withType:(NSString *)serviceType phoneNumber:(NSString *)phone
{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    HMGlobalParams *gParams = [HMGlobalParams sharedInstance];
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 11];
    [queryParam setObject:gParams.screenWidth  forKey:@"screenSizeWidth"];
    [queryParam setObject:gParams.screenHeight  forKey:@"screenSizeHeight"];
    [queryParam setObject:serviceName  forKey:@"businessName"];
    [queryParam setObject:serviceType  forKey:@"businessType"];
    if (gParams.carrier) {
        [queryParam setObject:gParams.carrier  forKey:@"operators"];
    }
    if (gParams.model) {
        [queryParam setObject:gParams.model  forKey:@"model"];
    }
    [queryParam setObject:gParams.osName  forKey:@"system"];
    [queryParam setObject:gParams.osVersion  forKey:@"systemVer"];
    [queryParam setObject:gParams.vendorName  forKey:@"manufacturers"];
    [queryParam setObject:gParams.serialNumber  forKey:@"deviceID"];
    if (!gParams.anonymous) {
        [queryParam setObject:gParams.mobile  forKey:@"userMobile"];
    } else {
        [queryParam setObject:@""  forKey:@"username"];
        [queryParam setObject:@""  forKey:@"userMobile"];
    }
    
     [queryParam setObject:phone forKey:@"calledPhone"];
    //增加客户端版本号
    [queryParam setObject:gParams.appVersion forKey:@"clientVersion"];
//    [net asynRequest:interfaceClientVisitRecord with:queryParam needSSL:NO target:nil action:nil];
}
*/

+ (void)submitDeviceToken4Push
{
    HMGlobalParams *gParam = [HMGlobalParams sharedInstance];
    if (gParam.deviceToken4Push) {
        LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
        NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 2];
        [queryParam setObject:gParam.deviceToken4Push forKey:@"deviceToken"];
        [queryParam setObject:gParam.serialNumber forKey:@"deviceId"];
        if(gParam.mobile != nil) [queryParam setObject:gParam.mobile forKey:@"mobile"];
        
        [net asynRequest:interfacePushReportToken with:queryParam needSSL:NO target:nil action:nil];
        //[net asynRequest:interfacePushReportToken path:LC_SYS_PROVIDER_SERVERPATH with:queryParam needSSL:NO target:nil action:nil];
    }
}

+ (void)submitAppLaunch
{
    HMGlobalParams *gParam = [HMGlobalParams sharedInstance];
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 2];
    if (gParam.deviceToken4Push) {
        [queryParam setObject:gParam.deviceToken4Push forKey:@"deviceToken"];
    }
    [queryParam setObject:gParam.serialNumber forKey:@"deviceId"];
    [queryParam setObject:@"0" forKey:@"type"];
   
    [net asynRequest:interfacePushReportLaunch with:queryParam needSSL:NO target:nil action:nil];
}


+ (BOOL)isIphone5
{
    if ([UIScreen instancesRespondToSelector:@selector(currentMode)]) {
         if (CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size)) {
            return YES;
        }
    }
    return NO;    
}
@end

