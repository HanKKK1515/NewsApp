//
//  HLNewsTableViewCell.m
//  简闻
//
//  Created by 韩露露 on 16/6/1.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLNewsTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "NSDate+HL.h"

@interface HLNewsTableViewCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeTopTitle;

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UILabel *timeView;
@property (weak, nonatomic) IBOutlet UILabel *sourceView;
@property (weak, nonatomic) IBOutlet UILabel *content;
@end

@implementation HLNewsTableViewCell

- (void)setNews:(HLNews *)news {
    _news = news;
    if (news.img.length) {
        self.iconLeft.constant = 10;
        self.iconWidth.constant = 60;
        self.timeTop.priority = UILayoutPriorityDefaultHigh;
        self.timeTopTitle.priority = UILayoutPriorityDefaultLow;
        self.iconView.hidden = NO;
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:news.img] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    } else {
        self.iconLeft.constant = 0;
        self.iconWidth.constant = 0;
        self.timeTop.priority = UILayoutPriorityDefaultLow;
        self.timeTopTitle.priority = UILayoutPriorityDefaultHigh;
        self.iconView.hidden = YES;
    }
    
    self.titleView.text = news.title;
    self.timeView.text = [NSDate timeIntervarWithDate:news.date];
    self.sourceView.text = news.src;
    self.content.text = news.content;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"newsCell";
    return [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
}

@end
