//
//  HMRegistEx.h
//  hmArt
//
//  Created by wangyong on 14-8-13.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMInputController.h"
#import "HMGlobal.h"
#import "HMUtility.h"
#import "HMTextChecker.h"
#include "LCNetworkInterface.h"
#import "LCAnimationUtility.h"
#import "HMModalBaseView.h"
#import "HMLoginEx.h"
@interface HMRegistEx : HMInputController
{
    unsigned int _requestId;
    NSString *_authSerial;
    BOOL _canSendAuthCode;
    NSTimer *_timer;
    NSDate *_sentDate;
    BOOL _stopCountDown;
  
    NSString *_pass;
    NSString *_mobile;
    NSString *_proCodes;

}
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (strong, nonatomic) IBOutlet UITextField *mobileText;
@property (strong, nonatomic) IBOutlet UITextField *pwdText;
@property (weak, nonatomic) IBOutlet UITextField *proxyCodeText;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)registButtonDown:(id)sender;
- (IBAction)smsButtonDown:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *formView;
@property (strong, nonatomic) IBOutlet UIButton *smsButton;


@end
