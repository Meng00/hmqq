//
//  LCDESCoder.m
//  lifeassistant
//
//  Created by liuxue on 13-7-19.
//
//
#import <CommonCrypto/CommonCryptor.h>
#import "LCDESCoder.h"

//空字符串
//#define     LocalStr_None   @""
static NSString *LocalStr_None = @"";

static NSString *key = @"278a977a23745062278df5c3ac2d1794";
static NSString *h5Key=@"dd3c624bfbc0de83485ee4cd12c611a2";

@implementation LCDESCoder


+ (NSString *)base64StringFromText:(NSData *)data
{
    if (data) {
        return [LCBase64 base64Encode:[self DESEncrypt:data WithKey:key]];
    }
    else {
        return LocalStr_None;
    }
}

+ (NSData *)textFromBase64String:(NSString *)base64
{
    if (base64 && ![base64 isEqualToString:LocalStr_None]) {
        if ([base64 hasPrefix:@"\""]) {
            base64 = [base64 substringWithRange:NSMakeRange(1, base64.length-2)];
        }
        return [self DESDecrypt:[LCBase64 base64Decode:base64] WithKey:key];
    }
    else {
        return nil;
    }
}

+ (NSString *)h5Base64StringFromText:(NSData *)data
{
    if (data) {
        return [LCBase64 base64Encode:[self DESEncrypt:data WithKey:h5Key]];
    }
    else {
        return LocalStr_None;
    }
}

+ (NSData *)h5TextFromBase64String:(NSString *)base64
{
    if (base64 && ![base64 isEqualToString:LocalStr_None]) {
        base64 = [base64 substringWithRange:NSMakeRange(1, base64.length-2)];
        return [self DESDecrypt:[LCBase64 base64Decode:base64] WithKey:h5Key];
    }
    else {
        return nil;
    }
}


/******************************************************************************
 函数描述 : 文本数据进行DES加密
 ******************************************************************************/
+ (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}

/******************************************************************************
 函数描述 : 文本数据进行DES解密
 ******************************************************************************/
+ (NSData *)DESDecrypt:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}


@end
