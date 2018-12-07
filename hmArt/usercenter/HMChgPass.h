//
//  HMChgPass.h
//  hmArt
//
//  Created by wangyong on 14-8-13.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMInputController.h"
#import "HMGlobal.h"
#import "LCNetworkInterface.h"
@interface HMChgPass : HMInputController
{
    unsigned int _requestId;

}
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *formView;
@property (strong, nonatomic) IBOutlet UITextField *pwdText;
@property (strong, nonatomic) IBOutlet UITextField *confirmPwd;
@property (strong, nonatomic) IBOutlet UITextField *oldPwdText;
- (IBAction)ButtonClick:(id)sender;
@end
