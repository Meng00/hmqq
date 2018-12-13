//
//  EasyJSWebViewDelegate.m
//  EasyJS
//
//  Created by Lau Alex on 19/1/13.
//  Copyright (c) 2013 Dukeland. All rights reserved.
//

#import "EasyJSWebViewProxyDelegate.h"
#import "EasyJSDataFunction.h"
#import <objc/runtime.h>

/*
 This is the content of easyjs-inject.js
 Putting it inline in order to prevent loading from files
 */
NSString* INJECT_JS = @"window.EasyJS = {\
__callbacks: {},\
\
invokeCallback: function (cbID, removeAfterExecute){\
var args = Array.prototype.slice.call(arguments);\
args.shift();\
args.shift();\
\
for (var i = 0, l = args.length; i < l; i++){\
args[i] = decodeURIComponent(args[i]);\
}\
\
var cb = EasyJS.__callbacks[cbID];\
if (removeAfterExecute){\
EasyJS.__callbacks[cbID] = undefined;\
}\
return cb.apply(null, args);\
},\
\
call: function (obj, functionName, args){\
var formattedArgs = [];\
for (var i = 0, l = args.length; i < l; i++){\
if (typeof args[i] == \"function\"){\
formattedArgs.push(\"f\");\
var cbID = \"__cb\" + (+new Date);\
EasyJS.__callbacks[cbID] = args[i];\
formattedArgs.push(cbID);\
}else{\
formattedArgs.push(\"s\");\
formattedArgs.push(encodeURIComponent(args[i]));\
}\
}\
\
var argStr = (formattedArgs.length > 0 ? \":\" + encodeURIComponent(formattedArgs.join(\":\")) : \"\");\
\
var iframe = document.createElement(\"IFRAME\");\
iframe.setAttribute(\"src\", \"easy-js:\" + obj + \":\" + encodeURIComponent(functionName) + argStr);\
document.documentElement.appendChild(iframe);\
iframe.parentNode.removeChild(iframe);\
iframe = null;\
\
var ret = EasyJS.retValue;\
EasyJS.retValue = undefined;\
\
if (ret){\
return decodeURIComponent(ret);\
}\
},\
\
inject: function (obj, methods){\
window[obj] = {};\
var jsObj = window[obj];\
\
for (var i = 0, l = methods.length; i < l; i++){\
(function (){\
var method = methods[i];\
var jsMethod = method.replace(new RegExp(\":\", \"g\"), \"\");\
jsObj[jsMethod] = function (){\
return EasyJS.call(obj, method, Array.prototype.slice.call(arguments));\
};\
})();\
}\
}\
};";

@implementation EasyJSWebViewProxyDelegate

@synthesize realDelegate;
@synthesize javascriptInterfaces;

