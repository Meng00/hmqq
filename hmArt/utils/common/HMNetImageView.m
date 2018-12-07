//
//  HMNetImageView.m
//  hmArt
//
//  Created by wangyong on 13-7-12.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import "HMNetImageView.h"


@implementation HMNetImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)dealloc
{
    // 取消所有的请求
    [self stopLoad];
}

- (void)load
{
    // 停止原先的请求
    [self stopLoad];
    
    // 远程请求图片
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    
    if (_imageUrl && ![_imageUrl isEqualToString:HM_SYS_IMGSRV_PREFIX])
        _requestID = [net asynExternalRequest:_imageUrl needSSL:NO cached:YES target:self action:@selector(serviceComplete:withResult:)];
    
    
    
}

- (void)stopLoad
{
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    
    if (_requestID != 0)
        [net cancelRequest:_requestID];
    
}

#pragma mark -
#pragma mark 处理服务返回的消息
- (void)serviceComplete:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    if (result.requestID == _requestID) {
        if (result.result == HM_NET_INTERFACE_SUCCESS) {
            UIImage *image = [UIImage imageWithData:result.value];
            self.contentMode = UIViewContentModeScaleAspectFit;
            self.image = image;
            if (_delegate && [_delegate respondsToSelector:@selector(netImageLoaded)]) {
                [_delegate netImageLoaded];
            }
        }
        _requestID = 0;
    }
}

@end
