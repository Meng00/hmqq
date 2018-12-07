//
//  NSString+LCJsonKit.h
//  lifeassistant
//
//  Created by wangyong on 15/11/9.
//
//

#import <Foundation/Foundation.h>

@interface NSString (JSONKitDeserializing)
- (id)objectFromJSONString;
@end

@interface NSDictionary (JSONKitSerializing)
- (id)JSONString;
@end
