//
//  LCNetworkInterface.m
//  lifeassistant
//
//  Created by wangyong on 13-4-10.
//
//

#import "LCNetworkInterface.h"

static unsigned int LC_NETWORK_TIMEOUT_SECONDS = 60;


// 添加私有方法
@interface LCNetworkInterface()

// 创建错误结果
- (LCInterfaceResult *)createErrorResult:(NSError *)error;

// 解析并返回结果
- (LCInterfaceResult* )parseResponse:(NSData *)data;

//不加密返回结果
- (LCInterfaceResult *)parseResponseWithoutEncode:(NSData *)data;

// 异步请求成功
- (void)requestFinished:(ASIHTTPRequest *)request;

// 异步请求失败
- (void)requestFailed:(ASIHTTPRequest *)request;

// 取请求ID
- (NSNumber *)getReqeustID;

// 删除请求
- (void)removeRequest:(NSNumber *)reqId;

// 执行回调
- (void)performDelegate:(NSDictionary *)userInfo result:(LCInterfaceResult *)result;

/*!
 @method
 @abstract 创建请求句柄
 @param serviceName 服务名称
 @param parameter 参数
 @param ssl 是否使用SSL
 @param serverUrl 地址
 @param user 用户名
 @param password 密码
 @result 请求句柄
 */
- (ASIHTTPRequest *)createRequestWithName:(NSString *)serviceName
                                parameter:(NSObject *)parameter
                                  needSSL:(BOOL)ssl
                                serverUrl:(NSString *)serverUrl;

@end

//实现部分
//------------------------------------------------------------------------------
@implementation LCNetworkInterface


+ (id)sharedInstance {
    // 单例
    static LCNetworkInterface *singleInstance = nil;
    
    if (!singleInstance) {
        singleInstance = [[super allocWithZone:nil] init];
        
        // 设置缓存
        ASIDownloadCache *cache = [ASIDownloadCache sharedCache];
        [cache setShouldRespectCacheControlHeaders:NO];
        
        //路径
        NSString *tmpPath = NSTemporaryDirectory();
        NSString *storePath = [tmpPath stringByAppendingPathComponent:@"cache114menhu"];
        //设置缓存存放路径
        [cache setStoragePath:storePath];
        
        //设置缓存策略
        [cache setDefaultCachePolicy:ASIOnlyLoadIfNotCachedCachePolicy];
        
        //        [[ASIDownloadCache sharedCache] setDefaultCachePolicy:ASIOnlyLoadIfNotCachedCachePolicy];
        
    }
    
    return singleInstance;
}

+ (void)setTimeOutSeconds:(unsigned int)seconds
{
    LC_NETWORK_TIMEOUT_SECONDS = seconds;
}

- (id)init
{
    self = [super init];
    
    _requstCount = 0;
    _requests = [[NSMutableDictionary alloc] init];
    
    return self;
}

#pragma mark 防止生成调用
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

#pragma mark -
#pragma mark 发起异步请求
- (ASIHTTPRequest *)createRequestWithName:(NSString *)serviceName
                                parameter:(NSObject *)parameter
                                  needSSL:(BOOL)ssl
                                serverUrl:(NSString *)serverUrl
{
    // 组装请求串的格式
    NSString *urlFormat = @"%@://%@%@";
    
    // 是否是SSL
    NSString *SSL = HM_SYS_SERVER_scheme;
//    if (!ssl)
//        SSL = @"s";
//    else
//        SSL = @"";
    
    // 组成URL请求串
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: urlFormat, SSL, serverUrl, serviceName]];
    
    NSLog(@"%@", [NSString stringWithFormat: urlFormat, SSL, serverUrl, serviceName]);
    // 生成一个Http请求
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    // 设置Http Header
    [request addRequestHeader:@"Content-Type" value:@"application/json;charset=UTF-8"];
    
    
    if (ssl) {
        // 不认证SSL证书
        [request setValidatesSecureCertificate: NO];
    }
    
    // 当进入后台时，继续请求
    [request setShouldContinueWhenAppEntersBackground: YES];
    
    // 设置提交的数据
    NSData *jsonData;
    if (parameter) {
        jsonData = [[LCJsonUtil sharedInstance] dataWithJSONObject:parameter];
    }else{
        NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithCapacity:1];
        jsonData = [[LCJsonUtil sharedInstance] dataWithJSONObject:param];
    }
    NSString *coderStr = [LCDESCoder base64StringFromText:jsonData];
    NSData *postData =  [coderStr dataUsingEncoding: NSUTF8StringEncoding];
    [request appendPostData: postData];
    
    // 设置为POST方式
    [request setRequestMethod: @"POST"];
    
    // 设置超时
    [request setTimeOutSeconds:LC_NETWORK_TIMEOUT_SECONDS];
    
    return request;
    
}
/*
 *创建一个异步请求，目前采取宏定义114-interface地址
 */
