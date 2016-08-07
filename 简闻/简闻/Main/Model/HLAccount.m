//
//  HLAccount.m
//  简闻
//
//  Created by 韩露露 on 16/6/12.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLAccount.h"

@implementation HLAccount

static HLAccount *_account = nil;
+ (instancetype)sharedAccount {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _account = [[HLAccount alloc] init];
        _account.notes = [NSArray array];
    });
    return _account;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.rememberPwd = [aDecoder decodeBoolForKey:@"rememberPwd"];
        self.autoLogin = [aDecoder decodeBoolForKey:@"autoLogin"];
        self.emailStatus = [aDecoder decodeIntegerForKey:@"emailStatus"];
        self.platformType = [aDecoder decodeIntegerForKey:@"platformType"];
        self.login = [aDecoder decodeBoolForKey:@"login"];
        self.gender = [aDecoder decodeObjectForKey:@"gender"];
        self.icon = [aDecoder decodeObjectForKey:@"icon"];
        self.uid = [aDecoder decodeObjectForKey:@"uid"];
        self.nickname = [aDecoder decodeObjectForKey:@"nickname"];
        self.pwd = [aDecoder decodeObjectForKey:@"pwd"];
        self.email = [aDecoder decodeObjectForKey:@"email"];
        self.birthday = [aDecoder decodeObjectForKey:@"birthday"];
        self.notes = [aDecoder decodeObjectForKey:@"notes"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeBool:self.rememberPwd forKey:@"rememberPwd"];
    [aCoder encodeBool:self.autoLogin forKey:@"autoLogin"];
    [aCoder encodeBool:self.login forKey:@"login"];
    [aCoder encodeInteger:self.emailStatus forKey:@"emailStatus"];
    [aCoder encodeInteger:self.platformType forKey:@"platformType"];
    [aCoder encodeObject:self.gender forKey:@"gender"];
    [aCoder encodeObject:self.icon forKey:@"icon"];
    [aCoder encodeObject:self.uid forKey:@"uid"];
    [aCoder encodeObject:self.nickname forKey:@"nickname"];
    [aCoder encodeObject:self.pwd forKey:@"pwd"];
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeObject:self.birthday forKey:@"birthday"];
    [aCoder encodeObject:self.notes forKey:@"notes"];
}

@end
