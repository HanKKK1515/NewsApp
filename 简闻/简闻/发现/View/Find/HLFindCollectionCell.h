//
//  HLFindCollectionCell.h
//  简闻
//
//  Created by 韩露露 on 16/8/5.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HLFindCollectionCell : UICollectionViewCell

@property (copy, nonatomic) NSString *icon;
@property (copy, nonatomic) NSString *text;

+ (instancetype)findCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end
