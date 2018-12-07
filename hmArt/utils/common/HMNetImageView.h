//
//  HMNetImageView.h
//  hmArt
//
//  Created by wangyong on 13-7-12.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCNetworkInterface.h"

@protocol HMNetImageLoaded <NSObject>

@optional
- (void)netImageLoaded;

@end

@interface HMNetImageView : UIImageView
{
    unsigned int _requestID;
    
}

@property (nonatomic, retain) id <HMNetImageLoaded> delegate;
@property (copy, nonatomic) NSString *imageUrl;

- (void)load;

- (void)stopLoad;

@end
