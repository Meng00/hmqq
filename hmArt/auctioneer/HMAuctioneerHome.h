//
//  HMAuctioneerHome.h
//  hmArt
//
//  Created by 刘学 on 15-7-6.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMGlobal.h"
#import "HMIconView.h"
#import "HMUtility.h"
#import "HMNetImageView.h"
#import "HMAuctioneerArtwords.h"

@interface HMAuctioneerHome : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>
{
    unsigned int _requestId;
    NSMutableArray *_items;
    NSMutableArray *_resultArray;
}
@property (copy, nonatomic) NSString *titleName;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

- (void)setParams:(NSString *)params;
@end
