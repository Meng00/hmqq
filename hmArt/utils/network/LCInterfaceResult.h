//
//  LCInterfaceResult.h
//  lifeassistant
//
//  Created by wangyong on 13-4-10.
//
//

#import <Foundation/Foundation.h>

@interface LCInterfaceResult : NSObject
/*!
 @property
 @abstract 请求编码
 */
@property unsigned int requestID;

/*！
 @property
 @abstract 服务返回的结果
 */
@property int result;

/*!
 @property
 @abstract 返回的信息
 */
@property (strong, nonatomic) NSString *message;

/*!
 @property
 @abstract 返回的数据对象
 */
@property (strong, nonatomic) id value;

/*!
 @property
 @abstract 用户存储的数据
 */
@property (strong, nonatomic) id userData;


@end
