//
//  GetValueDelegate.h
//  hmArt
//
//  Created by wangyong on 13-7-9.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMInputCtrl.h"

@protocol GetValueDelegate <NSObject>

@optional
- (void)getValueFromInputCtrl:(HMInputCtrl *)sender;

@end
