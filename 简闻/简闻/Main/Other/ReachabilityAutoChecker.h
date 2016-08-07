//
//  ReachabilityAutoChecker.h
//  简闻
//
//  Created by 韩露露 on 16/6/13.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface ReachabilityAutoChecker : NSObject

@property (nonatomic, strong) Reachability  *reachability;
@property (nonatomic, assign) NetworkStatus networkStatus;
@property (nonatomic, assign, getter = isConnectionRequired) BOOL connectionRequired;

+ (instancetype)sharedChecker;

@end
