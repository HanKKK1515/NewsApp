//
//  NSDate+HL.h
//  新新浪微博
//
//  Created by 韩露露 on 15/12/19.
//  Copyright © 2015年 韩露露. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (HL)
/**
 *  返回距离现在的具体时间
 */
+ (NSString *)timeIntervarWithDate:(NSDate *)date;

/**
 *  是否为今天
 */
- (BOOL)isToday;
/**
 *  是否为昨天
 */
- (BOOL)isYesterday;
/**
 *  是否为今年
 */
- (BOOL)isThisYear;

/**
 *  返回一个只有年月日的时间
 */
- (NSDate *)dateWithYMD;

/**
 *  返回一个只有年月日的时间字符串
 */
- (NSString *)stringWithYMD;

/**
 *  获得与当前时间的差距
 */
- (NSDateComponents *)intervalWithNow;

@end
