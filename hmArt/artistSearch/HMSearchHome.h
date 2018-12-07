//
//  HMSearchHome.h
//  hmArt
//
//  Created by wangyong on 14-8-17.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMInputController.h"
#import "HMNetImageView.h"
#import "LCGlobalSelector.h"
#import "HMGalleryCategory.h"
#import "HMUtility.h"
#import "HMArtistDetail.h"
#import "HMPictureList.h"
#import "HMArtistList.h"
#import "HMPaintingDetail.h"
#import "LCUniverseSelector.h"

@interface HMSearchHome : HMInputController <globalSelectorDataSource, globalSelectorDelegate, LCUniverseSelectorDataSource, LCUniverseSelectorDelegate>
{
    NSArray *_searchType;
    NSInteger _curSearchType;
    NSUInteger _curSelector;
    
    NSArray *_priceItems;
    NSInteger _curPriceIndex;
    
    NSArray *_cityArray;
    unsigned int _requestCityId;
    
    NSInteger _tmpProvinceRow;
    NSInteger _selectedProvinceRow;
    NSInteger _selectedCityRow;
    
    unsigned int _requestArtistId;    
    unsigned int _requestArtWorkId;
    NSMutableArray *_artistRecItems;
    NSMutableArray *_artWorkRecItems;
    
    BOOL _artDataLoad;
    BOOL _paintDataLoad;
}
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *formView;
@property (strong, nonatomic) IBOutlet UIView *nameView;
@property (strong, nonatomic) IBOutlet UIView *priceView;
@property (strong, nonatomic) IBOutlet UIView *cityView;
@property (strong, nonatomic) IBOutlet UITextField *nameText;
@property (strong, nonatomic) IBOutlet UILabel *searchTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceSelectLabel;
@property (strong, nonatomic) IBOutlet UILabel *cityLabel;
@property (strong, nonatomic) IBOutlet UILabel *citySelectLabel;
@property (strong, nonatomic) IBOutlet UIView *artistView;
@property (strong, nonatomic) IBOutlet UIView *paintingView;
@property (strong, nonatomic) IBOutletCollection(HMNetImageView) NSArray *artistItems;
@property (strong, nonatomic) IBOutletCollection(HMNetImageView) NSArray *paintingItems;
- (IBAction)searchButtonDown:(id)sender;
@end
