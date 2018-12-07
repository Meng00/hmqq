//
//  HMMUIWebView.h
//  hmArt
//
//  Created by 刘学 on 16/10/14.
//  Copyright © 2016年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "PDRCore.h"
#import "PDRCoreAppWindow.h"

@interface HMMUIWebView : UIViewController<PDRCoreDelegate,PDRCoreAppWindowDelegate>

@property (nonatomic, copy) NSString *url;

@end
