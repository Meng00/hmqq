//
//  HMInputCtrl.h
//  hmArt
//
//  Created by wangyong on 13-7-9.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMInputCtrl : NSObject

@property (nonatomic, strong) id input;

@property (nonatomic, copy) NSString *name;

@property (nonatomic) long sequence;

@property (nonatomic, strong) id value;

@property (nonatomic, assign) BOOL keyBoardInput;

@end

@interface HMEventAction : NSObject

@property (nonatomic, strong) id source;

@property (nonatomic, strong) id target;

@property (nonatomic, unsafe_unretained) SEL action;

@property (nonatomic, copy) NSString *format;

@end