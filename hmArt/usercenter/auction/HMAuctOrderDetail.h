//
//  HMAuctOrderDetail.h
//  hmArt
//
//  Created by 刘学 on 15/7/11.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMUtility.h"
#import "HMGlobalParams.h"
#import "LCNetworkInterface.h"
#import "LCView.h"
#import "HMNetImageView.h"
#import "HMInputController.h"
#import "HMArtworkDetail.h"
#import "HMSalesRequest.h"

@interface HMAuctOrderDetail :HMInputController
{
    unsigned int _requestImageId;
    unsigned int _requestId;
    NSDictionary *dic;
    LCView *_topView;
    
}

@property (nonatomic) NSInteger orderId;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end
