//
//  HMInputController.h
//  hmArt
//
//  Created by wangyong on 13-7-9.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetValueDelegate.h"
#import "HMUtility.h"
#import "HMInputCtrl.h"
#import "HMTextChecker.h"

@interface HMInputController : UIViewController<UITextFieldDelegate, UITextViewDelegate>
{
    // 输入Form的偏移
    CGPoint formOffset;
    NSMutableArray *_inputsArray;
    NSMutableArray *_actionsWhenTextFieldEndEditing;
    UIBarButtonItem *_prevBBItem;
    UIBarButtonItem *_nextBBItem;
    UIBarButtonItem *_doneBBItem;
    UIView *_attachView;
    CGRect _currentKeyBoardRect;
}

/*!
 @property
 @abstract 表单
 */
@property (strong, nonatomic) UIScrollView *inputform;

/*!
 @property
 @abstract 当前的输入控件
 */
@property (strong, nonatomic) UIView *inputView;

/*!
 @property
 @abstract 所有的输入框
 */
@property (strong, nonatomic) NSMutableDictionary *inputs;

/*!
 @property
 @abstract 取值的委托，需要实现LCGetValueDelegate
 */
@property (strong, nonatomic) id getValueDelegate;

/*!
 @method
 @abstract 取下一个输入项, 应该重载。
 */
- (UIView *)getNextInputControl:(UIView *)current;

- (BOOL)isVisable:(UIView *)view;

- (void)goToNextInput;

- (BOOL)ifCurrentLastInput;

- (BOOL)ifShowAttachView;

- (void)addDoneButtonInKeyboard:(CGRect)keyboardRect duration:(NSTimeInterval)duration;

/*!
 @method
 @abstract 加入输入控件
 @param control
 @param tag
 @name
 */
- (void)addInput:(id)control
        sequence:(long)tag
            name:(NSString *)name;

/*!
 @param seq 顺序标记
 @param error 错误提示
 @abstract 监测是否为空，如果不是返回YES
 */
- (BOOL)checkRequired:(NSInteger)seq errorMessage:(NSString *)error;

/*!
 @param seq1 顺序标记1
 @param seq2 顺序标记2
 @param error 错误提示
 @abstract 监测seq1是否等于seq2
 */
- (BOOL)checkEqual:(NSInteger)seq1 to:(NSInteger)seq2 errorMessage:(NSString *)error;

/*!
 @param seq 顺序标记
 @param value 字符串值
 @param error 错误提示
 @abstract 监测是否等于给定值
 */
- (BOOL)checkEqual:(NSInteger)seq toValue:(NSString *)value errorMessage:(NSString *)error;

- (NSString *)getValueForSeq:(NSInteger)seq;

/*!
 @method
 @abstract 将取值加入到字典类型中。需先调用getInputValues方法。
 @result 字典对象
 */
- (id)createParameter;

/*!
 @method
 @abstract 取所有的输入值
 */
- (void)getInputValues;

/*!
 @method
 @abstract 点击背景，关闭输入键盘
 */
- (IBAction)backgroundTap:(id)sender;

/*!
 @method
 @abstract 关闭键盘
 */
- (void)hideKeyboard;

/*!
 @method
 @abstract
 */
- (void)setValue:(NSString *)val toSeq:(NSInteger)seq;

- (void)whenTextFieldEndEditing:(UITextField *)textField changeLabel:(UILabel *)label format:(NSString *)format;

- (void)whenTextFieldEndEditing:(UITextField *)textField toTarget:(id)target action:(SEL)action;

/*!
 @method
 @param seq
 @param min
 @param max
 @param error
 *@abstract 检测长度
 */
- (BOOL)checkLength:(NSInteger)seq min:(NSUInteger)min max:(NSUInteger)max errorMessage:(NSString *)error;

/*!
 @method
 @param seq
 @param error
 @abstract 检测身份证号码
 */
- (BOOL)checkPersonId:(NSInteger)seq errorMessage:(NSString *)error;

/*!
 @method
 @param seq
 @param error
 @abstract 检测是否是数字
 */
- (BOOL)checkNumber:(NSInteger)seq errorMessage:(NSString *)error;

/*!
 @method
 @param seq
 @param length
 @param error
 @abstract 检测某个长度的数字
 */
- (BOOL)checkNumber:(NSInteger)seq withLenth:(NSUInteger)length errorMessage:(NSString *)error;

/*!
 @method
 @param seq
 @param regex
 @param error
 @abstract 检测是否符合正则表达式
 */
- (BOOL)check:(NSInteger)seq match:(NSString *)regex errorMessage:(NSString *)error;

// 显示提示
- (void)showTip:(NSString *)tip title:(NSString *)title;

//启用/禁用键盘监听事件
- (void)enableKeyboardObserve:(BOOL)enable;

@end
