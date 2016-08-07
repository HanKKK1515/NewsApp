//
//  HLNewsHeaderCell.m
//  简闻
//
//  Created by 韩露露 on 16/8/6.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLNewsHeaderCell.h"
#import "UIImageView+WebCache.h"

@interface HLNewsHeaderCell ()
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@end

@implementation HLNewsHeaderCell

- (void)setIconURL:(NSString *)iconURL {
    _iconURL = iconURL;
    [self.icon sd_setImageWithURL:[NSURL URLWithString:iconURL] placeholderImage:[UIImage imageNamed:@"placeholder"]];
}

+ (instancetype)headerCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    static NSString *headerId = @"headerCell";
    return [collectionView dequeueReusableCellWithReuseIdentifier:headerId forIndexPath:indexPath];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    self.icon.contentMode = UIViewContentModeScaleAspectFill;
    self.icon.clipsToBounds = YES;
}

@end
