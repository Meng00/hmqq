//
//  HMIconView.h
//  hmArt
//
//  Created by wangyong on 13-7-7.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "LCNetworkInterface.h"

@interface HMIconView : UIView
{
    unsigned int _requestID;
    
    CGRect _viewSize;
    
    UIImageView *_imageView;
    UILabel *_label;

}

@property (copy, nonatomic) NSString *imageUrl;
@property (copy, nonatomic) NSString *iconTitle;

- (void)load;

- (void)stopLoad;

@end
