//
//  HLFindCollectionCell.m
//  简闻
//
//  Created by 韩露露 on 16/8/5.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLFindCollectionCell.h"

@interface HLFindCollectionCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *textView;

@end

@implementation HLFindCollectionCell

+ (instancetype)findCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath; {
    static NSString *itemId = @"findItem";
    return [collectionView dequeueReusableCellWithReuseIdentifier:itemId forIndexPath:indexPath];
}

- (void)setIcon:(NSString *)icon {
    _icon = icon;
    self.iconView.image = [UIImage imageNamed:icon];
}

- (void)setText:(NSString *)text {
    _text = text;
    self.textView.text = text;
}

@end
