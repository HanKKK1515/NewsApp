//
//  HLTool.m
//  简闻
//
//  Created by 韩露露 on 16/4/21.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLTool.h"
#import "HLMemo.h"
#import "HLRobotCellData.h"
#import "SDImageCache.h"
#import <BmobSDK/Bmob.h>

@implementation HLTool

+ (void)saveAccount:(HLAccount *)account {
    BmobUser *bUser = [BmobUser getCurrentUser];
    if (bUser) {
        bUser.username = account.nickname;
        bUser.email = account.email;
        bUser.password = account.pwd;
        [bUser setObject:account.gender forKey:@"gender"];
        [bUser setObject:account.birthday forKey:@"birthday"];
        [bUser setObject:account.icon forKey:@"icon"];
        [bUser setObject:account.uid forKey:@"uid"];
        [bUser setObject:[NSNumber numberWithUnsignedLong:account.platformType] forKey:@"platformType"];
        [bUser updateInBackground];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    HLAccount *act = account;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:act];
    [defaults setObject:data forKey:@"act"];
}

+ (HLAccount *)getAccount {
    HLAccount *account = [HLAccount sharedAccount];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"act"];
    
    if (data) {
       HLAccount *accTemp = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        account.rememberPwd = accTemp.rememberPwd;
        account.autoLogin = accTemp.autoLogin;
        account.login = accTemp.login;
        account.platformType = accTemp.platformType;
        account.gender = accTemp.gender;
        account.icon = accTemp.icon;
        account.uid = accTemp.uid;
        account.nickname = accTemp.nickname;
        account.pwd = accTemp.pwd;
        account.birthday = accTemp.birthday;
        account.emailStatus = accTemp.emailStatus;
        account.email = accTemp.email;
    }
    
    account.login = account.isAutoLogin && account.isLogin;
    if (account.login) {
        __weak typeof(self) tool = self;
        [BmobUser loginInbackgroundWithAccount:account.nickname andPassword:account.pwd block:^(BmobUser *user, NSError *error) {
            if (user) {
                account.nickname = user.username;
                account.email = user.email;
                account.gender = [user objectForKey:@"gender"];
                account.birthday = [user objectForKey:@"birthday"];
                account.icon = [user objectForKey:@"icon"];
                account.uid = [user objectForKey:@"uid"];
                account.platformType = [[user objectForKey:@"platformType"] unsignedLongValue];
                
                BmobQuery *bquery = [BmobQuery queryWithClassName:@"notes"];
                [bquery whereObjectKey:@"myNotes" relatedTo:[BmobUser getCurrentUser]];
                [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
                    NSMutableArray *memos = [NSMutableArray array];
                    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        BmobObject *note = obj;
                        HLMemo *memo = [[HLMemo alloc] init];
                        memo.title = [note objectForKey:@"title"];
                        memo.text = [note objectForKey:@"text"];
                        memo.date = [note objectForKey:@"date"];
                        [tool insertNews:memo inArray:memos];
                    }];
                    account.notes = memos;
                }];
            } else {
                account.login = NO;
            }
        }];
    } else {
        account.notes = [NSArray array];
    }
    
    return account;
}

+ (void)insertNews:(HLMemo *)memo inArray:(NSMutableArray *)array {
    if (array.count > 0) {
        for (int i = 0; i < array.count; i++) {
            HLMemo *tempMemo = array[i];
            NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
            fmt.dateFormat = @"yyyy-MM-dd hh:mm:ss";
            NSComparisonResult result = [[fmt stringFromDate:memo.date] compare:[fmt stringFromDate:tempMemo.date]];
            if ((result == NSOrderedDescending) || (result == NSOrderedSame)) {
                [array insertObject:memo atIndex:i];
                return;
            } else if (i == array.count - 1) {
                [array addObject:memo];
                return;
            }
        }
    } else {
        [array addObject:memo];
    }
}

+ (void)delegateAccount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"act"];
}