- (void) addJavascriptInterfaces:(NSObject*) interface WithName:(NSString*) name{
    if (! self.javascriptInterfaces){
        self.javascriptInterfaces = [[NSMutableDictionary alloc] init];
    }
    
    [self.javascriptInterfaces setValue:interface forKey:name];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSMutableString *desc = [[NSMutableString alloc] init];
    switch (error.code) {
        case NSURLErrorDNSLookupFailed:
        case NSURLErrorCannotConnectToHost:
        case NSURLErrorCannotFindHost:
            [desc appendString:@"当前网络不可用，请检查网络设置"];
            break;
        case NSURLErrorTimedOut:
            [desc appendString: @"连接超时，请重新尝试"];
            break;
        case NSURLErrorDataNotAllowed:
            [desc appendString:@"服务器不可到达，请检查网络"];
            break;
        case NSURLErrorBadURL:
        case NSURLErrorUnsupportedURL:
            [desc appendString:@"连接地址错误，请重新尝试"];
            break;
        default:
            break;
    }
    if (desc.length > 5) {
        [LCAlertView showWithTitle:@"提示" message:desc buttonTitle:@"确定"];
    }

    if ([self.realDelegate respondsToSelector:@selector(webView: didFailLoadWithError:)]) {
        [self.realDelegate webView:webView didFailLoadWithError:error];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none';"];
    
    // 禁用用户选择
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    // 禁用长按弹出框
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];

    
    
    NSMutableString* injection = [[NSMutableString alloc] init];
    
    //inject the javascript interface
    for(id key in self.javascriptInterfaces) {
        NSObject* interface = [self.javascriptInterfaces objectForKey:key];
        
        [injection appendString:@"EasyJS.inject(\""];
        [injection appendString:key];
        [injection appendString:@"\", ["];
        
        unsigned int mc = 0;
        Class cls = object_getClass(interface);
        Method * mlist = class_copyMethodList(cls, &mc);
        for (int i = 0; i < mc; i++){
            [injection appendString:@"\""];
            [injection appendString:[NSString stringWithUTF8String:sel_getName(method_getName(mlist[i]))]];
            [injection appendString:@"\""];
            
            if (i != mc - 1){
                [injection appendString:@", "];
            }
        }
        
        free(mlist);
        
        [injection appendString:@"]);"];
    }
    
    
    NSString* js = INJECT_JS;
    //inject the basic functions first
    [webView stringByEvaluatingJavaScriptFromString:js];
    //inject the function interface
    [webView stringByEvaluatingJavaScriptFromString:injection];
    
    if ([self.realDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.realDelegate webViewDidFinishLoad:webView];
    }
    
    if (!webView.isLoading) {
        NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
        NSLog(@"currentURL: %@", currentURL);

        if([currentURL hasPrefix:@"file:"]){
            [webView stringByEvaluatingJavaScriptFromString:@"javascript:onARTJsObjReady()"];
        }else{
            [webView stringByEvaluatingJavaScriptFromString:@"javascript:onARTJsObjReady2()"];
        }
        
        if ([currentURL rangeOfString:@"/art-interface/mui/HMHome.html"].location != NSNotFound) {
            UIViewController * topVC = [(UITabBarController *)[[[UIApplication sharedApplication] keyWindow] rootViewController] selectedViewController];
            if ([topVC isKindOfClass:[UINavigationController class]]) {
                UINavigationController * naviVC = (UINavigationController *)topVC;
                [naviVC popViewControllerAnimated:YES];
            }
        }
    }
    //    NSString *jsToGetHTMLSource = @"document.getElementsByTagName('html')[0].innerHTML";
    //    NSString *HTMLSource = [webView stringByEvaluatingJavaScriptFromString:jsToGetHTMLSource];
    //    NSLog(@"%@",HTMLSource);
    
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString *requestString = [[request URL] absoluteString];
    
    if ([requestString hasPrefix:@"easy-js:"]) {
        /*
         A sample URL structure:
         easy-js:MyJSTest:test
         easy-js:MyJSTest:testWithParam%3A:haha
         */
        NSArray *components = [requestString componentsSeparatedByString:@":"];
        
        NSString* obj = (NSString*)[components objectAtIndex:1];
        NSString* method = [(NSString*)[components objectAtIndex:2]
                            stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSObject* interface = [javascriptInterfaces objectForKey:obj];
        
        // execute the interfacing method
        SEL selector = NSSelectorFromString(method);
        NSMethodSignature* sig = [[interface class] instanceMethodSignatureForSelector:selector];
        NSInvocation* invoker = [NSInvocation invocationWithMethodSignature:sig];
        invoker.selector = selector;
        invoker.target = interface;
        
        NSMutableArray* args = [[NSMutableArray alloc] init];
        
        if ([components count] > 3){
            NSString *argsAsString = [(NSString*)[components objectAtIndex:3]
                                      stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSArray* formattedArgs = [argsAsString componentsSeparatedByString:@":"];
            for (long i = 0, j = 0, l = [formattedArgs count]; i < l; i+=2, j++){
                NSString* type = ((NSString*) [formattedArgs objectAtIndex:i]);
                NSString* argStr = ((NSString*) [formattedArgs objectAtIndex:i + 1]);
                
                if ([@"f" isEqualToString:type]){
                    EasyJSDataFunction* func = [[EasyJSDataFunction alloc] initWithWebView:(EasyJSWebView *)webView];
                    func.funcID = argStr;
                    [args addObject:func];
                    [invoker setArgument:&func atIndex:(j + 2)];
                }else if ([@"s" isEqualToString:type]){
                    NSString* arg = [argStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    [args addObject:arg];
                    [invoker setArgument:&arg atIndex:(j + 2)];
                }
            }
        }
        [invoker invoke];
        
        //return the value by using javascript
        if ([sig methodReturnLength] > 0){
            NSString* retValue;
            [invoker getReturnValue:&retValue];
            
            if (retValue == NULL || retValue == nil){
                [webView stringByEvaluatingJavaScriptFromString:@"EasyJS.retValue=null;"];
            }else{
                retValue = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef) retValue, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
                [webView stringByEvaluatingJavaScriptFromString:[@"" stringByAppendingFormat:@"EasyJS.retValue=\"%@\";", retValue]];
            }
        }
        
        return NO;
    }
    
    if (!self.realDelegate){
        return YES;
    }else if ([self.realDelegate respondsToSelector:@selector(webView: shouldStartLoadWithRequest: navigationType:)]){
        BOOL b = [self.realDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
        return b;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    if ([webView.subviews count] > 0) {
        UIScrollView *scrollView = [webView.subviews objectAtIndex:0];
        [scrollView setContentOffset:CGPointMake(0, 0)];
    }

    if ([self.realDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.realDelegate webViewDidStartLoad:webView];
    }
    
}

- (void)dealloc{
    if (self.javascriptInterfaces){
        self.javascriptInterfaces = nil;
    }
    
    if (self.realDelegate){
        self.realDelegate = nil;
    }
    
}

@end
