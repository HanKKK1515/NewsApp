//
//  HLNewsResult.m
//  简闻
//
//  Created by 韩露露 on 16/6/1.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLNews.h"
#import "SDWebImageManager.h"

@implementation HLNews
- (NSString *)content {
    NSMutableString *contentT = _content.mutableCopy;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@ || SELF contains[c] %@", @"<em>", @"</em>"];
    while ([predicate evaluateWithObject:contentT]) {
        [self removeEM:contentT];
    }
    return contentT;
}

- (void)removeEM:(NSMutableString *)str {
    NSRange range1 = [str rangeOfString:@"<em>"];
    if (range1.location != NSNotFound) { 
        [str deleteCharactersInRange:range1];
    }
    NSRange range2 = [str rangeOfString:@"</em>"];
    if (range2.location != NSNotFound) {
        [str deleteCharactersInRange:range2];
    }
}

- (NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [formatter dateFromString:self.pdate_src];
}

@end
