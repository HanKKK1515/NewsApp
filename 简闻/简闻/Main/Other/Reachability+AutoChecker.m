//
//  Reachability+AutoChecker.m
//  简闻
//
//  Created by 韩露露 on 16/6/13.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "Reachability+AutoChecker.h"
#import "ReachabilityAutoChecker.h"

@implementation Reachability (AutoChecker)

+ (void)startCheckWithReachability:(Reachability *)reachability
{
    ReachabilityAutoChecker *checker = [ReachabilityAutoChecker sharedChecker];
    
    if (checker.reachability) {
        [checker.reachability stopNotifier];
        checker.reachability = nil;
    }
    
    checker.reachability = reachability;
    [checker.reachability startNotifier];
}

+ (BOOL)isReachable
{
    ReachabilityAutoChecker *checker = [ReachabilityAutoChecker sharedChecker];
    
    if (!checker.reachability) {
        return NO;
    }
    
    NetworkStatus networkStatus = [checker networkStatus];
    
    if (networkStatus)
        return YES;
    else
        return NO;
}

@end
