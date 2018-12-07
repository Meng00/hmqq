/*!
 @header LCAnimationUtility.h
 @abstract 动画工具类
 @author Copyright (c) Leader China. All rights reserved.
 @version 1.00 2012/03/14
 */

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

// 定义block
typedef void (^LCCompletion)(BOOL finished);

/*!
 @enum
 @abstract 动画类型
 */
enum LCAnimationType {
    // 淡入
    LCAnimation_FadeIn = 0,
    // 淡出
    LCAnimation_FadeOut = 1,
    // 从底部升起
    LCAnimation_FromBottom = 2,
    // 藏入底部
    LCAnimation_ToBottom = 3
};

/*!
 @class
 @abstract 动画工具类
 */
@interface LCAnimationUtility : NSObject
{
    // 动画结束后的执行函数指针
    LCCompletion _completion;
}

/*!
 @method
 @abstract 执行动画
 @discussion 路径使用由NSValue封装的CGPoint结构
 @param view 动画对象
 @param duration 执行时长
 @param completion 完成后执行block
 @param startPoint ... 运动到的位置
 */
+ (void)animateView:(UIView *)view
           duration:(CGFloat)duration
         completion:(LCCompletion)completion
               path:(NSValue *)startPoint,...;

/*!
 @method
 @abstract 执行动画
 @discussion 路径使用由NSValue封装的CGPoint结构
 @param view 动画对象
 @param duration 执行时长
 @param rotateCount 旋转次数
 @param completion 完成后执行block
 @param startPoint ... 运动到的位置
 */
+ (void)animateView:(UIView *)view
           duration:(CGFloat)duration
        rotateCount:(NSUInteger)rotateCount
         completion:(LCCompletion)completion
               path:(NSValue *)startPoint,...;

/*!
 @method
 @param view        动画对象
 @param container   容器视图
 @param duration    执行时长
 @param completion  完成后执行block
 @param fromTop     是否从上部滑入
 @abstract 滑入
 */
+ (void)easeInView:(UIView *)view
     containerView:(UIView *)container
          duration:(CGFloat)duration
        completion:(LCCompletion)completion
           fromTop:(BOOL)top;

/*!
 @method
 @param view        动画对象
 @param container   容器视图
 @param duration    执行时长
 @param completion  完成后执行block
 @param fromTop     是否从上部滑入
 @abstract 滑出
 */
+ (void)easeOutView:(UIView *)view
     containerView:(UIView *)container
          duration:(CGFloat)duration
        completion:(LCCompletion)completion
           toTop:(BOOL)top;

/*!
 @param view
 @param container
 @param delay
 @param duration
 @param completion
 @param top
 @abstract 滑进滑出
 */
+ (void)easeInOutView:(UIView *)view
        containerView:(UIView *)container
                delay:(CGFloat)delay
             duration:(CGFloat)duration
           completion:(LCCompletion)completion
              fromTop:(BOOL)top;

/*!
 @param view
 @param container
 @param delay
 @param duration
 @param completion
 @param top
 @abstract 淡入再淡出
 */
+ (void)fadeInOutView:(UIView *)view
        containerView:(UIView *)container
                delay:(CGFloat)delay
             duration:(CGFloat)duration
           completion:(LCCompletion)completion;


/*!
 @param view
 @param container
 @param delay
 @param duration
 @param completion
 @param top
 @abstract 淡出
 */
+ (void)fadeOutView:(UIView *)view
      containerView:(UIView *)container
              delay:(CGFloat)delay
           duration:(CGFloat)duration
         completion:(LCCompletion)completion;

@end
