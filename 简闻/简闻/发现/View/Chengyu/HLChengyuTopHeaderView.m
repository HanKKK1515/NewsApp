//
//  HLChengyuTopHeaderView.m
//  简闻
//
//  Created by 韩露露 on 16/5/17.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLChengyuTopHeaderView.h"

@interface HLChengyuTopHeaderView ()
@property (weak, nonatomic) IBOutlet UILabel *chengyu;
@property (weak, nonatomic) IBOutlet UILabel *pinyin;

@end

@implementation HLChengyuTopHeaderView

+ (instancetype)topHeaderView {
    return [[NSBundle mainBundle] loadNibNamed:@"HLChengyuTopHeaderView" owner:self options:nil].lastObject;
}

- (void)chengyu:(NSString *)chengyu pinyin:(NSString *)pinyin {
    self.chengyu.text = chengyu;
    self.pinyin.text = pinyin;
}

@end
