//
//  LCAnimationUtility.m
//  Test5
//
//  Created by administrator on 12-4-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LCAnimationUtility.h"

@interface LCAnimationUtility()

// 设置完成函数
- (void)setCompleation:(LCCompletion)completion;

// 动画完成执行的动作
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag;

@end

@implementation LCAnimationUtility

- (void)setCompleation:(LCCompletion)completion {
    _completion = completion;
}

+ (void)animateView:(UIView *)view
           duration:(CGFloat)duration
         completion:(LCCompletion)completion
               path:(NSValue *)startPoint,...
{
    // 取动画路径
    NSMutableArray *points = [[NSMutableArray alloc] init];
    [points addObject:startPoint];
    NSValue *arg;
    va_list argList;
    va_start(argList, startPoint);
    //arg = va_arg(argList, NSValue *);
    while ((arg = va_arg(argList, NSValue *)))
    {
        [points addObject:arg];
    }
    va_end(argList);
    
    [LCAnimationUtility animateView:view duration:duration rotateCount:0 completion:completion paths:points];
}

+ (void)animateView:(UIView *)view
           duration:(CGFloat)duration
        rotateCount:(NSUInteger)rotateCount
         completion:(LCCompletion)completion
               path:(NSValue *)startPoint,...
{
    // 取动画路径
    NSMutableArray *points = [[NSMutableArray alloc] init];
    [points addObject:startPoint];
    NSValue *arg;
    va_list argList;
    va_start(argList, startPoint);
    //arg = va_arg(argList, NSValue *);
    while ((arg = va_arg(argList, NSValue *)))
    {
        [points addObject:arg];
    }
    va_end(argList);
    
    [LCAnimationUtility animateView:view duration:duration rotateCount:rotateCount completion:completion paths:points];
}

+ (void)animateView:(UIView *)view
           duration:(CGFloat)duration
        rotateCount:(NSUInteger)rotateCount
         completion:(LCCompletion)completion
               paths:(NSArray *)paths
{
    // 创建一个变量
    LCAnimationUtility *util = [[LCAnimationUtility alloc] init];
    
    // 设置完成后的函数
    [util setCompleation:completion];
    
    // 取动画路径
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:paths.count];
    for (NSUInteger i = 1; i < paths.count; ++i) {
        [points addObject:[paths objectAtIndex:i]];
    }
    
    if (points.count % 2 == 1) {
        [points addObject: [points objectAtIndex: points.count - 1]];
    }
    
    CGPoint point1 =  [[paths objectAtIndex:0] CGPointValue];
    CGMutablePathRef thePath = CGPathCreateMutable();
    //　动画起始位置
    CGPathMoveToPoint(thePath, NULL, point1.x, point1.y);
    
    // 动画运动轨迹点
    NSValue *v1 = nil;
    NSValue *v2 = nil;
    
    for (unsigned int i = 0; i < points.count; i += 2) {
        v1 = [points objectAtIndex: i];
        v2 = [points objectAtIndex: i + 1];
        
        CGPoint point2 = v1.CGPointValue;
        CGPoint point3 = v2.CGPointValue;
        
        CGPathAddCurveToPoint(thePath,NULL,
                              point1.x, point1.y,
                              point2.x, point2.y,
                              point3.x, point3.y);
        point1 = point3;
    }
    
    // 设置一个关键帧动画
    CAKeyframeAnimation *theAnimation=[CAKeyframeAnimation
                                       animationWithKeyPath:@"position"];
    
    theAnimation.path=thePath;
    // 设置运行时长
    theAnimation.duration = duration;
    
    theAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    // 动画执行委托为创建的变量
    theAnimation.delegate = util;
    
    CFRelease(thePath);
    
    // 开始动画
    [view.layer addAnimation:theAnimation forKey:@"animatePosition"];
    
    // 旋转视图
    if (rotateCount > 0) {
        CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotation.byValue = [NSNumber numberWithDouble:M_PI * rotateCount];
        rotation.duration = duration;
        
        [view.layer addAnimation:rotation forKey:@"animateRotation"];
    }
}

- (void)animationDidStop:(CAAnimation *)theAnimation
                finished:(BOOL)flag
{
    // 如果有完成后函数，则执行。
    if (_completion)
        _completion(flag);
}

+ (void)easeInView:(UIView *)view
        containerView:(UIView *)container
             duration:(CGFloat)duration
           completion:(LCCompletion)completion
              fromTop:(BOOL)top
{
    // 如果上部开始
    CGSize containerSize = container.bounds.size;
    CGRect targetFrame = view.frame;
    
    CGFloat x = (containerSize.width - view.bounds.size.width) / 2;
    
    if (top) {
        CGRect rect = CGRectMake(x, -view.frame.size.height, view.frame.size.width, view.frame.size.height);
        view.frame = rect;
        if (view.hidden)
            view.hidden = NO;
    } else {
        CGRect rect = CGRectMake(x, containerSize.height, view.frame.size.width, view.frame.size.height);
        view.frame = rect;
        if (view.hidden)
            view.hidden = NO;
    }
    
    BOOL clip = container.clipsToBounds;
    container.clipsToBounds = YES;
    [container addSubview:view];
    
    [UIView animateWithDuration:duration animations:^{
        if (top) {
            CGAffineTransform moveTransform = CGAffineTransformMakeTranslation(0, view.bounds.size.height + targetFrame.origin.y);
            [view.layer setAffineTransform:moveTransform];
        } else {
            CGAffineTransform moveTransform = CGAffineTransformMakeTranslation(0, -view.bounds.size.height - targetFrame.origin.y);
            [view.layer setAffineTransform:moveTransform];
        }
    } completion:^(BOOL finished) {
        if (finished) {
            [view.layer setAffineTransform:CGAffineTransformIdentity];
            view.frame = targetFrame;
            container.clipsToBounds = clip;
        }
        //　是否执行完成后函数
        if (completion)
            completion(finished);
    }];
}

