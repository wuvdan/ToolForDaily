//
//  NSString+MD.h
//  DailyProject-Swift
//
//  Created by wudan on 2021/10/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (MD)
+ (NSString *)HMACWithSecret:(NSString *)secret andString:(NSString *)str;
@end

NS_ASSUME_NONNULL_END
