//
//  LCMapLocate.m
//  lifeassistant
//
//  Created by wangyong on 14-6-11.
//
//

#import "LCMapLocate.h"

@implementation LCMapLocationResult


@end


@implementation LCMapLocate


#pragma mark -
#pragma mark class init
+ (LCMapLocate *)sharedInstance
{
    static LCMapLocate *singleInstance = nil;
    @synchronized(self){
        if (!singleInstance) {
            singleInstance = [[super allocWithZone:nil] init];
            [singleInstance initMe];
        }
    }
    return singleInstance;
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

- (void)dealloc
{
    _geoSearch.delegate = nil;
    _locService.delegate = nil;
}

- (void)initMe
{
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyBest];
    [BMKLocationService setLocationDistanceFilter:100.0f];
    
    _geoSearch = [[BMKGeoCodeSearch alloc] init];
    _locService = [[BMKLocationService alloc] init];
    _needReverse = NO;
    _isLocating = NO;
    
    _locResult = [[LCMapLocationResult alloc] init];
    _locResult.result = 0;
    _locResult.address = @"";
    _locResult.errMessage = @"";
    _locResult.city = @"";
    _locResult.pt = (CLLocationCoordinate2D){0, 0};
    _locResult.object = nil;
    
    _geoSearch.delegate = self;
    _locService.delegate = self;
}

- (void)resetResult
{
    _locResult.result = 0;
    _locResult.address = @"";
    _locResult.errMessage = @"";
    _locResult.city = @"";
    _locResult.pt = (CLLocationCoordinate2D){0, 0};
}
#pragma mark -
#pragma mark action methods
- (void)startLocate
{
    if ([CLLocationManager locationServicesEnabled]) {
        [self resetResult];
        if (_isLocating) {
            [_locService stopUserLocationService];
        }
        [_locService startUserLocationService];
        _isLocating = YES;
        
    }else{
        _locResult.result = 1;
        _locResult.errMessage = @"定位功能已关闭，请前往设置页打开";
        if (_delegate && [_delegate respondsToSelector:@selector(didUpdateLocation:)]) {
            [_delegate didUpdateLocation:_locResult];
        }
    }
}
- (void)startLocateWithObject:(id)object
{
    _locResult.object =  object;
    [self startLocate];
}

- (void)stopLocate
{
    [_locService stopUserLocationService];
    _isLocating = NO;
}

#pragma mark -
#pragma baidu map api delegates
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_locService stopUserLocationService];
    _locResult.pt = userLocation.location.coordinate;
    if (_needReverse) {
        BMKReverseGeoCodeOption *option = [[BMKReverseGeoCodeOption alloc] init];
        option.reverseGeoPoint = _locResult.pt;
        BOOL flag = [_geoSearch reverseGeoCode:option];
        if (!flag) {
            _isLocating = NO;
            if (_delegate && [_delegate respondsToSelector:@selector(didUpdateLocation:)]) {
                _locResult.result = 2;
                _locResult.errMessage = @"未能获取定位地址信息，请重新尝试";
                [_delegate didUpdateLocation:_locResult];
            }
        }
    }else{
        _isLocating = NO;
        if (_delegate && [_delegate respondsToSelector:@selector(didUpdateLocation:)]) {
            _locResult.result = 0;
            [_delegate didUpdateLocation:_locResult];
        }
    }
}


- (void)didFailToLocateUserWithError:(NSError *)error
{
    _isLocating = NO;
    [_locService stopUserLocationService];
    NSString *errorString;
    _locResult.result = 3;
    switch ([error code]) {
        case kCLErrorDenied:
        {
            _locResult.result = 1;
            errorString = @"定位功能已关闭，请前往设置页打开";
        }
            break;
        case kCLErrorLocationUnknown:
            errorString = @"未能获取定位信息，请重新尝试";
            break;
        default:
            errorString = @"未知错误，请稍后重新尝试";
            break;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(didUpdateLocation:)]) {
        _locResult.errMessage = errorString;
        [_delegate didUpdateLocation:_locResult];
    }
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        _locResult.result = 0;
        //_locResult.address = result.address;
        _locResult.address = [NSString stringWithFormat:@"%@%@%@",result.addressDetail.district, result.addressDetail.streetName, result.addressDetail.streetNumber];
        _locResult.city = result.addressDetail.city;
    }else{
        _locResult.result = 2;
        _locResult.address = @"";
        _locResult.city = @"";
    }
    if (_delegate && [_delegate respondsToSelector:@selector(didUpdateLocation:)]) {
        [_delegate didUpdateLocation:_locResult];
    }
    _isLocating = NO;
}
@end
