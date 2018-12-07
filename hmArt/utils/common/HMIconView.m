//
//  HMIconView.m
//  hmArt
//
//  Created by wangyong on 13-7-7.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import "HMIconView.h"

@implementation HMIconView

@synthesize imageUrl = _imageUrl;
@synthesize iconTitle = _iconTitle;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _viewSize = frame;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _viewSize.size.width, _viewSize.size.height)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, _viewSize.size.height - 25, _viewSize.size.width, 25)];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor whiteColor];
        _label.backgroundColor = [UIColor blackColor];
        _label.alpha = 0.3;
        if (_iconTitle) {
            _label.text = _iconTitle;
        }
        [self addSubview:_label];
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

- (void)setIconTitle:(NSString *)iconTitle
{
    if (iconTitle) {
        _iconTitle = iconTitle;
        _label.text = iconTitle;
    }
}

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
    
    if (_imageUrl)
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
            _imageView.image = image;
        }
        _requestID = 0;
    }
}


@end
