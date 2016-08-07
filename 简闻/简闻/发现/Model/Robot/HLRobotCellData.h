//
//  HLRobotCellData.h
//  简闻
//
//  Created by 韩露露 on 16/5/22.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    HLRobotTypeRobot,
    HLRobotTypeMe
} HLRobotType;

@interface HLRobotCellData : NSObject <NSCoding>
@property (copy, nonatomic) NSString *text;
@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) HLRobotType type;
@property (assign, nonatomic, getter = isHiddenTime) BOOL hiddenTime;
@end
