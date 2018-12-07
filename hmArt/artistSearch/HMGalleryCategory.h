//
//  HMGalleryCategory.h
//  hmArt
//
//  Created by wangyong on 14-8-18.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMGlobal.h"
#import "HMIconView.h"
#import "HMUtility.h"
#import "HMPictureList.h"
#import "HMSearchHome.h"
@interface HMGalleryCategory : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>
{
    unsigned int _requestId;
    NSMutableArray *_items;
    NSMutableArray *_resultArray;
}

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end
