//
//  Reachability+AutoChecker.h
//  简闻
//
//  Created by 韩露露 on 16/6/13.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "Reachability.h"

@interface Reachability (AutoChecker)
+ (void)startCheckWithReachability:(Reachability *)reachability;
+ (BOOL)isReachable;
@end
