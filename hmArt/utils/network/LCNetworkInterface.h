//
//  LCNetworkInterface.h
//  lifeassistant
//
//  Created by wangyong on 13-4-10.
//
//

#import <Foundation/Foundation.h>
#import "NetworkResultProcDelegate.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "LCJsonUtil.h"
#import "LCInterfaceProtocol.h"
#import "HMGlobal.h"
#import "LCDESCoder.h"

/*!
 @class
 @abstract 网络服务工具类。
 */
@interface LCNetworkInterface : NSObject<LCInterfaceProtocol> {
    unsigned int _requstCount;
    __strong NSMutableDictionary *_requests;
}

/*!
 @property
 @abstract 网络状态委托
 */
@property (nonatomic, strong) id<NetworkResultProcDelegate> delegate;

/*!
 @method
 @abstract 单实例
 */
+ (id)sharedInstance;

/*!
 @method
 @param
 @abstract 设置超时秒数
 */
+ (void)setTimeOutSeconds:(unsigned int)seconds;

@end
