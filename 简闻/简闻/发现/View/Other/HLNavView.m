//
//  HLNavView.m
//  简闻
//
//  Created by 韩露露 on 16/5/3.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLNavView.h"

@implementation HLNavView

+ (instancetype)titleView {
    return [[NSBundle mainBundle] loadNibNamed:@"HLNavView" owner:self options:nil].lastObject;
}

@end
