//
//  HMInformation.h
//  hmArt
//
//  Created by wangyong on 13-7-8.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMGlobal.h"
#import "HMNetImageView.h"

@interface HMInformation : UIViewController
{
    
}
- (id)initWithTitle:(NSString *)title;

@property (nonatomic) BOOL showListButton;
@property (nonatomic)NSInteger infoType;
@property (strong, nonatomic) NSArray *framesArray;
@property (strong, nonatomic) NSDictionary *infoDictionary;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

- (void)layoutInformation;
@end
