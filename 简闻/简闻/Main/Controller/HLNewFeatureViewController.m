//
//  HLNewFeatureViewController.m
//  简闻
//
//  Created by 韩露露 on 16/6/30.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLNewFeatureViewController.h"
#import "HLTabBarController.h"

#define HLNewFeatureImageCount 4

@interface HLNewFeatureViewController () <UIScrollViewDelegate>
@property (nonatomic, weak) UIPageControl *page;
@end

@implementation HLNewFeatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupScrollView];
    
    [self setupPageControl];
}

- (void)setupScrollView {
    UIScrollView *scroll = [[UIScrollView alloc] init];
    [self.view addSubview:scroll];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *topScr = [NSLayoutConstraint constraintWithItem:scroll attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *bottomScr = [NSLayoutConstraint constraintWithItem:scroll attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *leftScr = [NSLayoutConstraint constraintWithItem:scroll attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *rightScr = [NSLayoutConstraint constraintWithItem:scroll attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    [self.view addConstraints:@[topScr, bottomScr, leftScr, rightScr]];
    
    scroll.pagingEnabled = YES;
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.delegate = self;
    scroll.backgroundColor = [UIColor colorWithRed:246 / 255.0 green:246 / 255.0 blue:246 / 255.0 alpha:1.0];
    
    [self setImageViewInScrollView:scroll];
}

- (void)setImageViewInScrollView:(UIScrollView *)scroll {
    CGFloat imageW = [UIScreen mainScreen].bounds.size.width;
    CGFloat imageH = [UIScreen mainScreen].bounds.size.height;
    for(int i = 0; i < HLNewFeatureImageCount; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"new_feature_%d", i + 1]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [scroll addSubview:imageView];
        
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:imageH];
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:imageW];
        [imageView addConstraints:@[height, width]];
        
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:scroll attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:scroll attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:scroll attribute:NSLayoutAttributeLeft multiplier:1 constant:imageW * i];
        [scroll addConstraints:@[top, bottom, left]];
        
        if(i == HLNewFeatureImageCount - 1) {
            NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:scroll attribute:NSLayoutAttributeRight multiplier:1 constant:0];
            [scroll addConstraint:right];
            imageView.userInteractionEnabled = YES;
            [self setupStartButton:imageView];
        }
    }
}

- (void)setupStartButton:(UIImageView *)image {
    UIButton *startBtn = [[UIButton alloc] init];
    startBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [startBtn setTitle:@"开始体验" forState:UIControlStateNormal];
    [startBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [startBtn setBackgroundImage:[UIImage imageNamed:@"new_feature_finish_button"] forState:UIControlStateNormal];
    [startBtn setBackgroundImage:[UIImage imageNamed:@"new_feature_finish_button_highlighted"] forState:UIControlStateHighlighted];
    [image addSubview:startBtn];
    
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:startBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:image attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:startBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:image attribute:NSLayoutAttributeBottom multiplier:1 constant:-80];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:startBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:startBtn.currentBackgroundImage.size.height];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:startBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:startBtn.currentBackgroundImage.size.width];
    [image addConstraints:@[centerX, bottom]];
    [startBtn addConstraints:@[height, width]];
    
    [startBtn addTarget:self action:@selector(startBtn) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupPageControl {
    UIPageControl *page = [[UIPageControl alloc] init];
    page.translatesAutoresizingMaskIntoConstraints = NO;
    page.numberOfPages = HLNewFeatureImageCount;
    page.pageIndicatorTintColor = [UIColor grayColor];
    page.currentPageIndicatorTintColor = [UIColor redColor];
    [self.view addSubview:page];
    
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:page attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:page attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-30];
    [self.view addConstraints:@[centerX, bottom]];
    self.page = page;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat doubleX = scrollView.contentOffset.x / scrollView.frame.size.width;
    int  intX = (int)(doubleX + 0.5);
    self.page.currentPage = intX;
}

- (void)startBtn {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    HLTabBarController *tab = [sb instantiateViewControllerWithIdentifier:@"tabBarVc"];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.rootViewController = tab;
}

@end