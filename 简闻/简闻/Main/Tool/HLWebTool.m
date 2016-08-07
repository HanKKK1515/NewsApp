//
//  HLWebTool.m
//  简闻
//
//  Created by 韩露露 on 16/5/1.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLWebTool.h"
#import "HLPhoneResponse.h"
#import "MJExtension.h"
#import "AFNetworking.h"

@implementation HLWebTool
+ (void)get:(NSString *)url param:(NSDictionary *)param class:(Class)resultClass success:(void (^)(id responseObject))success failure:(void (^)(NSError *errof))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 20;
    [manager GET:url parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            id response = [resultClass mj_objectWithKeyValues:responseObject];
            success(response);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            failure(error);
        }
    }];
}
@end
