//
//  HMArtistInfo.h
//  hmArt
//
//  Created by wangyong on 13-7-11.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMNetImageView.h"

@interface HMArtistDetail : UIViewController
{
    unsigned int _requestId;
    NSString *_resume;
    NSMutableDictionary *_artistInfo;
}
@property (nonatomic) NSInteger artistId;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet HMNetImageView *portraitImage;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *birthLabel;
@property (strong, nonatomic) IBOutlet UILabel *hometownLabel;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *starlevelImages;
@property (strong, nonatomic) IBOutlet UILabel *resumeLabel;
@property (strong, nonatomic) IBOutlet UIView *buttonView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
- (IBAction)infoButtonDown:(UIButton *)sender;
- (IBAction)pictureButtonDown:(UIButton *)sender;
- (IBAction)priceButtonDown:(id)sender;

- (void)setParams:(NSString *)params;
@property (strong, nonatomic) IBOutlet UIImageView *icons;

@end
