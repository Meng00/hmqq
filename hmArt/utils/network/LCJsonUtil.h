/*!
 @header LCJsonUtil.h
 @abstract JSON协议处理工具
 @author Copyright (c) Leader China. All rights reserved.
 @version 1.00 2012/03/14
 */


#import <Foundation/Foundation.h>

//#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_5_0
// 当iphone版本小于5.0时，使用JSONKit
#import "JSONKit.h"
//#endif

/*!
 @class
 @abstract 用于处理JSON
 */
@interface LCJsonUtil : NSObject

/*!
 @method
 @abstract 单实例
 */
+ (id)sharedInstance;

/*!
 @method
 @abstract 从对象转变成JSON数据
 @discussion 只有NSArray和NSDictionary类型可以被转换
 @param object
 @result JSON数据
 */
- (NSData *)dataWithJSONObject:(id)object;

/*!
 @method
 @abstract 从JSON数据转换到对象
 @param data JSON数据
 @result 对象
 */
- (id)jsonWithData:(NSData *)data;

/*!
 @method
 @abstract 将JSON数据转换成NSDictionary
 @param data JSON数据
 @result NSDictionary对象
 */
- (NSDictionary *)dictionaryWithData:(NSData *)data;

/*!
 @method
 @abstract 将JSON数据转换成NSArray
 @param data JSON数据
 @result NSArray对象
 */
- (NSArray *)arrayWithData:(NSData *)data;

@end
