//
//  NSString+md5.m
//  简闻
//
//  Created by 韩露露 on 16/8/5.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "NSString+md5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (md5)

- (NSString *)md5String {
    const char *myPasswd = self.UTF8String;
    unsigned char mdc[16];
    CC_MD5 (myPasswd, (CC_LONG)strlen(myPasswd), mdc);
    NSMutableString *md5String = [NSMutableString string];
    [md5String appendFormat:@"%02x" ,mdc[0]];
    for (int i = 1 ; i < 16 ; i++) {
        [md5String appendFormat:@"%02x", mdc[i]^mdc[0]];
    }
    
    return md5String;
}

@end
