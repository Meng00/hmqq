//
//  NSString+LCJsonKit.m
//  lifeassistant
//
//  Created by wangyong on 15/11/9.
//
//

#import "LCJsonKit.h"

@implementation NSString (JSONKitDeserializing)

- (id)objectFromJSONString
{
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&error];
    if (jsonObject != nil && error == nil) {
        return jsonObject;
    }
    return nil;
    
}
@end

@implementation NSDictionary (JSONKitSerializing)
- (id)JSONString
{
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    if (!error) {
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return jsonString;
    }
    return nil;
    
}
@end