- (ASIHTTPRequest *)createRequestWithName:(NSString *)serviceName
                                parameter:(NSObject *)parameter
                                  needSSL:(BOOL)ssl
                               serverPath:(NSString *)path
{
    // 取出服务器地址或域名,目前采用宏定义
    NSString *server = nil;
    if(!path)
        server = HM_SYS_SERVER_URL;
    else
        server = path;
    return [self createRequestWithName:serviceName
                             parameter:parameter
                               needSSL:ssl
                             serverUrl:server];
    
}

//同步请求
- (LCInterfaceResult*)request:(NSString *)serviceName
                         with:(NSObject *)parameter
                    serverUrl:(NSString *)url
{
    ASIHTTPRequest *request = nil;
    
    // 组成URL请求串
    NSURL *serverPath = [NSURL URLWithString: url];
    
    // 生成一个Http请求
    request = [ASIHTTPRequest requestWithURL:serverPath];
    
    // 当进入后台时，继续请求
    [request setShouldContinueWhenAppEntersBackground: YES];
    // 同步请求
    [request startSynchronous];
    
    // 取错误信息
    NSError *error = [request error];
    
    if (!error)
        return [self parseResponseWithoutEncode:[request responseData]];
    else
        return [self createErrorResult:error];
}

//请求外部资源，如图片等
- (unsigned int)asynExternalRequest:(NSString *)path
                    needSSL:(BOOL)ssl
                     cached:(BOOL)cached
                     target:(id)target
                     action:(SEL)action
{
    
    ASIHTTPRequest *request = nil;
    
    // 组成URL请求串
    NSURL *url = [NSURL URLWithString: path];
    
    // 生成一个Http请求
    request = [ASIHTTPRequest requestWithURL:url];
    
    
    if (ssl) {
        // 不认证SSL证书
        [request setValidatesSecureCertificate: NO];
    }
    
    // 当进入后台时，继续请求
    [request setShouldContinueWhenAppEntersBackground: YES];
    
    // 设置为GET方式
    [request setRequestMethod: @"GET"];
    
    // 设置缓存
    if (cached) {
        [request setDownloadCache:[ASIDownloadCache sharedCache]];
        [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
        //        [request setCacheStoragePolicy:ASICacheForSessionDurationCacheStoragePolicy];
        [request setCachePolicy:ASIAskServerIfModifiedWhenStaleCachePolicy|ASIFallbackToCacheIfLoadFailsCachePolicy];
        //        [request setCachePolicy:ASIOnlyLoadIfNotCachedCachePolicy]; //ASIAskServerIfModifiedWhenStaleCachePolicy
        
        [request setSecondsToCache:21600];// 60*60*6s 保存6小时
    }
    
    // 异步请求委托
    [request setDelegate:self];
    
    // 生成请求ID
    NSNumber *requestID = [self getReqeustID];
    
    @synchronized(_requests) {
        [_requests setObject:request forKey:requestID];
    }
    
    // 将SEL类型打包成NSValue
    NSValue *selectorAsValue = [NSValue valueWithBytes:&action objCType:@encode(SEL)];
    
    // 存储委托以及服务名称
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                              target, @"target",
                              path, @"service",
                              selectorAsValue, @"action",
                              @"resource", @"tag",
                              requestID, @"requestID",
                              nil];
    
    [request setUserInfo:userInfo];
    
    // 异步请求
    [request startAsynchronous];
        
    return requestID.unsignedIntValue;
    
}

