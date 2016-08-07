//
//  HLNewsTableViewCell.h
//  简闻
//
//  Created by 韩露露 on 16/6/1.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLNews.h"

@interface HLNewsTableViewCell : UITableViewCell
@property (strong, nonatomic) HLNews *news;
+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
@end
