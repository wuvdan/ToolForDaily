//
//  NSString+MD.m
//  DailyProject-Swift
//
//  Created by wudan on 2021/10/19.
//

#import "NSString+MD.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation NSString (MD)
+ (NSString *)HMACWithSecret:(NSString *)secret andString:(NSString *)str
{
    unsigned long encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
     
    CCHmacContext    ctx;
    const char       *key = [secret cStringUsingEncoding:encode];
    const char       *string = [str cStringUsingEncoding:encode];
    unsigned char    mac[CC_MD5_DIGEST_LENGTH];
    char             hexmac[2 * CC_MD5_DIGEST_LENGTH + 1];
    char             *p;
     
    CCHmacInit( &ctx, kCCHmacAlgMD5, key, strlen( key ));
    CCHmacUpdate( &ctx, string, strlen(string) );
    CCHmacFinal( &ctx, mac );
     
    p = hexmac;
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++ ) {
        snprintf( p, 3, "%02x", mac[ i ] );
        p += 2;
    }
     
    return [NSString stringWithUTF8String:hexmac];
}
@end
