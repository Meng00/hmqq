//
//  HMLoginEx.h
//  hmArt
//
//  Created by wangyong on 14-8-13.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//
#import "HMInputController.h"
#import "HMGlobal.h"
#import "HMRegistEx.h"
#import "HMFindPassword.h"
#import "HMGlobalParams.h"
#import "HMAdImageViewLogin.h"
#import "EasyJSDataFunction.h"

@protocol HMJsLoginDelegate <NSObject>
-(void) loginResult:(BOOL) result func:(EasyJSDataFunction*) func;
@end

@interface HMLoginEx : HMInputController
{
    unsigned int _requestId;
    NSString *_pass;
    unsigned int _requestAdId;
}
@property (nonatomic) BOOL hideBackButton;

@property(nonatomic,retain) id<HMJsLoginDelegate> delegate;
@property (strong, nonatomic) EasyJSDataFunction *func;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (strong, nonatomic) IBOutlet UITextField *mobileText;
@property (strong, nonatomic) IBOutlet UITextField *pwdText;
@property (strong, nonatomic) IBOutlet HMAdImageViewLogin *adImageView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *registView;
- (IBAction)loginButtonDown:(id)sender;
- (IBAction)forgetButtonDown:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *formView;
@end
