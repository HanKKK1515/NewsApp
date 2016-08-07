//
//  HLMore.m
//  简闻
//
//  Created by 韩露露 on 16/5/28.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLMore.h"

@interface HLMore ()
- (IBAction)clickBtn:(UIButton *)sender;

@end

@implementation HLMore

+ (instancetype)more {
    return [[NSBundle mainBundle] loadNibNamed:@"HLMore" owner:self options:nil].lastObject;
}

- (IBAction)clickBtn:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(more:didSelectedType:)]) {
        [self.delegate more:self didSelectedType:sender.tag];
    }
}
@end
