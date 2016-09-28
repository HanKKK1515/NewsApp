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
#import "HLNewsHotResponse.h"
#import "HLNewsResponse.h"
#import "Reachability+AutoChecker.h"
#import "FMDB.h"

#define HLStopRefreshWithCountNotif(obj) [[NSNotificationCenter defaultCenter] postNotificationName:@"stopRefreshWithNewsCount" object:obj]
#define HLSetupHeaderViewDataNotif [[NSNotificationCenter defaultCenter] postNotificationName:@"setupHeaderViewData" object:nil]
#define HLReloadDataNotif [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil]
#define HLEndHeaderRefreshingNotif [[NSNotificationCenter defaultCenter] postNotificationName:@"endHeaderRefreshing" object:nil]
#define HLNetworkErrorNotif [[NSNotificationCenter defaultCenter] postNotificationName:@"networkError" object:nil]
#define HLTitleBecomeFirstResponder [[NSNotificationCenter defaultCenter] postNotificationName:@"titleBecomeFirstResponder" object:nil]
#define HLNoNews [[NSNotificationCenter defaultCenter] postNotificationName:@"noNews" object:nil]

static BOOL _all;
static NSMutableArray *_hotNewsAllTitle;
static NSMutableArray *_hotNewsTitle;
static NSMutableArray *_newsFirstes;
static int _newCount;
static FMDatabaseQueue *_dbq;
static int _page;

@implementation HLWebTool

+ (void)initialize
{
    _hotNewsTitle = [NSMutableArray array];
    _hotNewsAllTitle =[NSMutableArray array];
    _newsFirstes = [NSMutableArray array];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"news.sqlite"];
    _dbq = [FMDatabaseQueue databaseQueueWithPath:path];
    [_dbq inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_news (id integer PRIMARY KEY AUTOINCREMENT, time text NOT NULL UNIQUE, contents blob NOT NULL)"];
    }];
}

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

+ (void)getNewsHot:(void (^)(NSMutableArray *allNews))success {
    _all = YES;
    NSString *url = @"http://op.juhe.cn/onebox/news/words";
    NSDictionary *attribute = @{@"key" : @"2acf8e073270584d037f5da1ba51fb24"};
    [self get:url param:attribute class:[HLNewsHotResponse class] success:^(id responseObject) {
        HLNewsHotResponse *response = responseObject;
        if ([response.reason isEqualToString:@"查询成功"] && _all) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"!SELF in %@", _hotNewsAllTitle];
            _hotNewsTitle = [response.result filteredArrayUsingPredicate:predicate].mutableCopy;
            if (_hotNewsTitle.count) {
                [_hotNewsAllTitle addObjectsFromArray:_hotNewsTitle];
                [self setData:^(NSMutableArray *allNews) {
                    success(allNews);
                }];
            } else {
                success(_newsFirstes);
                HLStopRefreshWithCountNotif(@(0));
                HLSetupHeaderViewDataNotif;
                HLReloadDataNotif;
            }
        } else if (_all) {
            success(_newsFirstes);
            HLStopRefreshWithCountNotif(@(0));
            HLSetupHeaderViewDataNotif;
            HLReloadDataNotif;
        } else {
            HLEndHeaderRefreshingNotif;
            HLSetupHeaderViewDataNotif;
            HLReloadDataNotif;
        }
    } failure:^(NSError *error) {
        if (_all) {
            success(_newsFirstes);
            HLStopRefreshWithCountNotif(@(0));
            HLNetworkErrorNotif;
        } else {
            HLEndHeaderRefreshingNotif;
        }
        HLSetupHeaderViewDataNotif;
        HLReloadDataNotif;
    }];
}

+ (void)setData:(void (^)(NSMutableArray *allNews))success {
    _newCount = 0;
    NSUInteger allOldNewsCount = _newsFirstes.count;
    int hotCount = (int)_hotNewsTitle.count;
    __block int responseCount = 0;
    for (int i = 0; i < hotCount; i++) {
        NSString *keyword = _hotNewsTitle[i];
        NSString *url = @"http://op.juhe.cn/onebox/news/query";
        NSDictionary *attribute = @{@"q" : keyword, @"key" : @"2acf8e073270584d037f5da1ba51fb24"};
        [HLWebTool get:url param:attribute class:[HLNewsResponse class] success:^(id responseObject) {
            HLNewsResponse *response = responseObject;
            if ([response.reason isEqualToString:@"查询成功"] && _all) {
                HLNews *news = response.result.firstObject;
                [self insertNews:news inArray:_newsFirstes];
                [self saveCacheNewsWithNew:news];
                _newCount++;
            }
            responseCount++;
            if (_newCount == 1) {
                success(_newsFirstes);
                HLSetupHeaderViewDataNotif;
                HLReloadDataNotif;
            }
            if (!(responseCount % 10) && _all) {
                success(_newsFirstes);
                HLSetupHeaderViewDataNotif;
                HLReloadDataNotif;
            }
            if (responseCount == hotCount) {
                if (_all) {
                    success(_newsFirstes);
                    HLStopRefreshWithCountNotif(@(_newsFirstes.count - allOldNewsCount));
                } else {
                    HLEndHeaderRefreshingNotif;
                }
                HLSetupHeaderViewDataNotif;
                HLReloadDataNotif;
            }
        } failure:^(NSError *error) {
            responseCount++;
            if (responseCount == hotCount) {
                if (_all) {
                    success(_newsFirstes);
                    HLStopRefreshWithCountNotif(@(_newsFirstes.count - allOldNewsCount));
                    HLNetworkErrorNotif;
                } else {
                    HLEndHeaderRefreshingNotif;
                }
                HLSetupHeaderViewDataNotif;
                HLReloadDataNotif;
            }
        }];
    }
}

