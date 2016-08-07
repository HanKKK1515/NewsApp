//
//  HLTool.h
//  简闻
//
//  Created by 韩露露 on 16/4/21.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLAccount.h"

@interface HLTool : NSObject

+ (void)creatWithObject:(id)object;
+ (void)modifyWithObject:(id)object;
+ (void)deleteWithObject:(id)object;
+ (void)clearAllDataWithFileName:(NSString *)name;
+ (NSMutableArray *)listAllDataWithFileName:(NSString *)name;
+ (void)clearCache;
+ (NSString *)getCacheSize;
+ (void)saveAccount:(HLAccount *)account;
+ (HLAccount *)getAccount;
+ (void)delegateAccount;
@end
