//
//  HMUtility.h
//  hmArt
//
//  Created by wangyong on 13-6-16.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "LCTapToCloseView.h"
#import "HMGlobalParams.h"

@interface HMUtility : NSObject

+ (UIView *)getRootView:(UIView *)view;


/*!
 @method
 @param
 @param
 @abstract 从NIB加载视图
 */
+ (id)loadViewFromNib:(NSString *)nib withClass:(Class)clazz;



/*!
 @method
 @param view    对话框
 @param rview   显示在的视图
 @param close   是否点击背景关闭
 @abstract 显示对话框
 */
+ (void)showModalView:(UIView *)view baseView:(UIView *)rview clickBackgroundToClose:(BOOL)close;

/*!
 @method
 @param view    对话框
 @param rview   显示在的视图
 @param close   是否点击背景关闭
 @abstract 显示对话框
 */
+ (void)showModalViewOnTransparentBase:(UIView *)view baseView:(UIView *)rview clickBackgroundToClose:(BOOL)close;

/*!
 @method
 @param view    对话框
 @param rview   显示在的视图
 @param close   是否点击背景关闭
 @param color   对话框背景色
 @abstract 显示对话框
 */
+ (void)showModalView:(UIView *)view baseView:(UIView *)rview clickBackgroundToClose:(BOOL)close dlgBackgroundColor:(UIColor *)color;

/*!
 @method
 @param view    对话框
 @param rview   显示在的视图
 @param close   是否点击背景关闭
 @param size    显示尺寸
 @abstract 显示对话框，根据显示尺寸，有可能对话框内容需要滚动
 */
+ (void)showModalView:(UIView *)view baseView:(UIView *)rview clickBackgroundToClose:(BOOL)close fixSize:(CGSize)size;

/*!
 @method
 @param view    对话框
 @param rview   显示在的视图
 @param close   是否点击背景关闭
 @param size    显示尺寸
 @param color   对话框背景色
 @abstract 显示对话框，根据显示尺寸，有可能对话框内容需要滚动
 */
+ (void)showModalView:(UIView *)view baseView:(UIView *)rview clickBackgroundToClose:(BOOL)close fixSize:(CGSize)size dlgBackgroundColor:(UIColor *)color;

/*!
 @method
 @param view
 @abstract 关闭对话框
 */
+ (void)dismissModalView:(UIView *)view;

/**
 @method
 @param view
 @param radius
 @param topLeft
 @param topRight
 @param bottomLeft
 @param bottomRight
 @abstract 画圆角
 */
+ (void)addRoundCorner:(UIView *)view
            withRadius:(CGFloat)radius
             onTopLeft:(BOOL)topLeft
            onTopRight:(BOOL)topRight
          onBottomLeft:(BOOL)bottomLeft
         onBottonRight:(BOOL)bottomRight;

/*!
 @method
 @abstract 计算控件的位置
 @param view 视图
 @param referenceView 参照视图
 */
+ (CGPoint)caculLocation:(UIView *)view
           referenceView:(UIView *)referenceView;

/*!
 @method
 @param txt     日期字符串
 @param format  格式化串
 @param zone    时区
 @abstract 将字符串变换为日期
 */
+ (NSDate *)dateFrom:(NSString *)txt withFormat:(NSString *)format timeZone:(NSTimeZone *)zone;

/*!
 @method
 @param date    日期
 @param format  格式化串
 @param zone    时区
 @abstract 将日期变换为字符串
 */
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format timeZone:(NSTimeZone *)zone;

+ (NSDate *)datePlus:(NSDate *)date years:(NSInteger)years months:(NSInteger)months Days:(NSInteger)days hours:(NSInteger)hours minutes:(NSInteger)minutes seconds:(NSInteger)seconds;

+ (NSDate *)getShortDate:(NSDate *)date;

/*!
 @method
 @param view
 @param text
 @abstract 显示提示
 */
+ (void)showTipInView:(UIView *)view withText:(NSString *)text;


+ (void)showTip:(NSString *)text inView:(UIView *)view;

/*!
 @abstract 计算字符串显示尺寸
 */
+ (CGSize)calculateSize:(NSString *)txt withFont:(UIFont *)font fixedWidth:(CGFloat)width;

/*!
 @method
 @param text    显示的文字
 @param view    所在视图
 @param target  执行动作目标
 @param action  动作
 @abstract 在view中显示一个点击就执行动作的文字视图。
 */
+ (void)tap2Action:(NSString *)text on:(UIView *)view target:(id)target action:(SEL)action;

/*!
 @method
 @abstract 显示弹出窗口
 @param message 显示的消息
 @param title 标题
 */
+ (void)alert:(NSString *)message
        title:(NSString *) title;


+ (NSString *)getString:(NSString *)str;

/*!
 @method
 @param indicator
 @param view
 @abstract
 */
+ (void)addBusyIndictor:(UIActivityIndicatorView *)indicator toView:(UIView *)view;

/*
 *生成指定长度的数字随机数
 */
+ (NSString *)genRandom:(NSInteger)length;


+ (void)makeSearchBarTransparent:(UISearchBar *)searchBar;

+ (void)writeUserInfo;

+ (void)readUserInfo;

+ (void)resetUserInfo;

+ (void)navBar:(UINavigationBar *)bar backImage:(NSString *)image backTag:(NSInteger)tag;

+ (NSString *)getPrice:(NSNumber *)price pictureType:(NSInteger) type;

+ (BOOL)isComplexSize:(NSString *)pictureSize;

+ (NSString *)dealPictureSize:(NSString *)pictureSize;

+ (NSDictionary *) parametersWithSeparator:(NSString *)separator delimiter:(NSString *)delimiter url:(NSString *)str;

+(NSString *) compareCurrentTimeBySeconds:(NSUInteger)seconds;

+ (void)showCalendarInView:(UIView *)baseView target:(id)target currDate:(NSDate*)curDate minimumDate:(NSDate*)minDate maximumDate:(NSDate*)maxDate  hideYear:(BOOL)hidden;

@end
