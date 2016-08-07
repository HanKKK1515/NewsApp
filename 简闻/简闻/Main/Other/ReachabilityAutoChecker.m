//
//  ReachabilityAutoChecker.m
//  简闻
//
//  Created by 韩露露 on 16/6/13.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "ReachabilityAutoChecker.h"

@implementation ReachabilityAutoChecker
@synthesize reachability;
static ReachabilityAutoChecker *_staticChecker = nil;
+ (instancetype)sharedChecker {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _staticChecker = [[ReachabilityAutoChecker alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:_staticChecker selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        _staticChecker.networkStatus = NotReachable;
        _staticChecker.connectionRequired = NO;
    });
    return _staticChecker;
}

- (void)reachabilityChanged:(NSNotification* )note {
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    self.networkStatus = [curReach currentReachabilityStatus];
    self.connectionRequired = [curReach connectionRequired];
}
@end