//请求外部json接口
- (unsigned int)asynExternalRequest:(NSString *)path
                             cached:(BOOL)cached
                             target:(id)target
                             action:(SEL)action
{
    
    ASIHTTPRequest *request = nil;
    
    // 组成URL请求串
    NSURL *url = [NSURL URLWithString: path];
    
    // 生成一个Http请求
    request = [ASIHTTPRequest requestWithURL:url];
    
    
    
    // 当进入后台时，继续请求
    [request setShouldContinueWhenAppEntersBackground: YES];
    
    // 设置为GET方式
    [request setRequestMethod: @"GET"];
    
    // 设置缓存
    if (cached) {
        [request setDownloadCache:[ASIDownloadCache sharedCache]];
        [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
        //        [request setCacheStoragePolicy:ASICacheForSessionDurationCacheStoragePolicy];
        [request setCachePolicy:ASIAskServerIfModifiedWhenStaleCachePolicy|ASIFallbackToCacheIfLoadFailsCachePolicy];
        //        [request setCachePolicy:ASIOnlyLoadIfNotCachedCachePolicy]; //ASIAskServerIfModifiedWhenStaleCachePolicy
        
        [request setSecondsToCache:3600];// 60*60s 保存1小时
    }
    
    // 异步请求委托
    [request setDelegate:self];
    
    // 生成请求ID
    NSNumber *requestID = [self getReqeustID];
    
    @synchronized(_requests) {
        [_requests setObject:request forKey:requestID];
    }
    
    // 将SEL类型打包成NSValue
    NSValue *selectorAsValue = [NSValue valueWithBytes:&action objCType:@encode(SEL)];
    
    // 存储委托以及服务名称
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                              target, @"target",
                              path, @"service",
                              selectorAsValue, @"action",
                              @"json", @"tag",
                              requestID, @"requestID",
                              nil];
    
    [request setUserInfo:userInfo];
    
    // 异步请求
    [request startAsynchronous];
    
    return requestID.unsignedIntValue;
    
}

- (NSNumber *)getReqeustID {
    _requstCount ++;
    if (_requstCount >= INT_MAX) {
        _requstCount = 1;
    }
    NSNumber *num = [NSNumber numberWithUnsignedInt:_requstCount];
    return num;
}

#pragma mark -
#pragma mark 指定action模式
- (unsigned int)asynRequest:(NSString *)serviceName
                       with:(NSObject *)parameter
                    needSSL:(BOOL)ssl
                     target:(id)target
                     action:(SEL)action
                       data:(id)data
{
    
    ASIHTTPRequest *request = [self createRequestWithName:serviceName parameter:parameter needSSL:ssl serverPath:nil];
    
    // 异步请求委托
    [request setDelegate:self];
    
    // 生成请求ID
    NSNumber *requestID = [self getReqeustID];
    
    @synchronized(_requests) {
        [_requests setObject:request forKey:requestID];
    }
    
    // 将SEL类型打包成NSValue
    NSValue *selectorAsValue = [NSValue valueWithBytes:&action objCType:@encode(SEL)];
    
    // 存储委托以及服务名称
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                              target, @"target",
                              selectorAsValue, @"action",
                              serviceName, @"service",
                              data, @"data",
                              requestID, @"requestID",
                              nil];
    
    [request setUserInfo:userInfo];
    
    [request setUserAgent:@"com.chinaunicom.beijing.vip"];
    
    // 异步请求
    [request startAsynchronous];
    
    return requestID.unsignedIntValue;
    
}
//异步请求服务
- (unsigned int)asynRequest:(NSString *)serviceName
                       with:(NSObject *)parameter
                    needSSL:(BOOL)ssl
                     target:(id)target
                     action:(SEL)action
{
    return [self asynRequest:serviceName with:parameter needSSL:ssl target:target action:action data:[NSNull null]];
}

//异步请求服务，含服务端路径
- (unsigned int)asynRequest:(NSString *)serviceName
                       path:(NSString *)serverPath
                       with:(NSObject *)parameter
                    needSSL:(BOOL)ssl
                     target:(id)target
                     action:(SEL)action
{
    ASIHTTPRequest *request = [self createRequestWithName:serviceName parameter:parameter needSSL:ssl serverPath:serverPath];
    
    // 异步请求委托
    [request setDelegate:self];
    
    // 生成请求ID
    NSNumber *requestID = [self getReqeustID];
    
    @synchronized(_requests) {
        [_requests setObject:request forKey:requestID];
    }
    
    // 将SEL类型打包成NSValue
    NSValue *selectorAsValue = [NSValue valueWithBytes:&action objCType:@encode(SEL)];
    
    id data = [NSNull null];
    // 存储委托以及服务名称
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                              target, @"target",
                              selectorAsValue, @"action",
                              serviceName, @"service",
                              data, @"data",
                              requestID, @"requestID",
                              nil];
    
    [request setUserInfo:userInfo];
    
    [request setUserAgent:@"com.chinaunicom.beijing.vip"];
    
    // 异步请求
    [request startAsynchronous];
    
    return requestID.unsignedIntValue;
    
}

#pragma mark -
#pragma mark response deal
- (void)cancelRequest:(unsigned int)requestID
{
    NSNumber *number = [NSNumber numberWithUnsignedInt:requestID];
    @synchronized(_requests) {
        id val = [_requests objectForKey:number];
        if (val) {
            ASIHTTPRequest *request = val;
            [request setDelegate:nil];
            [request setUserInfo:nil];
            
            // 从请求列表中删除本项
            [self removeRequest:number];
            
        }
    }
}

