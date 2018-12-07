/*!
 @header NetworkResultProcDelegate.h
 @abstract 网络服务异步处理委托协议
 @author Copyright (c) Leader China. All rights reserved.
 @version 1.00 2012/03/14
 */

#import <Foundation/Foundation.h>

/*!
 @protocol
 @abstract 网络服务异步处理委托协议
 */
@protocol NetworkResultProcDelegate <NSObject>
@optional
/*!
 @method
 @param state 是否可用
 @param message 当不可用时的信息
 */
- (void)networkStatusChanged:(BOOL)state 
                        with:(NSString *)message;

@end
