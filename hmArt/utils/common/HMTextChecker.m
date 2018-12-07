//
//  HMTextChecker.m
//  hmArt
//
//  Created by wangyong on 13-7-9.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import "HMTextChecker.h"
#import "HMUtility.h"

@implementation HMTextChecker

+ (BOOL)checkAreaCode:(NSString *)code
{
    NSDictionary *area = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"北京", @"11", @"天津", @"12", @"河北", @"13",
                          @"山西", @"14", @"内蒙古", @"15" , @"辽宁", @"21",
                          @"吉林", @"22", @"黑龙江", @"23", @"上海", @"23",
                          @"江苏", @"32", @"浙江", @"33", @"安徽", @"34",
                          @"福建", @"35", @"江西", @"36", @"山东", @"37",
                          @"河南", @"41", @"湖北", @"42", @"湖南", @"43",
                          @"广东", @"44", @"广西", @"45", @"海南", @"46",
                          @"重庆", @"50", @"四川", @"51", @"贵州", @"52",
                          @"云南", @"53", @"西藏", @"54", @"陕西", @"61",
                          @"甘肃", @"62", @"青海", @"63", @"宁夏", @"64",
                          @"新疆", @"65", @"台湾", @"71", @"香港", @"81",
                          @"澳门", @"82", @"国外", @"91", nil];
    
    if ([area objectForKey:code] != nil)
        return YES;
    else
        return NO;
}

+ (BOOL)checkID:(NSString *)txt
{
    if (!txt) return NO;
    
    NSUInteger length = txt.length;
    
    // 长度检查
    if (length != 15 && length != 18) {
        return NO;
    }
    
    // 检查地区码
    NSString *code = [txt substringToIndex:2];
    if (![HMTextChecker checkAreaCode:code]) return NO;
    
    // 检查生日
    NSString *birthDay;
    if (length == 15) {
        birthDay = [NSString stringWithFormat:@"19%@", [txt substringWithRange:NSMakeRange(6, 6)]];
    } else {
        birthDay = [txt substringWithRange:NSMakeRange(6, 8)];
    }
    
    NSDate *date = [HMUtility dateFrom:birthDay withFormat:@"yyyyMMdd" timeZone:nil];
    if (!date) return NO;
    else return YES;
    
    return NO;
}

+ (BOOL)checkEmail:(NSString *)txt
{
    NSString *emailRegex = @"^\\w+((\\-\\w+)|(\\.\\w+))*@[A-Za-z0-9]+((\\.|\\-)[A-Za-z0-9]+)*.[A-Za-z0-9]+$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:txt];
}

+ (BOOL)checkDate:(NSString *)txt
{
    return [HMUtility dateFrom:txt withFormat:@"yyyyMMdd" timeZone:nil] != nil;
}

+ (BOOL)checkIsEmpty:(NSString *)txt
{
    if (txt && txt.length > 0) return NO;
    else return YES;
}

+ (BOOL)checkLength:(NSString *)txt min:(NSUInteger)min max:(NSUInteger)max
{
    if (!txt) {
        return min == 0;
    }
    
    NSUInteger len = txt.length;
    return (len >= min && len <= max);
}

+ (BOOL)checkIsNumber:(NSString *)txt
{
    NSString *regex = @"^[0-9]+$";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [test evaluateWithObject:txt];
}

+ (BOOL)checkIsNumber:(NSString *)txt withLength:(NSUInteger)len
{
    NSString *regex = [NSString stringWithFormat:@"^[0-9]{%lu}$", (unsigned long)len];
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [test evaluateWithObject:txt];
}

+ (BOOL)checkIsMobile:(NSString *)txt
{
    NSString *regex = @"^[1][3-8]+\\d{9}";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [test evaluateWithObject:txt];
}

@end
