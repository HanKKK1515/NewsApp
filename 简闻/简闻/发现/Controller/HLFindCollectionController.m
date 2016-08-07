//
//  HLFindCollectionController.m
//  简闻
//
//  Created by 韩露露 on 16/8/5.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLFindCollectionController.h"
#import "HLFindIconModel.h"
#import "HLFindCollectionCell.h"

static  NSString * const itemId = @"findItem";

@interface HLFindCollectionController ()

@property (strong, nonatomic) NSArray *icons;

@end

@implementation HLFindCollectionController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerNib:[UINib nibWithNibName:@"HLFindCollectionCell" bundle:nil] forCellWithReuseIdentifier:itemId];
    [self setupFlowLayout];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChange) name:UIApplicationDidChangeStatusBarOrientationNotification object:[UIApplication sharedApplication]];
}

- (void)deviceOrientationChange {
    [self setupFlowLayout];
    [self.view layoutSubviews];
}

- (void)setupFlowLayout {
    CGFloat colNo = 3;
    CGFloat colMargin = 40;
    CGFloat rowMargin = 0;
    CGFloat insetTop = 20;
    CGFloat insetLeft = 40;
    CGFloat insetBottom = 20;
    CGFloat insetRight = 40;
    CGFloat labelH = 40;
    CGFloat collectionW = self.collectionView.frame.size.width;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
            colNo = 6;
            colMargin = insetLeft = insetRight = 20;
        } else {
            colMargin = insetLeft = insetRight = 80;
        }
    }
    
    CGFloat itemW = (collectionW - (colNo - 1) * colMargin - insetLeft - insetRight) / colNo;
    CGFloat itemH = itemW + labelH;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.headerReferenceSize = CGSizeMake(collectionW, collectionW * 0.3);
    layout.itemSize = CGSizeMake(itemW, itemH);
    layout.minimumLineSpacing = rowMargin;
    layout.minimumInteritemSpacing = colMargin;
    layout.sectionInset = UIEdgeInsetsMake(insetTop, insetLeft, insetBottom, insetRight);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.icons.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HLFindCollectionCell *cell = [HLFindCollectionCell findCellWithCollectionView:collectionView indexPath:indexPath];
    HLFindIconModel *iconModel = self.icons[indexPath.item];
    cell.icon = iconModel.icon;
    cell.text = iconModel.text;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    HLFindIconModel *model = self.icons[indexPath.item];
    [self performSegueWithIdentifier:model.icon sender:self];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"findHeader" forIndexPath:indexPath];
        return header;
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"findFooter" forIndexPath:indexPath];
        return footer;
    }
    return nil;
}

- (NSArray *)icons {
    if (!_icons) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"findIcon.plist" ofType:nil];
        NSArray *iconsDict = [NSArray arrayWithContentsOfFile:path];
        NSMutableArray *iconsArray = [NSMutableArray array];
        for (NSDictionary *dict in iconsDict) {
            HLFindIconModel *icon = [HLFindIconModel iconWithDict:dict];
            [iconsArray addObject:icon];
        }
        self.icons = iconsArray;
    }
    return _icons;
}

@end
