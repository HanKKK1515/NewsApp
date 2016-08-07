//
//  HLAccount.h
//  简闻
//
//  Created by 韩露露 on 16/6/12.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  授权平台
 */
typedef NS_ENUM(NSUInteger, HLPlatformType){
    /**
     *  未知
     */
    kHLPlatformTypeUnknown = 0,
    /**
     *  新浪微博
     */
    kHLPlatformTypeSinaWeibo = 1,
    /**
     *  无平台
     */
    kHLPlatformTypeNone = 2,
    /**
     *  QQ空间
     */
    kHLPlatformSubTypeQZone = 6,
    /**
     *  QQ平台
     */
    kHLPlatformTypeQQ = 998,
};

typedef NS_ENUM(NSUInteger, HLEmailStatusType) {
    kHLEmailStatusTypeNoBinding = 1,
    kHLEmailStatusTypeNoVerify,
    kHLEmailStatusTypeVerified
};

@interface HLAccount : NSObject <NSCoding>

/**
 *  是否自动登录
 */
@property (assign, nonatomic, getter = isAutoLogin) BOOL autoLogin;

/**
 *  是否已登录
 */
@property (assign, nonatomic, getter = isLogin) BOOL login;

/**
 *  是否记住密码
 */
@property (assign, nonatomic, getter = isRememberPwd) BOOL rememberPwd;

/**
 *  是否验证邮箱
 */
@property (assign, nonatomic) HLEmailStatusType emailStatus;

/**
 *  平台类型
 */
@property (assign, nonatomic) HLPlatformType platformType;

/**
 *  用户标识
 */
@property (nonatomic, copy) NSString *uid;

/**
 *  昵称
 */
@property (nonatomic, copy) NSString *nickname;

/**
 *  密码
 */
@property (nonatomic, copy) NSString *pwd;
/**
 *  邮箱
 */
@property (nonatomic, copy) NSString *email;

/**
 *  头像
 */
@property (nonatomic, copy) NSString *icon;

/**
 *  性别
 */
@property (copy, nonatomic) NSString *gender;

/**
 *  生日
 */
@property (nonatomic, copy) NSString *birthday;

/**
 *  备忘
 */
@property (nonatomic, strong) NSArray *notes;

/**
 *  获取用户
 */
+ (instancetype)sharedAccount;

@end
