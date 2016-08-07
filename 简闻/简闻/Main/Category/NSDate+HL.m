//
//  NSDate+HL.m
//  新新浪微博
//
//  Created by 韩露露 on 15/12/19.
//  Copyright © 2015年 韩露露. All rights reserved.
//

#import "NSDate+HL.h"

@implementation NSDate (HL)

+ (NSString *)timeIntervarWithDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setLocale:locale];
    formatter.dateFormat = @"EEE MMM dd HH:mm:ss z yyyy";
    
    NSString *timeText = nil;
    if ([date isThisYear]) {
        if ([date isToday]) {
            NSDateComponents *intervalCom = [date intervalWithNow];
            if (intervalCom.hour) {
                timeText = [NSString stringWithFormat:@"%lu小时前", (long)intervalCom.hour];
            } else {
                if (intervalCom.minute) {
                    timeText = [NSString stringWithFormat:@"%lu分钟前", (long)intervalCom.minute];
                } else {
                    timeText = @"刚刚";
                }
            }
        } else if ([date isYesterday]) {
            formatter.dateFormat = @"昨天 HH:mm";
            timeText = [formatter stringFromDate:date];
        } else {
            formatter.dateFormat = @"MM-dd HH:mm";
            timeText = [formatter stringFromDate:date];
        }
    } else {
        timeText = date.stringWithYMD;
    }
    
    return timeText;
}

- (BOOL)isThisYear {
    NSDateComponents *creatCom = [self componentsWithDate:self];
    NSDateComponents *nowCom = [self componentsWithDate:[NSDate date]];
    return creatCom.year == nowCom.year;
}

- (BOOL)isToday {
    NSDateComponents *creatCom = [self componentsWithDate:self];
    NSDateComponents *nowCom = [self componentsWithDate:[NSDate date]];
    return (creatCom.year == nowCom.year) && (creatCom.month == nowCom.month) && (creatCom.day == nowCom.day);
}

- (BOOL)isYesterday {
    NSDateComponents *intervalCom = [self intervalWithNow];
    NSDateComponents *nowCom = [self componentsWithDate:[NSDate date]];
    NSInteger intervalMinute = intervalCom.day * 24 * 60 * 60 + intervalCom.hour * 60 * 60 + intervalCom.minute * 60 + intervalCom.second;
    NSInteger minMinute = nowCom.hour * 60 * 60 + nowCom.minute * 60 + nowCom.second;
    NSInteger maxMinute = minMinute + 24 * 60 * 60;
    return (intervalMinute <= maxMinute) && (intervalMinute > minMinute) && !intervalCom.year && !intervalCom.month;
}

- (NSDate *)dateWithYMD {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSString *selfStr = [fmt stringFromDate:self];
    return [fmt dateFromString:selfStr];
}

- (NSString *)stringWithYMD {
    NSDateComponents *com = [self componentsWithDate:self];
    return [NSString stringWithFormat:@"%lu-%lu-%lu", (long)com.year, (long)com.month, (long)com.day];
}

- (NSDateComponents *)intervalWithNow {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    return [calendar components:unit fromDate:self toDate:[NSDate date] options:0];
}

- (NSDateComponents *)componentsWithDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    return [calendar components:unit fromDate:date];
}
@end
