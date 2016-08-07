//
//  HLRobotCell.h
//  简闻
//
//  Created by 韩露露 on 16/5/22.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLRobotCellData.h"

@interface HLRobotCell : UITableViewCell
@property (strong, nonatomic) HLRobotCellData *cellData;

+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
@end
