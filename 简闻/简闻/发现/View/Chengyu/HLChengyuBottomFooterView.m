//
//  HLChengyuBottomFooterView.m
//  简闻
//
//  Created by 韩露露 on 16/5/19.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLChengyuBottomFooterView.h"

@implementation HLChengyuBottomFooterView

+ (instancetype)bottomFooterView {
    return [[NSBundle mainBundle] loadNibNamed:@"HLChengyuBottomFooterView" owner:self options:nil].lastObject;
}

@end
