//
//  HLRobotResponse.h
//  简闻
//
//  Created by 韩露露 on 16/5/22.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLRobotResult.h"

@interface HLRobotResponse : NSObject
@property (assign, nonatomic) int error_code;
@property (copy, nonatomic) NSString *reason;
@property (strong, nonatomic) HLRobotResult *result;
@end
