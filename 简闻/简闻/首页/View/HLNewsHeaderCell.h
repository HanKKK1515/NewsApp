//
//  HLNewsHeaderCell.h
//  简闻
//
//  Created by 韩露露 on 16/8/6.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HLNewsHeaderCell : UICollectionViewCell

@property (copy, nonatomic) NSString *iconURL;

+ (instancetype)headerCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end
