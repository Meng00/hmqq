//
//  LCMapLocate.h
//  lifeassistant
//
//  Created by wangyong on 14-6-11.
//
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI/BMapKit.h>

@interface LCMapLocationResult : NSObject

//定位结果：0-成功，1-未开启定位功能，2-定位成功但反geo失败，3-其它失败原因
@property (nonatomic) NSInteger result;

//反geo结果，成功返回地址，不成功返回空串
@property (nonatomic, copy) NSString *address;

//反geo结果，成功返回地址，不成功返回空串
@property (nonatomic, copy) NSString *city;

//定位结果经纬度
@property (nonatomic) CLLocationCoordinate2D pt;

//result!=0时的原因，成功时为空
@property (nonatomic ,copy) NSString *errMessage;

@property (nonatomic, copy) id object;

@end

@protocol LCMapLocateDelegate <NSObject>

@required
- (void)didUpdateLocation:(LCMapLocationResult *)result;

@end


@interface LCMapLocate : NSObject <BMKGeoCodeSearchDelegate, BMKLocationServiceDelegate>
{
    BMKGeoCodeSearch *_geoSearch;
    BMKLocationService *_locService;
    
    LCMapLocationResult *_locResult;
    
}

@property (nonatomic) BOOL needReverse;

@property (nonatomic, readonly) BOOL isLocating;

@property (nonatomic, retain) id <LCMapLocateDelegate> delegate;

/**
 *开始定位
 *异步函数，返回结果在LCMapLocateDelegate的onGetLocation通知
 *@param
 *@return
 */
- (void)startLocate;

/**
 *停止定位
 *
 *@param
 *@return
 */
- (void)stopLocate;

- (void)startLocateWithObject:(id)object;

+ (LCMapLocate *)sharedInstance;

@end
