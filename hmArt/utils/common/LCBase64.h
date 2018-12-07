//
//  LCBase64.h
//  lifeassistant
//
//  Created by liuxue on 13-7-19.
//
//

#import <Foundation/Foundation.h>

@interface LCBase64 : NSObject

/**
 *base64格式字符串转换为文本数据
 */
+ (NSData*) base64Decode:(NSString *)string;

/**
 *文本数据转换为base64格式字符串
 */
+ (NSString*) base64Encode:(NSData *)data;

@end
