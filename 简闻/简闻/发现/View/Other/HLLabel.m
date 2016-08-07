//
//  HL Label.m
//  简闻
//
//  Created by 韩露露 on 16/5/1.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLLabel.h"

@implementation HLLabel

- (instancetype)init {
    if (self = [super init]) {
        self.layer.cornerRadius = 4;
        self.clipsToBounds = YES;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.layer.cornerRadius = 4;
        self.clipsToBounds = YES;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 4;
        self.clipsToBounds = YES;
    }
    return self;
}

@end
