//
//  LCJsonUtil.m
//  ChinaUnicom114Client
//
//  Created by administrator on 12-3-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LCJsonUtil.h"

@implementation LCJsonUtil

+ (id)sharedInstance {
    static LCJsonUtil* singleInstance = nil;
    if (!singleInstance) {
        singleInstance = [[LCJsonUtil alloc] init];
        // 
    }
    return singleInstance;
}

- (NSData *)dataWithJSONObject: (id) object {
//#if __IPHONE_OS_VERSION_MAX_ALLOWED == __IPHONE_5_0 
//    NSError* error = nil;
//    NSData* jsonData = [NSJSONSerialization
//                        dataWithJSONObject: object
//                        options: NSJSONWritingPrettyPrinted 
//                        error: &error];
//    
//    if ([jsonData length] > 0 && error == nil){
//        NSLog(@"Successfully serialized the dictionary into data = %@", jsonData);
//    }
//    else if ([jsonData length] == 0 &&
//             error == nil){
//        NSLog(@"No data was returned after serialization.");
//    }
//    else if (error != nil){
//        NSLog(@"An error happened = %@", error); }
//    
//    return jsonData;
//#else
    // 使用JSONKit
    if ([object isKindOfClass: [NSDictionary class]])
        return [(NSDictionary *)object JSONData];
    else if ([object isKindOfClass: [NSArray class]])
        return [(NSArray *)object JSONData];
    return nil;
              
//#endif
    
}

- (id)jsonWithData:(NSData *)data {

//#if __IPHONE_OS_VERSION_MAX_ALLOWED == __IPHONE_5_0 
//    NSError* error = nil;
//    
//    id jsonObject = [NSJSONSerialization
//                     JSONObjectWithData:data
//                     options:NSJSONReadingAllowFragments 
//                     error:&error];
//    
//    if (jsonObject != nil && error == nil){
//        return jsonObject;
//    }
//    else if (error != nil){
//        return nil;
//    }
//    
//#else
    // 使用JSONKit
    NSError *error = nil;
    if (!data) {
        return nil;
    }
    JSONDecoder *decoder = [JSONDecoder decoder];
    id jsonObject = [decoder objectWithData:data error:&error];

    if (jsonObject != nil && error == nil)
        return jsonObject;
    else
        return nil;
    
//#endif
    
}

- (NSDictionary *)dictionaryWithData:(NSData *)data {
    id jsonObject = [self jsonWithData: data];
    if ([jsonObject isKindOfClass:[NSDictionary class]]){
        return (NSDictionary *)jsonObject;
    } else {
        return nil;
    }
}

- (NSArray*)arrayWithData:(NSData *)data {
    if (!data) {
        return [[NSArray alloc] init];
    }
    id jsonObject = [self jsonWithData: data];
    if ([jsonObject isKindOfClass:[NSArray class]]){
        return (NSArray *)jsonObject;
    } else {
        return nil;
    }
}

@end
