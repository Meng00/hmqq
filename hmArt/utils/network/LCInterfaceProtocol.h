//
//  LCInterfaceProtocol.h
//  lifeassistant
//
//  Created by wangyong on 13-4-10.
//
//

#import <Foundation/Foundation.h>
#import "LCInterfaceResult.h"

@protocol LCInterfaceProtocol <NSObject>

/*!
 @method
 @abstract 同步请求服务
 @discussion 无
 @param serviceName 服务名称
 @param parameter 参数对象
 @param ssl 是否需要SSL
 @result 服务结果
 */
- (LCInterfaceResult*)request:(NSString *)serviceName
                     with:(NSObject *)parameter
                  serverUrl:(NSString *)url;

/*!
 @method
 @abstract 异步请求服务
 @discussion 无
 @param serviceName 服务名称
 @param parameter 参数对象
 @param ssl 是否需要SSL
 @param target 异步委托处理对象
 @param action 处理动作
 @result 请求的标识
 */
- (unsigned int)asynRequest:(NSString *)serviceName
                       with:(NSObject *)parameter
                    needSSL:(BOOL)ssl
                     target:(id)target
                     action:(SEL)action;

/*!
 @method
 @abstract 异步请求服务
 @discussion 无
 @param serverPath 服务路径
 @param serviceName 服务名称
 @param parameter 参数对象
 @param ssl 是否需要SSL
 @param target 异步委托处理对象
 @param action 处理动作
 @result 请求的标识
 */
- (unsigned int)asynRequest:(NSString *)serviceName 
                    path:(NSString *)serverPath
                       with:(NSObject *)parameter
                    needSSL:(BOOL)ssl
                     target:(id)target
                     action:(SEL)action;

/*!
 @method
 @abstract 异步请求服务
 @discussion 无
 @param serviceName 服务名称
 @param parameter 参数对象
 @param ssl 是否需要SSL
 @param target 异步委托处理对象
 @param action 处理动作
 @param data    用户数据
 @result 请求的标识
 */
- (unsigned int)asynRequest:(NSString *)serviceName
                       with:(NSObject *)parameter
                    needSSL:(BOOL)ssl
                     target:(id)target
                     action:(SEL)action
                       data:(id)data;

/*!
 @method
 @abstract 异步请求资源
 @discussion
 @param path 资源路径
 @param external 是否是外部站点
 @param ssl 是否需要SSL
 @param cached 是否需要缓存
 @param delegate 结果委托处理对象
 @result 请求的标识
 */
- (unsigned int)asynExternalRequest:(NSString *)path
                            needSSL:(BOOL)ssl
                             cached:(BOOL)cached
                             target:(id)target
                             action:(SEL)action;

/*!
 @method
 @abstract 异步请求数据json
 @discussion
 @param path 资源路径
 @param cached 是否需要缓存
 @param delegate 结果委托处理对象
 */
- (unsigned int)asynExternalRequest:(NSString *)path
                             cached:(BOOL)cached
                             target:(id)target
                             action:(SEL)action;

/*!
 @method
 @abstract 取消异步请求
 @param requestID 请求标识
 */
- (void)cancelRequest:(unsigned int)requestID;

@end
