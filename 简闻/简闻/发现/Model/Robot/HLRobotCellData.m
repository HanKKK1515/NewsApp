//
//  HLRobotCellData.m
//  简闻
//
//  Created by 韩露露 on 16/5/22.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLRobotCellData.h"

@implementation HLRobotCellData
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.text = [aDecoder decodeObjectForKey:@"text"];
        self.date = [aDecoder decodeObjectForKey:@"date"];
        self.type = [aDecoder decodeIntForKey:@"type"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.text forKey:@"text"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeInt:self.type forKey:@"type"];
}
@end
