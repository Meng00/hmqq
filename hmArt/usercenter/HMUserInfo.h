//
//  HMUserInfo.h
//  hmArt
//
//  Created by wangyong on 14-8-13.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMInputController.h"
#import "HMGlobal.h"
#import "DCRoundSwitch.h"
#import "HMChgPass.h"
#import "HMChgMobile.h"
#import "LCNetworkInterface.h"
#import "LCActionSheet.h"
#import "LCUniverseSelector.h"
#import "ITTCalendarView.h"

@interface HMUserInfo : HMInputController<LCUniverseSelectorDataSource, LCUniverseSelectorDelegate, ITTCalendarViewDelegate>

{
    HMGlobalParams *params;
//    NSInteger _cityId;
    unsigned int _requestId;
    unsigned int _requestCityId;
    unsigned int _requesUserInfotId;
  
//    NSString *_cityName;
    NSArray *_cityArray;
    
    NSString *_city;
    NSString *_province;
    
    NSInteger _selectedProvinceRow;
    NSInteger _selectedCityRow;
    NSInteger _tmpProvinceRow;
    
    NSDate *_birthDate;
}
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (strong, nonatomic) IBOutlet UITextField *nameText;
@property (strong, nonatomic) IBOutlet DCRoundSwitch *genderSwitch;
//@property (strong, nonatomic) IBOutlet UITextField *birthText;
@property (strong, nonatomic) IBOutlet UILabel *birthLabel;
@property (strong, nonatomic) IBOutlet UILabel *birthArrow;
@property (strong, nonatomic) IBOutlet UITextField *workText;
@property (strong, nonatomic) IBOutlet UILabel *cityLabel;
@property (strong, nonatomic) IBOutlet UILabel *cityArrow;
@property (strong, nonatomic) IBOutlet UITextField *addressText;

@property (strong, nonatomic) IBOutlet UIView *changePwdView;
@property (strong, nonatomic) IBOutlet UIView *changeMobileView;
@property (strong, nonatomic) IBOutlet UIView *formView;
- (IBAction)buttonClick:(id)sender;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@end
