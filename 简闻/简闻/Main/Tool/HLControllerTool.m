//
//  HLControllerTool.m
//  新新浪微博
//
//  Created by 韩露露 on 15/12/2.
//  Copyright © 2015年 韩露露. All rights reserved.
//

#import "HLControllerTool.h"
#import "HLTabBarController.h"
#import "HLNewFeatureViewController.h"

@implementation HLControllerTool
+ (UIViewController *)chooseRootViewController {
    NSString *versionKey = (__bridge NSString *)kCFBundleVersionKey;
    NSString *currentVersion = [NSBundle mainBundle].infoDictionary[versionKey];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastVersion = [defaults objectForKey:versionKey];
    if ([lastVersion isEqualToString:currentVersion]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        return [sb instantiateViewControllerWithIdentifier:@"tabBarVc"];
    } else {
        [defaults setObject:currentVersion forKey:versionKey];
        [defaults synchronize];
        return [[HLNewFeatureViewController alloc] init];
    }
}
@end
