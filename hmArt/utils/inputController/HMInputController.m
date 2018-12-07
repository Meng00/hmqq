//
//  HMInputController.m
//  hmArt
//
//  Created by wangyong on 13-7-9.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import "HMInputController.h"

@interface HMInputController ()

@end

@implementation HMInputController

@synthesize inputform = _form;
@synthesize inputView = _inputView;
@synthesize inputs = _inputs;
@synthesize getValueDelegate = _getValueDelegate;


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    
    self.inputs = [[NSMutableDictionary alloc] init];
    _inputsArray = [[NSMutableArray alloc] init];
    _actionsWhenTextFieldEndEditing = [[NSMutableArray alloc] init];
    
    //_attachView = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 0, 60, 32)];
    _attachView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 32)];
    
    _attachView.backgroundColor = [UIColor colorWithRed:210.0/255.0 green:213.0/255.0 blue:220.0/255.0 alpha:0.9];
    
    //　添加一个TOOLBAR
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, -2, [UIScreen mainScreen].bounds.size.width, 36)];
    toolbar.barStyle = UIBarStyleDefault;
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    //UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    //[barItems addObject:flexSpace];
    
    _prevBBItem = [[UIBarButtonItem alloc] initWithTitle:@"上一项" style:UIBarButtonItemStyleDone target:self action:@selector(goToPrevInput)];
    [barItems addObject:_prevBBItem];
    _prevBBItem.width = 60;
    
    _nextBBItem = [[UIBarButtonItem alloc] initWithTitle:@"下一项" style:UIBarButtonItemStyleDone target:self action:@selector(goToNextInput)];
    [barItems addObject:_nextBBItem];
    _nextBBItem.width = 60;
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [barItems addObject:flexSpace];
    flexSpace.width = 160;
    
    _doneBBItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonDown)];
    [barItems addObject:_doneBBItem];
    _doneBBItem.width = 60;
    
    //flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    //[barItems addObject:flexSpace];
    
    [toolbar setItems:barItems animated:YES];
    [_attachView addSubview:toolbar];
    
    [HMUtility addRoundCorner:_attachView withRadius:10 onTopLeft:YES onTopRight:NO onBottomLeft:NO onBottonRight:NO];
    
}

- (void)viewDidUnload
{
    [self setInputView:nil];
    [self setInputs:nil];
    _inputsArray = nil;
    [_actionsWhenTextFieldEndEditing removeAllObjects];
    _actionsWhenTextFieldEndEditing = nil;
    _attachView = nil;
    _nextBBItem = nil;
    _prevBBItem = nil;
    _doneBBItem = nil;
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 加入对键盘通知的监听
    // 1. 键盘将要显示
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    // 2. 键盘将要消失
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 单击事件
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    
    // prevents the scroll view from swallowing up the touch event of child buttons
    tapGesture.cancelsTouchesInView = NO;
    
    [self.inputform addGestureRecognizer:tapGesture];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //　取消对键盘通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
    [self hideKeyboard];
    [super viewWillDisappear:animated];
}

