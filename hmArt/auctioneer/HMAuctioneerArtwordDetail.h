//
//  HMAuctioneerArtwordDetail.h
//  hmArt
//
//  Created by 刘学 on 15-7-7.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMUtility.h"
#import "HMGlobalParams.h"
#import "LCNetworkInterface.h"
#import "LCView.h"
#import "HMNetImageView.h"
#import <ShareSDK/ShareSDK.h>
#import "HMImageZoomView.h"
#import "HMInputController.h"
#import "LCAlertView.h"
#import "LCActionSheet.h"

@interface HMAuctioneerArtwordDetail : HMInputController<HMImageZommViewDelegate>
{
    unsigned int _requestImageId;
    unsigned int _requestId;
    NSDictionary *dic;
    LCView *_topView;
    
    BOOL _hiddenBar;
}

@property (nonatomic) NSInteger artworkId;
@property (copy, nonatomic) NSString *auctioneerName;
@property (copy, nonatomic) NSString *auctioneerImage;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (strong, nonatomic) IBOutlet UIView *fullImageView;

@end
