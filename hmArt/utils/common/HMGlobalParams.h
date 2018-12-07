//
//  HMGlobalParams.h
//  hmArt
//
//  Created by wangyong on 13-7-10.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMGlobalParams : NSObject

@property (nonatomic)BOOL anonymous;

@property (nonatomic)NSInteger uid;

@property (nonatomic)NSInteger sex;

@property (nonatomic)NSInteger vip;

@property (copy, nonatomic)NSString *mobile;

@property (copy, nonatomic)NSString *loginToken;

@property (copy, nonatomic)NSString *addr;

@property (copy, nonatomic)NSString *city;

@property (copy, nonatomic)NSString *job;

@property (copy, nonatomic)NSString *password;

@property (copy, nonatomic)NSString *name;

@property (copy, nonatomic)NSString *birth;

@property (copy, nonatomic)NSString *email;

@property (strong, nonatomic)NSMutableArray *categorys;

@property (strong, nonatomic) NSDictionary *classNames;

//mobile device infomation
@property (copy, nonatomic) NSString *osName;

@property (copy, nonatomic) NSString *osVersion;

@property (copy, nonatomic) NSString *vendorName;

@property (copy, nonatomic) NSString *model;

@property (copy, nonatomic) NSString *serialNumber;

@property (copy, nonatomic) NSNumber *screenWidth;

@property (copy, nonatomic) NSNumber *screenHeight;

@property (copy, nonatomic) NSNumber *scale;

@property (copy, nonatomic) NSString *screen;

@property (copy, nonatomic) NSString *carrier;

@property (copy, nonatomic) NSString *imei;

@property (copy, nonatomic) NSString *appVersion;

//消息推送
@property (nonatomic) NSInteger newsCount;

@property (nonatomic, strong) NSMutableString *newsIds;

@property (copy, nonatomic) NSString *deviceToken4Push;


@property (nonatomic) BOOL appendUserAgentSuffix;

/*!
 @method
 @abstract 单实例对象
 */
+ (HMGlobalParams *)sharedInstance;

@end
