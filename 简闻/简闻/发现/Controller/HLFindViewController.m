//
//  HLFindViewController.m
//  简闻
//
//  Created by 韩露露 on 16/5/26.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLFindViewController.h"

@interface HLFindViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeight;
@end

@implementation HLFindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.viewHeight.constant = [UIScreen mainScreen].bounds.size.width;
}

@end
