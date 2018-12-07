//
//  HMAdImageView.m
//  hmArt
//
//  Created by wangyong on 14-8-17.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMAdImageView.h"

@implementation HMAdImageView

@synthesize parent;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initMyself];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initMyself];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [_adItems removeAllObjects];
    _adItems = nil;
    
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    for (NSNumber *req in _requestIds) {
        if (req.intValue > 0) {
            [net cancelRequest:req.intValue];
        }
    }
    [_requestIds removeAllObjects];
    _requestIds = nil;
    
    [_adImages removeAllObjects];
    _adImages = nil;
}

- (void)initMyself
{
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.image = [UIImage imageNamed:@"addefault.png"];
    _switching = NO;
    _interval = 5;
    _current = 0;
    _adItems = [[NSMutableArray alloc] init];
    _requestIds = [[NSMutableArray alloc] init];
    _adImages = [[NSMutableArray alloc] init];
    
}

- (void)enableInteraction
{
    self.userInteractionEnabled = YES;
    UISwipeGestureRecognizer *swipe1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAdImage:)];
    swipe1.direction = UISwipeGestureRecognizerDirectionLeft;
    swipe1.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:swipe1];
    
    UISwipeGestureRecognizer *swipe2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAdImage:)];
    swipe2.direction = UISwipeGestureRecognizerDirectionRight;
    swipe2.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:swipe2];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tap];
}

//- (void)setParent:(UIViewController *)parent
//{
//    _parentController = parent;
//}
#pragma mark -
#pragma mark animating methods
- (void)setInterval:(NSUInteger)interval
{
    _interval = interval;
}
- (BOOL)isSwitching
{
    return _switching;
}

- (void)startSwitch
{
    if (_adImages.count < 2) {
        return;
    }
    if (_switching) {
        return;
    }
    _switching = YES;
    _pageIncrement = YES;
    [self performSelector:@selector(turnPage) withObject:nil afterDelay:_interval];
}

- (void)stopSwitch
{
    _switching = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(turnPage) object:nil];
}

- (void)swipeAdImage:(UISwipeGestureRecognizer *)recognizer
{
    if (_adImages.count <= 1) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(turnPage) object:nil];
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight)
    {
        _pageIncrement = NO;
    } else {
        _pageIncrement = YES;
    }
    
    [self turnPage];
}

- (void)turnPage
{
    if (_adImages.count < 2) {
        return;
    }
    CATransition *animation = [CATransition animation];
    animation.duration = 0.1f;
    //animation.timingFunction = UIViewAnimationCurveEaseIn;
    animation.type = kCATransitionPush;
    
    if (!_pageIncrement) {
        if (_current != 0)
           _current--;
        else
            _current= _adImages.count - 1;
        animation.subtype = kCATransitionFromLeft;
        //重置回向右切换图片
        _pageIncrement = YES;
        
    } else {
        _current = (++_current) % _adImages.count;
        animation.subtype = kCATransitionFromRight;
    }
     [self setImage:[_adImages objectAtIndex:_current]];
    
    
    [self.layer addAnimation:animation forKey:@"animationID"];
    
    [self performSelector:@selector(turnPage) withObject:nil afterDelay:_interval];
}

#pragma mark -
#pragma mark load images
- (void)addItem:(NSDictionary *)ad
{
    [_adItems addObject:ad];
    UIImage *image = [UIImage imageNamed:@"holder_320_110.png"];
    [_adImages addObject:image];
    if (_adItems.count == 1) {
        [self enableInteraction];
    }
    
    NSString *imgUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [ad objectForKey:@"image"]];
    unsigned int requestId = [[LCNetworkInterface sharedInstance] asynExternalRequest:imgUrl needSSL:NO cached:YES target:self action:@selector(serviceComplete:withResult:)];
    [_requestIds addObject:[NSNumber numberWithInt:requestId]];
}

- (void)serviceComplete:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        UIImage *image = [UIImage imageWithData:result.value];
        if (!image) {
            return;
        }
        for (unsigned int i = 0; i < _requestIds.count; i++) {
            NSNumber *num = [_requestIds objectAtIndex:i];
            if (num.intValue == result.requestID) {
                [_adImages replaceObjectAtIndex:i withObject:image];
                if (i==0) {
                    [self setImage:image];
                }
                [_requestIds replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
                break;
            }
        }
    }
}

#pragma mark -
#pragma mark AD tap method
- (void)tapped:(UITapGestureRecognizer*)param
{
    NSDictionary *dictionary = [_adItems objectAtIndex:_current];
    NSInteger adType = [[dictionary objectForKey:@"type"] integerValue];
//    [LCGlobalDeviceInfo submitDeviceInfoForAd:[dictionary objectForKey:@"name"] withType:@"HOME"];
    if (adType == 1) {
        NSString *iosAddr = [dictionary objectForKey:@"url"];
        NSRange searchResult = [iosAddr rangeOfString:@"?"];
        NSDictionary *classNames = [HMGlobalParams sharedInstance].classNames;
        if (searchResult.location == NSNotFound) {
            NSString *localClass = [classNames objectForKey:iosAddr];
            id controller = [[NSClassFromString(localClass) alloc] init];
            if (controller != nil) {
                parent.navigationController.navigationBarHidden = NO;
                [parent.navigationController pushViewController:controller animated:true];
            }
        } else {
            NSString *className = [iosAddr substringToIndex:searchResult.location];
            NSString *params = [iosAddr substringFromIndex:(searchResult.location + 1)];
            NSString *localClass = [classNames objectForKey:className];
            id controller = [[NSClassFromString(localClass) alloc] init];
            if (controller != nil) {
                if ([controller respondsToSelector:@selector(setParams:)]) {
                    [controller performSelector:@selector(setParams:) withObject:params];
                }
                parent.navigationController.navigationBarHidden = NO;
                [parent.navigationController pushViewController:controller animated:true];
            }
            
        }
        
    } else if (adType == 2){
        // 判断result是不是Http链接，如果是打开浏览器
        NSURL *candidateURL = [NSURL URLWithString: [dictionary objectForKey:@"url"]];
        
        // 如果是URL, 则用浏览器访问
        if (candidateURL) {
            UIApplication *myApp = [UIApplication sharedApplication];
            [myApp openURL:candidateURL];
        }
    } else if (adType == 3){
        
        HMJSWebView *web = [[HMJSWebView alloc] initWithNibName:nil bundle:nil];
        web.url = [dictionary objectForKey:@"url"];
        [parent.navigationController pushViewController:web animated:YES];
        
    }
}

@end