+ (void)creatWithObject:(id)object {
    if ([object isMemberOfClass:[HLMemo class]]) {
        HLMemo *memo = object;
        HLAccount *account = [HLAccount sharedAccount];
        NSMutableArray *array = account.notes.mutableCopy;
        if (!array) {
            array = [NSMutableArray array];
        }
        memo.date = [NSDate date];
        memo.title = [self newTitle:memo.title withArray:array];
        [array insertObject:memo atIndex:0];
        account.notes = array;
        __weak typeof(self) tool = self;
        BmobUser *bUser = [BmobUser getCurrentUser];
        BmobObject *note = [BmobObject objectWithClassName:@"notes"];
        [note setObject:memo.title forKey:@"title"];
        [note setObject:memo.text forKey:@"text"];
        [note setObject:memo.date forKey:@"date"];
        [note saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful) {
                BmobRelation *relation = [[BmobRelation alloc] init];
                [relation addObject:note];
                [bUser addRelation:relation forKey:@"myNotes"];
                [bUser updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    if (isSuccessful) {
                        [tool saveAccount:account];
                    } else {
                        [note deleteInBackground];
                    }
                }];
            }
        }];
        
        NSDictionary *userInfo = @{@"userInfo" : account.notes};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"memoDidChangeNotification" object:nil userInfo: userInfo];
    } else if ([object isMemberOfClass:HLRobotCellData.class]) {
        NSString *path = [self applicationDocumentPathWithFileName:@"robot.rrr"];
        NSMutableArray *listRobot = [self listAllDataWithFileName:@"robot.rrr"];
        HLRobotCellData *robot = object;
        robot.date = [NSDate date];
        [listRobot addObject:robot];
        [NSKeyedArchiver archiveRootObject:listRobot toFile:path];
        
        NSDictionary *userInfo = @{@"userInfo" : listRobot};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"robotDidChangeNotification" object:nil userInfo: userInfo];
    }
}

+ (void)modifyNoteWithNewObj:(HLMemo *)newObj oldDate:(NSDate *)oldDate account:(HLAccount *)account {
    
    __weak typeof(self) tool = self;
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"notes"];
    [bquery whereObjectKey:@"myNotes" relatedTo:[BmobUser getCurrentUser]];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BmobObject *noteO = obj;
            NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
            fmt.dateFormat = @"yyyy-MM-dd hh:mm:ss";
            NSDate *date = [noteO objectForKey:@"date"];
            if ([[fmt stringFromDate:date] isEqualToString:[fmt stringFromDate:oldDate]]) {
                BmobUser *bUser = [BmobUser getCurrentUser];
                BmobObject *noteN = [BmobObject objectWithClassName:@"notes"];
                [noteN setObject:newObj.title forKey:@"title"];
                [noteN setObject:newObj.text forKey:@"text"];
                [noteN setObject:newObj.date forKey:@"date"];
                [noteN saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    if (isSuccessful) {
                        BmobRelation *relation = [[BmobRelation alloc] init];
                        [relation addObject:noteN];
                        [bUser addRelation:relation forKey:@"myNotes"];
                        [bUser updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                            if (isSuccessful) {
                                [tool removeNote:noteO user:bUser account:account];
                            } else {
                                [noteN deleteInBackground];
                            }
                        }];
                    }
                }];
                *stop = YES;
            }
        }];
    }];
}

+ (void)removeNote:(BmobObject *)noteO user:(BmobUser *)bUser account:(HLAccount *)account {
    BmobRelation *relation = [[BmobRelation alloc] init];
    [relation removeObject:noteO];
    [bUser addRelation:relation forKey:@"myNotes"];
    [bUser updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            [noteO deleteInBackground];
            [self saveAccount:account];
        } else {
            [noteO deleteInBackground];
        }
    }];
}

+ (void)modifyWithObject:(id)object {
    if ([object isMemberOfClass:[HLMemo class]]) {
        __weak typeof(self) tool = self;
        HLMemo *newObj = object;
        NSDate *oldDate = newObj.date;
        HLAccount *account = [HLAccount sharedAccount];
        NSMutableArray *listMemo = account.notes.mutableCopy;
        [listMemo enumerateObjectsUsingBlock:^(HLMemo *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.date isEqualToDate:newObj.date]) {
                newObj.date = [NSDate date];
                if (![obj.title isEqualToString:newObj.title]) {
                    newObj.title = [tool newTitle:newObj.title withArray:listMemo];
                }

                [listMemo removeObject:obj];
                [listMemo insertObject:newObj atIndex:0];
                *stop = YES;
            }
        }];
        account.notes = listMemo;
        
        [self modifyNoteWithNewObj:newObj oldDate:oldDate account:account];
        
        NSDictionary *userInfo = @{@"userInfo" : account.notes};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"memoDidChangeNotification" object:nil userInfo: userInfo];
    }
}

