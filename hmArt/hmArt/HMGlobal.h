//
//  HMGlobal.h
//  hmArt
//
//  Created by wangyong on 13-7-7.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#ifndef hmArt_HMGlobal_h
#define hmArt_HMGlobal_h

//////***************新版**************/////
#define HM_SYS_SERVER_scheme @"https"
#define HM_SYS_SERVER_URL @"app.4008988518.com/art-interface/"
#define HM_SYS_IMGSRV_PREFIX @"https://app.4008988518.com/image"
#define HM_SYS_APPDOWN_URL @"https://app.4008988518.com/app/down.html"

#define kUrlBidNotice @"https://app.4008988518.com/art-interface/html/getContent.htm?type=1"    //竞买须知
#define kUrlAboutUs   @"https://app.4008988518.com/art-interface/html/getContent.htm?type=3"    //关于我们
#define kUrlHelp      @"https://app.4008988518.com/art-interface/html/getContent.htm?type=2"    //使用帮助
#define kUrlVoucher   @"https://app.4008988518.com/art-interface/html/getContent.htm?type=4"    //优惠券
#define kUrlVIPNotice @"https://app.4008988518.com/art-interface/html/getContent.htm?type=5"    //VIP须知
#define kUrlSalesNotice @"https://app.4008988518.com/art-interface/html/getContent.htm?type=6"  //二次销售
#define kUrlSellerRegNotice @"https://app.4008988518.com/art-interface/html/getContent.htm?type=7" //商家

//////***************旧版**************/////
//#define HM_SYS_SERVER_URL @"www.4008988518.com"
//#define HM_SYS_IMGSRV_PREFIX @"https://www.4008988518.com:8088/upload"

//////***************测试**************/////
//#define HM_SYS_SERVER_scheme @"http"
//#define HM_SYS_SERVER_URL @"60.205.212.126:8090/art-interface/"
//#define HM_SYS_SERVER_URL @"192.168.1.215:8080/art-interface/"
//#define HM_SYS_SERVER_URL @"https://www.4008988518.com:8180/art-interface/"


#define HM_SYS_DATE_FORMAT  @"yyyy-MM-dd"

#define HM_SYS_CUSTOM_SERVICE_PHONE @"4008988518"
#define LC_SYS_ID_APP_VERSION @"com.hanmo.51art.app.version"
#define LC_SYS_ID_BUILD_VER @"com.hanmo.51art.app.build"

#define LC_IMG_PAIMAIHANG @"https://app.4008988518.com/html/img/home_paimaihang.jpg"
#define LC_IMG_HUALANG @"https://app.4008988518.com/html/img/home_hualang.jpg"
#define LC_IMG_YISHUJIA @"https://app.4008988518.com/html/img/home_yishujia.jpg"

static const NSInteger HM_SYS_INTERFACE_SUCCESS = 1;
static const CGFloat HM_SYS_VIEW_OFFSET = 43;

#define kAppStoreID @"703272632"
#define interfaceQueryVersionInStore @"https://itunes.apple.com/lookup?id=703272632"

static const NSInteger HM_NET_INTERFACE_SUCCESS = 1;
static const NSInteger HM_SYS_NAVIBARBG_TAG = 825;

#define APP_SYS_RED_COLOR  [UIColor colorWithRed:226.0/255.0 green:38.0/255.0 blue:28.0/255.0 alpha:1]

//新接口VER2.0
#define interfaceAds @"advert/search.htm"
#define interfaceHomeRecommend @"homeRec/search.htm"
#define interfaceHomeAreas @"homeRec/info.htm"

#define kAD_POS_CODE_HOME @"001"
#define kAD_POS_CODE_LOGIN @"002"

#define interfaceAuction @"auctions/dateGroup.htm"        //预展日期
//#define interfaceWeiXinToPay @"payment/weixin.htm"   //微信支付
#define interfaceAppToPay @"payment/appPay.htm"   //app控件支付（支付宝、微信）

//竞拍专区开始
#define interfaceAuctionSearch @"auctionsV3/search.htm"        //竞拍品查询
#define interfaceAuctionDetail @"auctionsV3/detail.htm"        //竞拍详情
#define interfaceAuctionDateGroup @"aucareaList/preview.htm"   //预展专区
#define interfaceAuctionBiddingRecords @"auctionsV3/bidder.htm"   //出价记录
#define interfaceAuctionBidding @"auctionsV3/bidding.htm"   //出价