- (void)enableKeyboardObserve:(BOOL)enable
{
    if (!enable) {
        //　取消对键盘通知
        [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
        [self hideKeyboard];
    }else{
        // 加入对键盘通知的监听
        // 1. 键盘将要显示
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        // 2. 键盘将要消失
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    _inputView = textView;
    return YES;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // 设置当前输入控件
    _inputView = textField;
    // 是否需要显示attachView;
    
    if ([self ifShowAttachView]) {
        [self addDoneButtonInKeyboard:_currentKeyBoardRect duration:0];
    } else {
        [_attachView removeFromSuperview];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    for (HMEventAction *action in _actionsWhenTextFieldEndEditing) {
        if (action.source == textField) {
            if (action.action) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [action.target performSelector:action.action withObject:textField];
#pragma clang diagnostic pop
            } else {
                if (action.format) {
                    NSString *val = [NSString stringWithFormat:action.format, textField.text];
                    [action.target setText:val];
                } else {
                    [action.target setText:textField.text];
                }
            }
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // 当前输入框去掉首要响应者
    [textField resignFirstResponder];
    
    UIView *f = [self getNextInputControl:textField];
    
    // 如果存在，则变成首要相应者
    if (f)
        [f becomeFirstResponder];
    else
        return YES;
    
    return NO;
}

- (void)goToNextInput
{
    if (_inputView) {
        [_inputView resignFirstResponder];
        UIView *f = [self getNextInputControl:_inputView];
        
        if (f)
            [f becomeFirstResponder];
    }
}

- (void)goToPrevInput
{
    if (_inputView) {
        [_inputView resignFirstResponder];
        UIView *f = [self getPrevInputControl:_inputView];
        
        if (f)
            [f becomeFirstResponder];
    }
}

- (void)doneButtonDown
{
    if (_inputView) {
        [_inputView resignFirstResponder];
    }
}

- (UIView *)getPrevInputControl:(UIView *)current
{
    // 查找下一个输入框
    UIView *ctrl = nil;
    for (HMInputCtrl *lctrl in _inputsArray) {
        if (current == lctrl.input){
            return ctrl;
        } else {
            if ([self isVisable:(UIView *)lctrl.input] && [lctrl keyBoardInput]) ctrl = lctrl.input;
        }
    }
    
    return ctrl;
}

- (UIView *)getNextInputControl:(UIView *)current
{
    // 查找下一个输入框
    UIView *ctrl = nil;
    BOOL begin = NO;
    for (HMInputCtrl *lctrl in _inputsArray) {
        if (current == lctrl.input) {
            begin = YES;
            continue;
        }
        if (begin) {
            if (!lctrl.keyBoardInput) continue;
            if (![self isVisable:(UIView *)lctrl.input]) continue;
            ctrl = lctrl.input;
            break;
        }
    }
    
    return ctrl;
}

- (IBAction)backgroundTap:(id)sender
{
    [self hideKeyboard];
}

- (void)hideKeyboard
{
    if (_attachView) {
        [_attachView removeFromSuperview];
    }
    if (_inputView != nil)
        [_inputView resignFirstResponder];
}

- (BOOL)ifCurrentLastInput
{
    NSUInteger i = 0;
    BOOL begin = NO;
    for (; i < _inputsArray.count; ++i) {
        HMInputCtrl *lctrl = [_inputsArray objectAtIndex:i];
        if (_inputView == lctrl.input) {
            begin = YES;
            continue;
        }
        if (begin) {
            if ([self isVisable:((UIView *)lctrl.input)]) {
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)ifCurrentFirstInput
{
    NSUInteger i = 0;
    for (; i < _inputsArray.count; ++i) {
        HMInputCtrl *lctrl = [_inputsArray objectAtIndex:i];
        if (_inputView != lctrl.input) {
            if ([self isVisable:((UIView *)lctrl.input)] && [lctrl keyBoardInput]) {
                return NO;
            } else {
                continue;
            }
        } else {
            return YES;
        }
    }
    return YES;
}

- (BOOL)isVisable:(UIView *)view
{
    UIView *v = view;
    while (!v.hidden) {
        v = v.superview;
        if (v == nil)
            return  YES;
    }
    return NO;
}

- (BOOL)ifShowAttachView
{
    /*BOOL showAttachView = NO;
     if ([_inputView isKindOfClass:[UITextView class]]) {
     showAttachView = YES;
     } else if ([_inputView isKindOfClass:[UITextField class]]) {
     UITextField *f = (UITextField *)_inputView;
     if (f.keyboardType == UIKeyboardTypeNumberPad || f.keyboardType == UIKeyboardTypePhonePad) {
     showAttachView = YES;
     }
     }
     if ([self ifCurrentLastInput]) {
     _nextBBItem.title = @"完成";
     } else {
     _nextBBItem.title = @"下一项";
     }*/
    BOOL showAttachView = YES;
    if ([self ifCurrentFirstInput]) {
        _prevBBItem.enabled = NO;
    } else {
        _prevBBItem.enabled = YES;
    }
    if ([self ifCurrentLastInput]) {
        _nextBBItem.enabled = NO;
    } else {
        _nextBBItem.enabled = YES;
    }
    return showAttachView;
}

#pragma mark - keyborddelegate
- (void)keyboardWillShow:(NSNotification *)notification {
    
    // 计算键盘的位置
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    _currentKeyBoardRect = [aValue CGRectValue];
    
    
    //CGRect keyboardRect = [self.view convertRect:_currentKeyBoardRect fromView:nil];
    CGRect keyboardRect = [self.inputform convertRect:_currentKeyBoardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    
    // 计算当前输入框的位置
    CGFloat offset = [HMUtility caculLocation:_inputView referenceView:self.inputform].y;
    
    
    // 当前的滚动视图的内容偏移量（保存，以便恢复）
    formOffset = _form.contentOffset;
    
    CGPoint newOffset = formOffset;
    
    // 输入框下部相对屏幕的偏移量，需要加上之前滚蛋哦给你视图的偏移量，否则在同一个input中切换输入法时，由于目前
    //中文拼音输入法会出现一行选字框导致高度变化，而不能移动input和输入法的位置
    offset += _inputView.frame.size.height + 10 + _attachView.frame.size.height + formOffset.y;
    
    //  相对于键盘的位置
    CGFloat y = offset - keyboardTop;
    
    // 如果键盘位置高于输入框
    //if (y > 0)    //点击上一项时将视图向上翻滚,如果判断y>0，则当键盘低于输入框下面
    newOffset.y += y;
    //避免输入框在界面上端时下拉
    if (newOffset.y < 0) {
        newOffset.y = 0;
    }
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:@"HM_Input_Controller" context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    _form.contentOffset = newOffset;
    [UIView commitAnimations];
    
    if ([self ifShowAttachView])
        [self addDoneButtonInKeyboard:_currentKeyBoardRect duration:animationDuration];
    
}

- (void)addDoneButtonInKeyboard:(CGRect)keyboardRect duration:(NSTimeInterval)duration
{
    if ([[[UIApplication sharedApplication] windows] count] > 1) {
        UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
        CGRect frame = CGRectMake(_attachView.frame.origin.x, keyboardRect.origin.y - _attachView.frame.size.height, _attachView.frame.size.width, _attachView.frame.size.height);
        _attachView.frame = frame;
        [tempWindow performSelector:@selector(addSubview:) withObject:_attachView afterDelay:duration];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    [_attachView removeFromSuperview];
    
    NSDictionary* userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    // 还原位置
    CGFloat contentHeight = _form.contentSize.height;
    
    if (contentHeight == 0) { // 矫正contentSize返回0的问题
        for (UIView *v in _form.subviews) {
            if (!v.hidden && v.opaque == YES && v.alpha > 0 &&
                v.frame.origin.y + v.frame.size.height > contentHeight) {
                contentHeight = v.frame.origin.y + v.frame.size.height;
            }
        }
    }
    
    // 计算滚动超出实际内容的空白高度
    CGFloat offset = _form.contentOffset.y + _form.frame.size.height - contentHeight;
    
    if (offset > 0) { // 需要回滚
        offset = _form.contentOffset.y - offset;
        if(offset < 0) offset = 0;
        _form.contentOffset = CGPointMake(_form.contentOffset.x, offset);
    }
    
    [UIView commitAnimations];
}

- (void)addInput:(id)control
        sequence:(long)tag
            name:(NSString *)name
{
    HMInputCtrl *ctrl = [[HMInputCtrl alloc] init];
    ctrl.input = control;
    ctrl.name = name;
    ctrl.sequence = tag;
    
    ((UIView *)control).tag = tag;
    
    if ([control isKindOfClass:[UITextField class]]) {
        ctrl.keyBoardInput = YES;
        UITextField *fld = (UITextField *)control;
        if (!fld.delegate)
            fld.delegate = self;
    } else if ([control isKindOfClass:[UITextView class]]) {
        ctrl.keyBoardInput = YES;
        UITextView *fld = (UITextView *)control;
        if (!fld.delegate)
            fld.delegate = self;
    } else
        ctrl.keyBoardInput = NO;
    
    [_inputs setValue:ctrl
               forKey:[NSString stringWithFormat:@"%ld", tag]];
    [_inputsArray addObject:ctrl];
    
}

- (void)getInputValues
{
    [_inputs enumerateKeysAndObjectsUsingBlock:
     ^(__strong id key, __strong id obj, BOOL *stop) {
         HMInputCtrl *inputCtrl = obj;
         
         inputCtrl.value = nil;
         
         [self.getValueDelegate getValueFromInputCtrl:inputCtrl];
         
         // 如果没有取值，则从控件里读出
         if (!inputCtrl.value) {
             
             id ctrl = inputCtrl.input;
             id val = nil;
             
             if ([ctrl isKindOfClass: [UITextField class]]) {
                 // 对输入框
                 UITextField *f = ctrl;
                 val = f.text;
                 
             } else if ([ctrl isKindOfClass:[UISwitch class]]) {
                 // 对Switch开关
                 UISwitch *f = ctrl;
                 val = [NSNumber numberWithBool:f.on];
                 
             } else if ([ctrl isKindOfClass:[UISlider class]]) {
                 // 对UISlide开关
                 UISlider *f = ctrl;
                 val = [NSNumber numberWithFloat:f.value];
                 
             } else if ([ctrl isKindOfClass:[UITextView class]]) {
                 // 对UITextView开关
                 UITextView *f = ctrl;
                 val = f.text;
                 
             } else if ([ctrl isKindOfClass:[UIDatePicker class]]) {
                 // 对DatePicker开关
                 UIDatePicker *f = ctrl;
                 val = f.date;
             } else if ([ctrl isKindOfClass:[UISegmentedControl class]]) {
                 UISegmentedControl *f = ctrl;
                 val = [NSNumber numberWithInteger: [f selectedSegmentIndex]];
             } else if ([ctrl isKindOfClass:[UILabel class]]) {
                 UILabel *f = ctrl;
                 val = f.text;
             }
             
             inputCtrl.value = val;
         }
     }
     ];
    
}

- (id)createParameter
{
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
    
    [_inputs enumerateKeysAndObjectsUsingBlock:
     ^(__strong id key, __strong id obj, BOOL *stop) {
         HMInputCtrl *inputCtrl = obj;
         
         if (inputCtrl.name && inputCtrl.value) {
             [ret setObject:inputCtrl.value forKey:inputCtrl.name];
         }
     }
     ];
    
    return ret;
}

- (BOOL)checkRequired:(NSInteger)seq errorMessage:(NSString *)error
{
    HMInputCtrl *ctrl = [self.inputs objectForKey:[NSString stringWithFormat:@"%d", seq]];
    if (ctrl.value && [ctrl.value length] > 0)
        return YES;
    
    if (error) {
        [self showTip:error title:@"提示"];
        [ctrl.input becomeFirstResponder];
    }
    return NO;
}

- (BOOL)checkLength:(NSInteger)seq min:(NSUInteger)min max:(NSUInteger)max errorMessage:(NSString *)error
{
    HMInputCtrl *ctrl = [self.inputs objectForKey:[NSString stringWithFormat:@"%d", seq]];
    BOOL check = [HMTextChecker checkLength:ctrl.value min:min max:max];
    
    if (check)
        return YES;
    
    if (error) {
        [self showTip:error title:@"提示"];
        [ctrl.input becomeFirstResponder];
    }
    return NO;
}

- (BOOL)checkPersonId:(NSInteger)seq errorMessage:(NSString *)error
{
    HMInputCtrl *ctrl = [self.inputs objectForKey:[NSString stringWithFormat:@"%d", seq]];
    if (ctrl.value && [ctrl.value length] > 0) {
        if ([HMTextChecker checkID:ctrl.value]) {
            return YES;
        }
    }
    
    if (error) {
        [self showTip:error title:@"提示"];
        [ctrl.input becomeFirstResponder];
    }
    return NO;
}

- (BOOL)checkNumber:(NSInteger)seq errorMessage:(NSString *)error
{
    HMInputCtrl *ctrl = [self.inputs objectForKey:[NSString stringWithFormat:@"%d", seq]];
    if (ctrl.value && [ctrl.value length] > 0) {
        if ([HMTextChecker checkIsNumber:ctrl.value]) {
            return YES;
        }
    }
    
    if (error) {
        [self showTip:error title:@"提示"];
        [ctrl.input becomeFirstResponder];
    }
    return NO;
}

- (BOOL)checkNumber:(NSInteger)seq withLenth:(NSUInteger)length errorMessage:(NSString *)error
{
    HMInputCtrl *ctrl = [self.inputs objectForKey:[NSString stringWithFormat:@"%d", seq]];
    if (ctrl.value && [ctrl.value length] > 0) {
        if ([HMTextChecker checkIsNumber:ctrl.value withLength:length]) {
            return YES;
        }
    }
    
    if (error) {
        [self showTip:error title:@"提示"];
        [ctrl.input becomeFirstResponder];
    }
    return NO;
}

- (BOOL)checkEqual:(NSInteger)seq1 to:(NSInteger)seq2 errorMessage:(NSString *)error
{
    HMInputCtrl *ctrl1 = [self.inputs objectForKey:[NSString stringWithFormat:@"%d", seq1]];
    HMInputCtrl *ctrl2 = [self.inputs objectForKey:[NSString stringWithFormat:@"%d", seq2]];
    if (!ctrl1.value && !ctrl2.value)
        return YES;
    
    if (ctrl1.value && ctrl2.value && [ctrl1.value isEqualToString:ctrl2.value])
        return YES;
    
    if (error) {
        [self showTip:error title:@"提示"];
        [ctrl1.input becomeFirstResponder];
    }
    
    return NO;
}

- (BOOL)checkEqual:(NSInteger)seq toValue:(NSString *)value errorMessage:(NSString *)error
{
    HMInputCtrl *ctrl = [self.inputs objectForKey:[NSString stringWithFormat:@"%d", seq]];
    if (ctrl.value && [ctrl.value isEqualToString:value])
        return YES;
    
    if (error) {
        [self showTip:error title:@"提示"];
        [ctrl.input becomeFirstResponder];
    }
    return NO;
}

- (BOOL)check:(NSInteger)seq match:(NSString *)regex errorMessage:(NSString *)error
{
    HMInputCtrl *ctrl = [self.inputs objectForKey:[NSString stringWithFormat:@"%d", seq]];
    if (ctrl.value) {
        NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if ([test evaluateWithObject:ctrl.value])
            return YES;
    }
    
    if (error) {
        [self showTip:error title:@"提示"];
        [ctrl.input becomeFirstResponder];
    }
    return NO;
}

- (NSString *)getValueForSeq:(NSInteger)seq
{
    HMInputCtrl *ctrl = [self.inputs objectForKey:[NSString stringWithFormat:@"%d", seq]];
    return ctrl.value;
}

- (void)setValue:(NSString *)val toSeq:(NSInteger)seq
{
    HMInputCtrl *ctrl = [self.inputs objectForKey:[NSString stringWithFormat:@"%d", seq]];
    if ([val isEqual:[NSNull null]]) val = @"";
    [ctrl.input setText:val];
}

- (void)whenTextFieldEndEditing:(UITextField *)textField changeLabel:(UILabel *)label format:(NSString *)format
{
    HMEventAction *ea = [[HMEventAction alloc] init];
    ea.source = textField;
    ea.target = label;
    ea.format = format;
    
    [_actionsWhenTextFieldEndEditing addObject:ea];
}

- (void)whenTextFieldEndEditing:(UITextField *)textField toTarget:(id)target action:(SEL)action
{
    HMEventAction *ea = [[HMEventAction alloc] init];
    ea.source = textField;
    ea.target = target;
    ea.action = action;
    
    [_actionsWhenTextFieldEndEditing addObject:ea];
}

- (void)showTip:(NSString *)tip title:(NSString *)title
{
    [HMUtility showTip:tip inView:self.view];
    //    [LCUtility alert:tip title:title];
}

@end