+ (NSString *)newTitle:(NSString *)title withArray:(NSArray *)array {
    static NSUInteger i = 1;
    NSString *str = title;
    for (HLMemo *obj in array) {
        if ([obj.title isEqualToString:str]) {
            NSRange range = [str rangeOfString:[NSString stringWithFormat:@"(%lu)", (unsigned long)i]];
            if (range.location == NSNotFound) {
                str = [str stringByAppendingString:@"(1)"];
            } else {
                str = [str stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"(%lu)", (unsigned long)++i]];
            }
            return [self newTitle:str withArray:array];
        }
    }
    i = 1;
    return str;
}

+ (void)deleteWithObject:(id)object {
    if ([object isMemberOfClass:[HLMemo class]]) {
        HLMemo *deleMemo = object;
        NSDate *oldDate = deleMemo.date;
        HLAccount *account = [HLAccount sharedAccount];
        NSMutableArray *listMemo = account.notes.mutableCopy;
        [listMemo enumerateObjectsUsingBlock:^(HLMemo *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.date isEqualToDate:deleMemo.date]) {
                [listMemo removeObject:obj];
                *stop = YES;
            }
        }];
        account.notes = listMemo;
        
        __weak typeof(self) tool = self;
        BmobQuery *bquery = [BmobQuery queryWithClassName:@"notes"];
        [bquery whereObjectKey:@"myNotes" relatedTo:[BmobUser getCurrentUser]];
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                BmobObject *noteO = obj;
                NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
                fmt.dateFormat = @"yyyy-MM-dd hh:mm:ss";
                NSDate *date = [noteO objectForKey:@"date"];
                if ([[fmt stringFromDate:date] isEqualToString:[fmt stringFromDate:oldDate]]) {
                    [tool removeNote:noteO user:[BmobUser getCurrentUser] account:account];
                    *stop = YES;
                }
            }];
        }];
        NSDictionary *userInfo = @{@"userInfo" : account.notes};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"memoDidChangeNotification" object:nil userInfo: userInfo];
    } else if ([object isMemberOfClass:HLRobotCellData.class]) {
        HLRobotCellData *deleRobot = object;
        NSString *path = [self applicationDocumentPathWithFileName:@"robot.rrr"];
        NSMutableArray *listRobot = [self listAllDataWithFileName:@"robot.rrr"];
        [listRobot enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            HLRobotCellData *robot = obj;
            if ([robot.text isEqualToString:deleRobot.text]) {
                [listRobot removeObject:robot];
                *stop = YES;
            }
        }];
        [NSKeyedArchiver archiveRootObject:listRobot toFile:path];
        
        NSDictionary *userInfo = @{@"userInfo" : listRobot};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"robotDidChangeNotification" object:nil userInfo: userInfo];
    }
}

+ (void)clearAllDataWithFileName:(NSString *)name {
    if ([name isEqualToString:@"robot.rrr"]) {
        NSString *path = [self applicationDocumentPathWithFileName:@"robot.rrr"];
        NSMutableArray *listRobot = [self listAllDataWithFileName:@"robot.rrr"];
        [listRobot removeAllObjects];
        [NSKeyedArchiver archiveRootObject:listRobot toFile:path];
        
        NSDictionary *userInfo = @{@"userInfo" : listRobot};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"robotDidChangeNotification" object:nil userInfo: userInfo];
    }
}

+ (NSMutableArray *)listAllDataWithFileName:(NSString *)name {
    NSMutableArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:[self applicationDocumentPathWithFileName:name]];
    return array ? array : [NSMutableArray array];
}

+ (NSString *)applicationDocumentPathWithFileName:(NSString *)name {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    return [path stringByAppendingPathComponent:name];
}

+ (void)clearCache {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    path = [path stringByAppendingPathComponent:@"robot.rrr"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:nil];
    }
    SDImageCache *cache = [SDImageCache sharedImageCache];
    [cache cleanDisk];
    [cache clearDisk];
    [cache clearMemory];
}

+ (NSString *)getCacheSize {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    path = [path stringByAppendingPathComponent:@"robot.rrr"];
    long long robotSize = [self fileSizeAtPath:path];
    long long cacheSize = [[SDImageCache sharedImageCache] getSize];
    long long totalSize = (robotSize + cacheSize) / 1024.0 / 1024.0;
    NSString *cacheStr = nil;
    if (totalSize >= 0.1) {
        cacheStr = [NSString stringWithFormat:@"%.2fM", (float)totalSize];
    } else {
        cacheStr = @"无缓存";
    }
    return cacheStr;
}

+ (long long)fileSizeAtPath:(NSString *)path {
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path]){
        long long size=[fileManager attributesOfItemAtPath:path error:nil].fileSize;
        return size;
    }
    return 0;
}

@end