#define interfaceAuctionSms @"auctSms/subscribe.htm"        //短信订阅
#define interfaceAuctionSmsCancel @"auctSms/cancel.htm"        //取消短信订阅


#define interfaceMyAuction @"auctionsV3/getMyAuction.htm"   //我的正在竞买

//竞买记录
#define interfaceAuctionRecords @"auctionsV3/search.htm"   //
#define interfaceAuctionMoney @"auctions/totalAmount.htm"
#define interfaceAuctionRecordUnread @"auctions/unread.htm"   //新竞拍记录

//竞拍专区结束

//艺术家、作品、画廊等开始
//艺术家、作品推荐
#define interfaceGalleryCategory @"artwork/classify.htm"        //画廊分类
#define interfaceArtistSearch @"artist/search.htm"        //画家列表
#define interfaceArtistDetail @"artist/getArtist.htm"        //画家详情
#define interfaceArtWorkSearch @"artwork/search.htm"        //艺术品列表
#define interfaceArtWorkDetail @"artwork/detail.htm"        //艺术品详情
#define interfaceArtworkInfo @"artwork/info.htm"  //作品详情

#define interfaceArtistAcitvitySearch @"activity/search.htm"        //活动列表
#define interfaceArtistAcitvityDetail @"activity/detail.htm"        //活动详情
#define interfaceArtistAwardsSearch @"awards/search.htm"        //艺术品列表
#define interfaceArtistAwardsDetail @"awards/detail.htm"        //艺术品详情
#define interfaceArtistExpoSearch   @"expo/search.htm"      //艺术品列表
#define interfaceArtistExpoDetail   @"expo/detail.htm"      //艺术品详情
#define interfaceArtistCopyrightSearch @"copyright/search.htm"        //艺术品列表
#define interfaceArtistCopyrightDetail @"copyright/detail.htm"        //艺术品详情
#define interfacePriceTrend @"artwork/chart.htm"        //艺术家	价格走势

//艺术家、作品、画廊等结束

//用户相关开始
#define interfaceUserLogin @"login.htm"        //登录
#define interfaceUserRegist @"register.htm"        //注册
#define interfaceUserCheckName @"client/checkUserName.htm"        //用户名验证
#define interfaceUserUpdateMobile @"user/upmob.htm"        //修改手机号码
#define interfaceUserUpdatePwd @"user/uppwd.htm"        //修改密码
#define interfaceUserRePwd @"user/repwd.htm"        //忘记密码
#define interfaceUserSendAuth @"sms/code.htm"        //发送验证码
#define interfaceUserUpdateInfo @"user/upinfo.htm"        //修改用户信息
#define interfaceUserGetInfo @"user/getInfo.htm"        //修改用户信息
#define interfaceUserUpgrade @"user/vipReq.htm"        //申请升级为vip

//用户相关结束


//会员中心开始
//竞买订单
#define interfaceMemberAuctOrder @"member/order/search.htm"   //列表
#define interfaceMemberAuctOrderDetail @"member/order/detail.htm"   //详情
#define interfaceMemberAuctOrderSingFor @"member/order/signFor.htm"   //签收
#define interfaceMemberAuctOrderSales @"member/order/salesRequest.htm"   //二次销售
#define interfaceMemberAuctOrderSalesSubmit @"member/order/salesSubmit.htm"   //二次销售
#define interfaceMemberAuctOrderPayment @"member/order/payment.htm"   //支付
#define interfaceMemberAuctOrderToPay @"member/order/toPay.htm"   //支付跳转

#define interfaceMemberGetBalance @"account/getBalance.htm"   // 二次销售申请

//VIP升级
#define interfaceMemberVIPReq @"upgradeVip/request.htm"   // vip申请请求
#define interfaceMemberVIPRecharge @"upgradeVip/recharge.htm"   // vip申请请求充值

#define interfaceMemberAccountRecharge @"account/recharge.htm"   // 二次销售充值
#define interfaceMemberAuctRequestNote @"note/search.htm"   // 二次销售申请

#define interfaceAuctLabelSearch @"artLabel/getAll.htm"   //作品标签查询

//商家入驻
#define interfaceSellerRegReq @"srr/search.htm"   //
#define interfaceSellerRegSubmit @"srr/submit.htm"   //