- (LCInterfaceResult *)createErrorResult:(NSError *) error
{
    LCInterfaceResult *result = [[LCInterfaceResult alloc] init];
    result.result = 2;
    switch (error.code) {
        case 1:
            result.message = @"服务器不可达,请检查网络是否正常";
            break;
        case 2:
            result.message = @"连接超时,请重新尝试";
            break;
            
        default:
            result.message = @"请求失败,请重新尝试";
            break;
    }
    //result.message = [error description];
    return result;
}

- (LCInterfaceResult *)parseResponse:(NSData *)data
{
    LCInterfaceResult* result = [[LCInterfaceResult alloc] init];
    NSString *coderStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"coderStr:%@", coderStr);
    // 取回的结果应该是一个NSDictionary类型
    NSDictionary *dict = [[LCJsonUtil sharedInstance] jsonWithData:[LCDESCoder textFromBase64String:coderStr]];
    NSLog(@"ret:%@", dict);
     
    NSNumber *number = (NSNumber *)[dict objectForKey:@"result"];
    result.result = [number intValue];
    result.message = [dict objectForKey:@"message"];
    result.value =  dict;
    
    return result;
}
- (LCInterfaceResult *)parseResponseWithoutEncode:(NSData *)data
{
    LCInterfaceResult* result = [[LCInterfaceResult alloc] init];
    
    // 取回的结果应该是一个NSDictionary类型
    NSDictionary *dict = [[LCJsonUtil sharedInstance] jsonWithData:data];
    
    NSNumber *number = (NSNumber *)[dict objectForKey:@"result"];
    result.result = [number intValue];
    result.message = [dict objectForKey:@"message"];
    result.value =  dict;
    
    return result;
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSDictionary *userInfo = [request userInfo];
    
    if (userInfo == nil) {
        return;
    }
    
    NSNumber *requestID = [userInfo objectForKey:@"requestID"];
    
    @synchronized(_requests) {
        // 是否有效的返回
        if ([_requests objectForKey:requestID] == nil)
            return;
                
        LCInterfaceResult *result = nil;
        NSString *resource = [userInfo objectForKey:@"tag"];
        if ([@"resource" isEqualToString:resource]) {
            // 资源调用
            result = [[LCInterfaceResult alloc] init];
            result.result = 1;
            result.message = nil;
            
            BOOL dataWasCompressed = [request isResponseCompressed];
            if (!dataWasCompressed) {
                result.value = [request responseData];
            }else{
                result.value = [request rawResponseData];
            }
            
            
        }else if ([@"json" isEqualToString:resource]){
            result = [[LCInterfaceResult alloc] init];
            
            // 取回的结果应该是一个NSDictionary类型
            NSDictionary *dict = [[LCJsonUtil sharedInstance] jsonWithData:[request responseData]];
            NSLog(@"serviceName:%@, ret:%@", [userInfo objectForKey:@"service"], dict);
            
            NSNumber *number = (NSNumber *)[dict objectForKey:@"result"];
            result.result = [number intValue];
            result.message = [dict objectForKey:@"message"];
            result.value =  dict;
        } else {
            NSString *serviceName = [userInfo objectForKey:@"service"];
            NSLog(@"serviceName:%@", serviceName);
            // 服务调用
            result = [self parseResponse:[request responseData]];
        }
        
        result.userData = [userInfo objectForKey:@"data"];
        result.requestID = requestID.unsignedIntValue;
        
        // 从请求列表中删除本项
        [self removeRequest:requestID];
        
        [self performDelegate:userInfo result:result];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSDictionary *userInfo = [request userInfo];
    
    if (userInfo == nil) {
        return;
    }
    
    NSNumber *requestID = [userInfo objectForKey:@"requestID"];
    
    // 是否有效的返回
    @synchronized(_requests) {
        if ([_requests objectForKey:requestID] == nil)
            return;
        
        LCInterfaceResult *result = [self createErrorResult:[request error]];
        result.userData = [userInfo objectForKey:@"data"];
        result.requestID = requestID.unsignedIntValue;
        
        // 从请求列表中删除本项
        [self removeRequest:requestID];
        
        [self performDelegate:userInfo result:result];
    }
}

- (void)performDelegate:(NSDictionary *)userInfo result:(LCInterfaceResult *)result
{
    NSString *serviceName = [userInfo objectForKey:@"service"];
    id target = [userInfo objectForKey:@"target"];
    SEL action;
    [(NSValue *)[userInfo objectForKey:@"action"] getValue:&action];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [target performSelector:action withObject:serviceName withObject:result];
#pragma clang diagnostic pop
    
}

- (void)removeRequest:(NSNumber *)reqId
{
    [_requests removeObjectForKey:reqId];
}


@end
