//
//  HMPaintingDetail.h
//  hmArt
//
//  Created by wangyong on 14-8-19.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMNetImageView.h"
#import "HMUtility.h"
#import "LCNetworkInterface.h"
#import <ShareSDK/ShareSDK.h>
#import "LCAlertView.h"
#import "HMLoginEx.h"
#import "HMImageZoomView.h"
#import "LCActionSheet.h"

@interface HMPaintingDetail : UIViewController <HMImageZommViewDelegate>
{
    unsigned int _requestId;
    unsigned int _requestImageId;
    NSDictionary *_paintingInfo;
    BOOL _hiddenBar;
}
@property (nonatomic) NSInteger paintingId;
@property (nonatomic) NSInteger source;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet HMNetImageView *pictureImage;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

- (void)setParams:(NSString *)params;
- (IBAction)shareButtonDown:(id)sender;
- (IBAction)favoriteButtonDown:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *fullImageView;
@end