+ (void)insertNews:(HLNews *)news inArray:(NSMutableArray *)array {
    if (array.count > 0) {
        for (int i = 0; i < array.count; i++) {
            HLNews *tempNews = array[i];
            if ([news.title isEqualToString:tempNews.title]) return;
            
            NSComparisonResult result = [news.pdate_src compare:tempNews.pdate_src];
            if ((result == NSOrderedDescending) || (result == NSOrderedSame)) {
                [array insertObject:news atIndex:i];
                return;
            } else if (i == array.count - 1) {
                [array addObject:news];
                return;
            }
        }
    } else {
        [array addObject:news];
    }
}

+ (void)getNewsWithKeyword:(NSString *)keyword success:(void (^)(NSMutableArray *allNews))success {
    _all = NO;
    _newCount = 0;
    NSString *url = @"http://op.juhe.cn/onebox/news/query";
    NSDictionary *attribute = @{@"q" : keyword, @"key" : @"2acf8e073270584d037f5da1ba51fb24"};
    [HLWebTool get:url param:attribute class:[HLNewsResponse class] success:^(id responseObject) {
        HLNewsResponse *response = responseObject;
        if ([response.reason isEqualToString:@"查询成功"] && !_all) {
            success(response.result.mutableCopy);
            _newCount = (int)response.result.count;
        } else if (!_all) {
            HLNoNews;
            HLTitleBecomeFirstResponder;
        }
        if (_all) {
            HLEndHeaderRefreshingNotif;
        } else {
            HLStopRefreshWithCountNotif(@(_newCount));
        }
        HLSetupHeaderViewDataNotif;
        HLReloadDataNotif;
    } failure:^(NSError *error) {
        if (_all) {
            HLEndHeaderRefreshingNotif;
        } else {
            HLStopRefreshWithCountNotif(@(0));
            HLNetworkErrorNotif;
            HLTitleBecomeFirstResponder;
        }
        HLSetupHeaderViewDataNotif;
        HLReloadDataNotif;
    }];
}

+ (void)saveCacheNewsWithNew:(HLNews *)new {
    [_dbq inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQueryWithFormat:@"SELECT time FROM t_news WHERE time = %@", new.pdate_src];
        if (!result.next) {
            NSData *newData = [NSKeyedArchiver archivedDataWithRootObject:new];
            [db executeUpdateWithFormat:@"INSERT INTO t_news (time, contents) VALUES (%@, %@);", new.pdate_src, newData];
        }
        [result close];
    }];
}

+ (void)getNewsFromCache:(BOOL)cache success:(void (^)(NSMutableArray *allNews))success {
    if (cache) {
        NSUInteger count = _newsFirstes.count;
        [_dbq inDatabase:^(FMDatabase *db) {
            FMResultSet *result = [db executeQueryWithFormat:@"SELECT contents FROM t_news ORDER BY time DESC LIMIT %d, 20", _page * 20];
            while (result.next) {
                NSData *data = [result dataForColumn:@"contents"];
                HLNews *new = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                [self insertNews:new inArray:_newsFirstes];
            }
            [result close];
            if (count != _newsFirstes.count) {
                _page++;
            }
            success(_newsFirstes);
            HLStopRefreshWithCountNotif(@(_newsFirstes.count - count));
            HLSetupHeaderViewDataNotif;
            HLReloadDataNotif;
        }];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([Reachability isReachable]) {
                [self getNewsHot:^(NSMutableArray *allNews) {
                    success(allNews);
                }];
            } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if ([Reachability isReachable]) {
                        [self getNewsHot:^(NSMutableArray *allNews) {
                            success(allNews);
                        }];
                    } else {
                        success(_newsFirstes);
                        HLNetworkErrorNotif;
                    }
                });
            }
        });
    }
}

@end
