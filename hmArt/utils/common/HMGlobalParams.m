//
//  HMGlobalParams.m
//  hmArt
//
//  Created by wangyong on 13-7-10.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import "HMGlobalParams.h"

static HMGlobalParams *single;

@implementation HMGlobalParams

+ (HMGlobalParams *)sharedInstance
{
    if (single == nil) {
        single = [[super allocWithZone:nil] init];
        
        single.anonymous = YES;
        single.categorys = [[NSMutableArray alloc] initWithCapacity:1];
        single.appendUserAgentSuffix = NO;
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"HMAuctionRecords",@"AuctionRecord",
                             @"HMGalleryCategory", @"GalleryCategory",
                             @"HMAuctionArea", @"AuctionArea",
                             @"HMAuctionDetail", @"AuctionDetail",
                             @"HMAuctionPreview", @"AuctionPreview",
                             @"HMArtistList", @"ArtistList",
                             @"HMArtistDetail", @"Artist",
                             @"HMPictureList", @"PaintingList",
                             @"HMPaintingDetail", @"PaintingDetail",
                             @"HMNewsList", @"IndustryNews",
                             @"HMPushMessages", @"PushNews",
                             @"HMLoginEx", @"Login",
                             @"HMRegistEx", @"Regist",
                             @"HMAuctioneerHome", @"AuctioneerHome",
                             @"HMAllianceGroup", @"AllianceGroup",
                             @"HMJSWebView", @"JSWEBAPP",
                             @"HMMemberFeedback", @"Feedback",
                             @"HMUpgradeVIP", @"UpgradeVIP",
                             @"HMChgPass", @"ChgPass",
                             @"HMAuctOrders", @"AuctOrders",
                             nil];
        
        single.classNames = [NSDictionary dictionaryWithDictionary:dic];

    }
    
    return single;
    
}
+ (id)alloc
{
    return nil;
}

+ (id)new
{
    return [self alloc];
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self alloc];
}

+ (id)copyWithZone:(NSZone *)zone
{
    return self;
}

+ (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone:zone];
}

@end
