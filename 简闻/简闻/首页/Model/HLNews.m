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

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self.title = [aDecoder decodeObjectForKey:@"title"];
    self.src = [aDecoder decodeObjectForKey:@"src"];
    self.url = [aDecoder decodeObjectForKey:@"url"];
    self.img = [aDecoder decodeObjectForKey:@"img"];
    self.img_width = [aDecoder decodeObjectForKey:@"img_width"];
    self.img_length = [aDecoder decodeObjectForKey:@"img_length"];
    self.content = [aDecoder decodeObjectForKey:@"content"];
    self.pdate_src = [aDecoder decodeObjectForKey:@"pdate_src"];
    self.date = [aDecoder decodeObjectForKey:@"date"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.src forKey:@"src"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.img forKey:@"img"];
    [aCoder encodeObject:self.img_width forKey:@"img_width"];
    [aCoder encodeObject:self.img_length forKey:@"img_length"];
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.pdate_src forKey:@"pdate_src"];
    [aCoder encodeObject:self.date forKey:@"date"];
}

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