//会员积分
#define interfaceMemberPoints @"integral/get.htm"   //我的积分
#define interfaceMemberPointsLog @"integral/log.htm"   //我的积分流水记录
#define interfaceMemberGiftCategory @"gift/group.htm"   //积分商品分类
#define interfaceMemberGiftList @"gift/search.htm"   //积分商品列表
#define interfaceMemberGiftOrder @"gift/order.htm"   //兑换记录
#define interfaceMemberGiftExchange @"gift/exchange.htm"   //兑换礼品
//意见反馈列表
#define interfaceFeebackList @"feedback/search.htm"
#define interfaceFeebackSub @"feedback/sub.htm"
#define interfaceFeebackUnreadSuggestion @"feedback/unread.htm"        //未读建议条数


//收藏类
#define interfaceFavoriteAdd @"favorite/add.htm"        //添加收藏
#define interfaceFavoriteDel @"favorite/del.htm"        //删除收藏
#define interfaceFavoriteList @"favorite/search.htm"        //收藏列表
//代金券
#define interfaceVouchersList @"vouchers/search.htm"        //代金券列表
#define interfaceVouchersUnread @"vouchers/unread.htm"        //新代金券数量

//会员中心结束

//地区类表接口
#define interfaceAddr @"addr/search.htm"

//更多服务开始
//战略联盟
#define interfaceAllianceGroup @"partner/classify.htm"
#define interfaceAlliancePartners @"partner/search.htm"
//新闻行业动态
#define interfaceNewsList @"news/search.htm"
#define interfaceNewsDetail @"news/detail.htm"

//推送消息
//#define interfacePushReportToken @"push/reportDevice.htm"
#define interfacePushReportToken @"pushNotice/reportDevice.htm"
#define interfacePushMessageList @"push/list.htm"
#define interfacePushReportLaunch @"client/start.htm"


//更多服务结束


//以下是旧版app使用的接口地址
//首页广告地址
#define interfaceHomeAds @"client/advertList.htm"



//画廊相关
#define interfaceGalleryList @"client/galleryList.htm"              //画廊列表
#define interfaceGalleryDetail @"client/galleryDetail.htm"            //画廊详情

//拍卖公司
#define interfaceAuctionList @"client/auctionCompanyList.htm"      //拍卖公司

//联系我们
#define interfaceContactUs @"client/contactUs.htm"      //联系我们




//画家、作品相关
#define interfacePictureList @"client/artWorkList.htm"        //作品列表
#define interfacePictureDetail @"client/artWorkDetail.htm"        //作品详情

//拍卖行
#define interfaceAuctioneerList @"auctioneer/list.htm"        //拍卖行列表
#define interfaceAuctioneerArtwork @"auctioneerArtwork/search.htm"        //拍卖行展品列表
#define interfaceAuctioneerArtworkDetail @"auctioneerArtwork/detail.htm"  //拍卖行展品详情


//信息类型
#define kInfoTypeNews 1
#define kInfoTypeActivity 2
#define kInfoTypePrize 3
#define kInfoTypePublish 4
#define kInfoTypeExhibition 5

//作品类型kPictureType
#define kPictureTypeGallery 1
#define kPictureTypeForSale 2
#define kPictureTypeSaled 3
//#define kPictureTypeWonderful 4

#define IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)


//分享
#define kShareSDKKey @"301bbb75e00c"

#define kSinaWeiboAppKey             @"1633555340"
#define kSinaWeiboAppSecret          @"fa7acd567b5823e1f140212e40cab0ce"
#define kSinaWeiboAppRedirectURI     @"http://weibo.com/u/3655540721"
//#define kSinaWeiboAppKey             @"568898243"
//#define kSinaWeiboAppSecret          @"38a4f8204cc784f81f9f0daaf31e02e3"
//#define kSinaWeiboAppRedirectURI     @"http://www.sharesdk.cn"

#define kQQZoneAppKey             @"1101029863"
#define kQQZoneAppSecret          @"Fy1xxJUXcUyvw33g"

#define kTencentWeiboAppKey             @"801543826"
#define kTencentWeiboAppSecret          @"970f4c712bff2340f194aa772cfba3ce"
#define kTencentWeiboAppRedirectURI     @"http://www.hmqqw.com"

#define kWeChatAppKey             @"wxd0ad852a1550a5d8"
#define kAlipayAppKey             @"alipayhmArt"


#endif
