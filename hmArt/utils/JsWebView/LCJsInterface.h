//
//  LCJsInterface.h
//  lifeassistant
//
//  Created by 刘学 on 14-11-14.
//
//

#import <Foundation/Foundation.h>
#import "EasyJSDataFunction.h"
#import "EasyJSWebView.h"
#import "HMGlobalParams.h"
#import "LCJsonKit.h"


@protocol LCJsInterfaceDelegate <NSObject>

@optional
- (void)login:(EasyJSDataFunction*) func;
- (void)signout:(NSString*) backurl;
- (void)sendSms:(NSString *)content toMobile:(NSString *)mobile;
- (NSArray *)location:(NSString * )func;
- (void)scanQrcode:(EasyJSDataFunction*) func;
- (void)shakeMotion:(EasyJSDataFunction*) func;
- (void)openUrl:(NSString *)url inAPP:(BOOL)isIn;
- (void)setHeaderColorRed:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b;
- (void)setHeaderTitle:(NSString *)title;
- (void)call:(NSString *)phone serviceName:(NSString *)service tips:(NSString *)title showNumber:(BOOL)show;
- (void)hideTabBar:(NSString*) hide;
- (void)fenxiangTitle:(NSString *)title Content:(NSString *)content ImageUrl:(NSString *)image SiteUrl:(NSString *)url;
- (void)goBack;
- (void)popToRootView;
- (void)toPay:(NSString*)type Data:(NSString*)data;
- (void)start:(NSString *)log Navi:(NSString *)lat;
- (void)saveImage:(NSString*)imgUrl;
@required

@end

@interface LCJsInterface : NSObject

@property(nonatomic,retain) id<LCJsInterfaceDelegate> delegate;
@property (strong, nonatomic) EasyJSWebView *jsWebView;
- (void) test;
/**
 *检查登录接口
 **/
-(NSString*) check:(NSString*)require Login:(NSString*) callback;

/**
 *注销登录
 **/
-(NSString*) sign:(NSString*) backurl out:(NSString*) callback;


/**
 *客户端信息
 **/
-(NSString*) getAppInfo:(NSString*) callback;

/**
 *手机信息
 **/
-(NSString*) getHardwareInfo:(NSString*) callback;


/**
 *隐藏底部状态条
 **/
-(void) hideCtrlBar:(NSString*) hide;

/**
 *设置APP头部颜色
 **/
- (NSString *)setPageColor:(NSString *)color;

/**
 *设置APP标题
 **/
- (NSString *)setPageTitle:(NSString *)title;



/**
 *手机位置信息
 **/
- (NSString *)myLocation:(NSString *)callback;

/**
 *开启二维码扫描
 **/
//- (NSString *)qrcodeScan:(NSString *)callback;

/**
 *摇一摇事件监测
 **/
- (NSString *)shake:(NSString *)callback;

/**
 *加密json字符串
 **/
- (NSString *)encrypt:(NSString *)json Params:(NSString *)callback;


/**
 *发送短信
 **/
-(NSString*)send:(NSString*)content Sms:(NSString *)mobile;

/**
 *手机浏览器打开url
 **/
- (NSString *)openUrl:(NSString *)url;

/**
 *APP浏览器打开url
 **/
- (NSString *)openUrlInApp:(NSString *)url;

/**
 *APP分享
 **/
- (NSString *)fenxiangTitle:(NSString *)title Content:(NSString *)content ImageUrl:(NSString *)image SiteUrl:(NSString *)url;
/**
 *APP分享
 **/
- (NSString *)fenxiangTitle:(NSString *)title Content:(NSString *)content ImageUrl:(NSString *)image SiteUrl:(NSString *)url Type:(NSString *) type Id:(NSString *)id;

/**
 *返回上一页
 */
- (void)goBack;

/**
 *返回首页
 */
- (void)popToRootView;

/***
 * 支付
*/
- (void)toPay:(NSString*)type Data:(NSString*)data;
 
/**
 *验证是否支持某函数
 **/
- (NSString *)canPerform:(NSString *)funcName Callback:(NSString *)callback;

/**
 *导航
 **/
- (void)start:(NSString *)log N:(NSString *)lat a:(NSString *)log0 vi:(NSString *)lat0;

/***
 * 保存图片
 */
- (void)saveImage:(NSString*)imgUrl;


@end
