//
//  HLToolBar.m
//  简闻
//
//  Created by 韩露露 on 16/6/4.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLToolBar.h"

@interface HLToolBar ()
@property (weak, nonatomic) IBOutlet UIButton *back;
@property (weak, nonatomic) IBOutlet UIButton *go;
@property (weak, nonatomic) IBOutlet UIButton *refresh;

- (IBAction)clickBtn:(UIButton *)sender;
@end

@implementation HLToolBar

- (IBAction)clickBtn:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(toolBar:didClickBtn:)]) {
        [self.delegate toolBar:self didClickBtn:sender.tag];
    }
}

+ (instancetype)toolBar {
    return [[NSBundle mainBundle] loadNibNamed:@"HLToolBar" owner:self options:nil].lastObject;
}

- (void)setEnableBack:(BOOL)enableBack {
    _enableBack = enableBack;
    _back.enabled = enableBack;
}

- (void)setEnableGo:(BOOL)enableGo {
    _enableGo = enableGo;
    _go.enabled = enableGo;
}

- (void)setRefreshing:(BOOL)refreshing {
    _refreshing = refreshing;
    if (self.isRefreshing) {
        [self.refresh setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    } else {
        [self.refresh setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    }
}

@end
