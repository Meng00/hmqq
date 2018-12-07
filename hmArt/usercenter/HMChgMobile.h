//
//  HMChgMobile.h
//  hmArt
//
//  Created by wangyong on 14-8-13.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMInputController.h"
#import "HMGlobal.h"
#import "LCNetworkInterface.h"
@interface HMChgMobile : HMInputController
{
    unsigned int _requestId;    
    BOOL _canSendAuthCode;
    NSTimer *_timer;
    NSDate *_sentDate;
    BOOL _stopCountDown;

    NSString *_newMobile;
}
@property (strong, nonatomic) IBOutlet UIButton *smsButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *formView;
@property (strong, nonatomic) IBOutlet UITextField *pwdText;
@property (strong, nonatomic) IBOutlet UITextField *mobileText;
- (IBAction)resetSendSms:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *verifyCodeText;
- (IBAction)buttonClick:(id)sender;
@end
