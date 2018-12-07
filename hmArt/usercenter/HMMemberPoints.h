//
//  HMMemberPoints.h
//  hmArt
//
//  Created by wangyong on 14-8-14.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMGlobal.h"
#import "HMNetImageView.h"
#import "HMMemberPointProduct.h"
#import "HMMemberPointRecords.h"
@interface HMMemberPoints : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSMutableArray *_items;
    unsigned int _requestCateId;
    

}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@end
