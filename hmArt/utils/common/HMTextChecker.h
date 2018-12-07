//
//  HMTextChecker.h
//  hmArt
//
//  Created by wangyong on 13-7-9.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMTextChecker : NSObject

+ (BOOL)checkID:(NSString *)txt;

+ (BOOL)checkEmail:(NSString *)txt;

+ (BOOL)checkDate:(NSString *)txt;

+ (BOOL)checkIsEmpty:(NSString *)txt;

+ (BOOL)checkLength:(NSString *)txt min:(NSUInteger)min max:(NSUInteger)max;

+ (BOOL)checkIsNumber:(NSString *)txt;

+ (BOOL)checkIsNumber:(NSString *)txt withLength:(NSUInteger)len;

+ (BOOL)checkIsMobile:(NSString *)txt;

@end
