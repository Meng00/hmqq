//
//  LCGlobalDeviceInfo.h
//  uni114
//
//  Created by wangyong on 13-1-24.
//
//

#import <Foundation/Foundation.h>

@interface LCGlobalDeviceInfo : NSObject

//+ (void)submitDeviceInfo:(NSString *)serviceName withType:(NSString *)serviceType;

//+ (void)submitDeviceInfoForAd:(NSString *)serviceName withType:(NSString *)serviceType;

//+ (void)submitPhoneCallLog:(NSString *)serviceName withType:(NSString *)serviceType phoneNumber:(NSString *)phone;

+ (void)submitDeviceToken4Push;

+ (void)submitAppLaunch;

+ (void)getDeviceInfo;

+ (BOOL)isIphone5;

@end

struct CTServerConnection
{
    int a;
    int b;
    CFMachPortRef myport;
    int c;
    int d;
    int e;
    int f;
    int g;
    int h;
    int i;
};

struct CTResult
{
    int flag;
    int a;
};

struct CTServerConnection * _CTServerConnectionCreate(CFAllocatorRef, void *, int *);

void _CTServerConnectionCopyMobileIdentity(struct CTResult *, struct CTServerConnection *, NSString **);