+ (void)easeOutView:(UIView *)view
     containerView:(UIView *)container
          duration:(CGFloat)duration
        completion:(LCCompletion)completion
           toTop:(BOOL)top
{
    // 如果上部开始
    [UIView animateWithDuration:duration animations:^{
        if (top) {
            CGAffineTransform moveTransform = CGAffineTransformMakeTranslation(0, -view.bounds.size.height - view.frame.origin.y);
            [view.layer setAffineTransform:moveTransform];
        } else {
            CGAffineTransform moveTransform = CGAffineTransformMakeTranslation(0, container.bounds.size.height - view.frame.origin.y);
            [view.layer setAffineTransform:moveTransform];
        }
    } completion:^(BOOL finished) {
        if (finished) {
            [view.layer setAffineTransform:CGAffineTransformIdentity];
            [view removeFromSuperview];
        }

        //　是否执行完成后函数
        if (completion)
            completion(finished);
    }];
}

+ (void)easeInOutView:(UIView *)view
        containerView:(UIView *)container
                delay:(CGFloat)delay
             duration:(CGFloat)duration
           completion:(LCCompletion)completion
              fromTop:(BOOL)top
{
    // 如果上部开始
    CGSize containerSize = container.bounds.size;
    CGFloat x = (containerSize.width - view.bounds.size.width) / 2;
    
    if (top) {
        CGRect rect = CGRectMake(x, -view.frame.size.height, view.frame.size.width, view.frame.size.height);
        view.frame = rect;
        if (view.hidden)
            view.hidden = NO;
    } else {
        CGRect rect = CGRectMake(x, containerSize.height, view.frame.size.width, view.frame.size.height);
        view.frame = rect;
        if (view.hidden)
            view.hidden = NO;
    }
    
    BOOL clip = container.clipsToBounds;
    container.clipsToBounds = YES;
    [container addSubview:view];
    
    [UIView animateWithDuration:duration animations:^{
        if (top) {
            CGAffineTransform moveTransform = CGAffineTransformMakeTranslation(0, view.bounds.size.height);
            [view.layer setAffineTransform:moveTransform];
        } else {
            CGAffineTransform moveTransform = CGAffineTransformMakeTranslation(0, -view.bounds.size.height);
            [view.layer setAffineTransform:moveTransform];
        }
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:duration
                                  delay:delay
                                options:UIViewAnimationOptionTransitionNone
                             animations:^{
                if (top) {
                    CGAffineTransform moveTransform = CGAffineTransformMakeTranslation(0, -view.bounds.size.height);
                    [view.layer setAffineTransform:moveTransform];
                } else {
                    CGAffineTransform moveTransform = CGAffineTransformMakeTranslation(0, view.bounds.size.height);
                    [view.layer setAffineTransform:moveTransform];
                }
            } completion:^(BOOL finished) {
                if (finished) {
                    [view.layer setAffineTransform:CGAffineTransformIdentity];
                    view.hidden = YES;
                    [view removeFromSuperview];
                    container.clipsToBounds = clip;
                }
                //　是否执行完成后函数
                if (completion)
                    completion(finished);
            }];
        }
    }];
}

+ (void)fadeInOutView:(UIView *)view
        containerView:(UIView *)container
                delay:(CGFloat)delay
             duration:(CGFloat)duration
           completion:(LCCompletion)completion
{
    // 全透明
    view.layer.opacity = 0;

    [container addSubview:view];
    
    [UIView animateWithDuration:duration animations:^{
        view.layer.opacity = 1;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:duration
                                  delay:delay
                                options:UIViewAnimationOptionTransitionNone
                             animations:^{
                view.layer.opacity = 0;
            } completion:^(BOOL finished) {
                if (finished)
                    [view removeFromSuperview];
                //　是否执行完成后函数
                if (completion)
                    completion(finished);
            }];
        }
    }];
    
}

+ (void)fadeOutView:(UIView *)view
        containerView:(UIView *)container
              delay:(CGFloat)delay
             duration:(CGFloat)duration
           completion:(LCCompletion)completion
{
    // 全透明
    view.layer.opacity = 1;

    [container addSubview:view];
    
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
        view.layer.opacity = 0;
    } completion:^(BOOL finished) {
        if (finished)
            [view removeFromSuperview];
        //　是否执行完成后函数
        if (completion)
            completion(finished);
    }];
    
}

@end
