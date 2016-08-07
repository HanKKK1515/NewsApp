//
//  HLMemo.m
//  简闻
//
//  Created by 韩露露 on 16/4/21.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLMemo.h"

@implementation HLMemo
+ (instancetype)memoWithTitle:(NSString *)title text:(NSString *)text {
    HLMemo *memo = [[HLMemo alloc] init];
    memo.title = title;
    memo.text = text;
    memo.date = [NSDate date];
    return memo;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.text = [aDecoder decodeObjectForKey:@"text"];
        self.date = [aDecoder decodeObjectForKey:@"date"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.text forKey:@"text"];
    [aCoder encodeObject:self.date forKey:@"date"];
}
@end
