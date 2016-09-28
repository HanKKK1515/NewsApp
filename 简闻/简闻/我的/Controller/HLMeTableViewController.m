//
//  HLMeTableViewController.m
//  简闻
//
//  Created by 韩露露 on 16/6/10.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLMeTableViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import "UIImageView+WebCache.h"
#import "NSDate+HL.h"
#import "HLTool.h"
#import "MBProgressHUD+MJ.h"
#import <BmobSDK/Bmob.h>
#import "HLForgetPwdViewController.h"
#import "HLGenderView.h"
#import "HLBirthdayView.h"
#import "HLMemo.h"
#import "NSString+md5.h"


#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "WeiboSDK.h"


@interface HLMeTableViewController ()
@property (strong, nonatomic) HLAccount *account;
@property (weak, nonatomic) UITextField *genderView;
@property (weak, nonatomic) UITextField *birthdayView;

- (IBAction)login:(HLButton *)sender;
- (IBAction)tencent;
- (IBAction)sina;
@end

@implementation HLMeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self setupNotif];
    
    self.account.login = self.account.isAutoLogin && self.account.isLogin;
}

- (void)setupNotif {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(genderDidChoice:) name:@"genderDidChoice" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectedBirthday:) name:@"didSelectedDateNotification" object:nil];
}

- (void)genderDidChoice:(NSNotification *)notif {
    self.genderView.text = notif.userInfo[@"userInfo"];
}

- (void)didSelectedBirthday:(NSNotification *)notif {
    NSDate *date = notif.userInfo[@"userInfo"];
    self.birthdayView.text = date.stringWithYMD;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refreshEmailCell];
}

- (void)refreshEmailCell {
    if (self.account.isLogin) {
        __weak NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
        __weak UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        [BmobUser loginInbackgroundWithAccount:self.account.nickname andPassword:self.account.pwd block:^(BmobUser *user, NSError *error) {
            if (user) {
                NSString *email = @"";
                if (user.email.length > 0) {
                    if ([[user objectForKey:@"emailVerified"] boolValue]) {
                        self.account.emailStatus = kHLEmailStatusTypeVerified;
                        email = self.account.email;
                    } else {
                        self.account.emailStatus = kHLEmailStatusTypeNoVerify;
                        email = [NSString stringWithFormat:@"%@(未验证)", self.account.email];
                    }
                } else {
                    self.account.emailStatus = kHLEmailStatusTypeNoBinding;
                    email = @"绑定邮箱";
                }
                cell.detailTextLabel.text = email;
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
    }
}

/**
 *  更新本地账户信息
 */
- (void)setupAccount:(BmobUser *)user {
    self.account.nickname = user.username;
    self.account.email = user.email;
    self.account.login = YES;
    self.account.rememberPwd = YES;
    self.account.autoLogin = YES;
    self.account.pwd = [user objectForKey:@"uid"];
    self.account.uid = [user objectForKey:@"uid"];
    self.account.gender = [user objectForKey:@"gender"];
    self.account.birthday = [user objectForKey:@"birthday"];
    self.account.icon = [user objectForKey:@"icon"];
    self.account.platformType = [[user objectForKey:@"platformType"] unsignedLongValue];
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"notes"];
    [bquery whereObjectKey:@"myNotes" relatedTo:[BmobUser currentUser]];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        NSMutableArray *memos = [NSMutableArray array];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BmobObject *note = obj;
            HLMemo *memo = [[HLMemo alloc] init];
            memo.title = [note objectForKey:@"title"];
            memo.text = [note objectForKey:@"text"];
            memo.date = [note objectForKey:@"date"];
            [self insertNews:memo inArray:memos];
        }];
        self.account.notes = memos;
    }];
    
    [self.tableView reloadData];
    [self refreshEmailCell];
    [HLTool saveAccount:self.account];
}

- (void)insertNews:(HLMemo *)memo inArray:(NSMutableArray *)array {
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

/**
 *  第三方登录到自己的账户
 */
- (void)thirdpartyLoginWithBmobUser:(BmobUser *)bUser SSDKUser:(SSDKUser *)ssdkUser {
    [BmobUser loginInbackgroundWithAccount:bUser.username andPassword:ssdkUser.uid.md5String block:^(BmobUser *user, NSError *error) {
        if (user) {
            [self setupAccount:user];
            [user setObject:ssdkUser.icon forKey:@"icon"];
            [user updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                if (isSuccessful) {
                    [self setupAccount:user];
                } else {
                    [MBProgressHUD showError:@"头像更新失败" toView:self.view];
                }
            }];
        } else {
            self.account.login = NO;
            [MBProgressHUD showError:[NSString stringWithFormat:@"登录失败：%@", error.localizedDescription] toView:self.view];
        }
    }];
}

/**
 *  用第三方信息注册用户
 */
- (void)thirdpartyRegistAndLoginWithSSDKUser:(SSDKUser *)ssdkUser {
    
    BmobUser *bUser = [[BmobUser alloc] init];
    bUser.username = ssdkUser.nickname;
    bUser.password = ssdkUser.uid.md5String;
    NSString *gender = @"";
    if (ssdkUser.gender == SSDKGenderMale) {
        gender = @"男";
    } else if (ssdkUser.gender == SSDKGenderFemale) {
        gender = @"女";
    }
    [bUser setObject:gender forKey:@"gender"];
    [bUser setObject:ssdkUser.birthday.stringWithYMD forKey:@"birthday"];
    [bUser setObject:ssdkUser.icon forKey:@"icon"];
    [bUser setObject:ssdkUser.uid.md5String forKey:@"uid"];
    [bUser setObject:[NSNumber numberWithUnsignedLong:ssdkUser.platformType] forKey:@"platformType"];
    [bUser signUpInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful){
            [BmobUser loginInbackgroundWithAccount:ssdkUser.nickname andPassword:ssdkUser.uid.md5String block:^(BmobUser *user, NSError *error) {
                if (user) {
                    [self setupAccount:user];
                } else {
                    [MBProgressHUD showError:[NSString stringWithFormat:@"登录失败：%@", error.localizedDescription] toView:self.view];
                }
            }];
        } else {
            [MBProgressHUD showMessage:@"注册失败" toView:self.view];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view];
            });
        }
    }];
}

/**
 *  第三方登录获取用户，失败后再注册
 */
- (void)getAccountWithUser:(SSDKUser *)user {
    BmobQuery *query = [BmobUser query];
    [query whereKey:@"uid" equalTo: user.uid.md5String];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (array.count > 0) {
            for (BmobUser *bUser in array) {
                if ([[bUser objectForKey:@"platformType"] unsignedLongValue] == user.platformType) {
                    [self thirdpartyLoginWithBmobUser:bUser SSDKUser:user];
                    return;
                }
            }
        }
        
        [self thirdpartyRegistAndLoginWithSSDKUser:user];
    }];
}

- (IBAction)login:(HLButton *)sender {
    if (self.account.isLogin) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"确定要退出帐号吗？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionYES = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSUInteger type = self.account.platformType;
            if (type == kHLPlatformTypeSinaWeibo || type == kHLPlatformSubTypeQZone || type == kHLPlatformTypeQQ) {
                [BmobUser logout];
                [ShareSDK cancelAuthorize:(NSUInteger)self.account.platformType];
            } else {
                [BmobUser logout];
            }
            self.account.notes = [NSArray array];
            self.account.login = NO;
            [self.tableView reloadData];
        }];
        UIAlertAction *actionNO = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:actionYES];
        [alert addAction:actionNO];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self performSegueWithIdentifier:@"loginSegue" sender:nil];
    }
}

- (IBAction)tencent {
    if (self.account.isLogin) {
        NSString *msg = nil;
        if (self.account.platformType == 6 || self.account.platformType == 998) {
            msg = @"已用QQ账号登录";
        } else {
            msg = @"请先退出当前账号！";
        }
        [MBProgressHUD showMessage:msg toView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view];
        });
        return;
    }
    
    [ShareSDK getUserInfo:SSDKPlatformTypeQQ
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         if (state == SSDKResponseStateSuccess) {
             [self getAccountWithUser:user];
         }
     }];
}

- (IBAction)sina {
    if (self.account.isLogin) {
        NSString *msg = nil;
        if (self.account.platformType == 1) {
            msg = @"已用新浪微博登录";
        } else {
            msg = @"请先退出当前账号！";
        }
        [MBProgressHUD showMessage:msg toView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view];
        });
        return;
    }
    
    [ShareSDK getUserInfo:SSDKPlatformTypeSinaWeibo
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         if (state == SSDKResponseStateSuccess) {
             [self getAccountWithUser:user];
         }
     }];
}

- (UILabel *)setupTitleViewHeaderView:(UIView *)headerView {
    UILabel *titleView = [[UILabel alloc] init];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:15];
    titleView.textColor = [UIColor orangeColor];
    titleView.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:titleView];
    
    titleView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *topTitle = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *leftTitle = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeLeft multiplier:1 constant:10];
    NSLayoutConstraint *bottomTitle = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *rightTitle = [NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeRight multiplier:1 constant:-10];
    [headerView addConstraints:@[topTitle, leftTitle, bottomTitle, rightTitle]];
    return titleView;
}

- (void)setupLineBottomHeaderView:(UIView *)headerView {
    UIView *lineBottom = [[UIView alloc] init];
    lineBottom.backgroundColor = [UIColor blackColor];
    lineBottom.alpha = 0.2;
    [headerView addSubview:lineBottom];
    
    lineBottom.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:lineBottom attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:1];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:lineBottom attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeLeft multiplier:1 constant:10];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:lineBottom attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:lineBottom attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeRight multiplier:1 constant:-10];
    [headerView addConstraints:@[height, left, bottom, right]];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section % 2 == 0) {
        UIView *headerView = [[UIView alloc] init];
        headerView.backgroundColor = [UIColor clearColor];
        [self setupLineBottomHeaderView:headerView];
        
        if (section == 4) {
            return headerView;
        } else {
            UILabel *titleView = [self setupTitleViewHeaderView:headerView];
            if (section == 0) {
                titleView.text = @"用户";
                return headerView;
            } else if (section == 2) {
                titleView.text = @"设置";
                return headerView;
            } else if (section == 6) {
                titleView.text = @"使用第三方登录";
                return headerView;
            }
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 30.0f;
    } else if (section == 2) {
        return 30.0f;
    } else if (section == 4) {
        return 1.0f;
    } else if (section == 6) {
        return 30.0f;
    }
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            UIImageView *iconView = [cell viewWithTag:1];
            UIImage *image = [UIImage imageNamed:@"userIcon"];
            if (self.account.isLogin) {
                [iconView sd_setImageWithURL:[NSURL URLWithString:self.account.icon] placeholderImage:image];
            } else {
                iconView.image = image;
            }
        } else if (indexPath.row == 1) {
            cell.detailTextLabel.text = self.account.isLogin ? self.account.nickname : @"请登录";
        } else if (indexPath.row == 2) {
            if (!self.account.isLogin) {
                cell.detailTextLabel.text = @"";
            }
        } else if (indexPath.row == 3) {
            cell.detailTextLabel.text = self.account.isLogin ? self.account.gender : @"";
        } else if (indexPath.row == 4) {
            cell.detailTextLabel.text = self.account.isLogin ? self.account.birthday : @"";
        }
    } else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = [HLTool getCacheSize];
        }
    } else if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            HLButton *login = [cell viewWithTag:1];
            NSString *title = self.account.isLogin ? @"退出登录" : @"未登录";
            [login setTitle:title forState:UIControlStateNormal];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3 && indexPath.row == 0) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell.detailTextLabel.text isEqualToString:@"无缓存"]) {
            [MBProgressHUD showMessage:@"无需清理！" toView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view];
            });
        } else {
            [HLTool clearCache];
            [MBProgressHUD showMessage:@"正在删除缓存，请稍候....." toView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:3]] withRowAnimation:UITableViewRowAnimationNone];
                [MBProgressHUD showMessage:@"已删除缓存！" toView:self.view];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view];
                });
            });
        }
    }
    if (!self.account.isLogin) return;
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [MBProgressHUD showMessage:@"暂不支持修改头像！" toView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view];
            });
        } else if (indexPath.row == 1) {
            [self modifyUserInfoWithRow:1];
        } else if (indexPath.row == 2) {
            if (self.account.emailStatus == kHLEmailStatusTypeNoBinding) {
                [self performSegueWithIdentifier:@"meSegue" sender:nil];
            } else if (self.account.emailStatus == kHLEmailStatusTypeNoVerify) {
                [self clickEmailCell:@"邮箱未验证，将不能用作找回密码，立即验证？"];
            } else if (self.account.emailStatus == kHLEmailStatusTypeVerified) {
                [self clickEmailCell:@"要修改绑定邮箱吗？"];
            }
        } else if (indexPath.row == 3) {
            [self modifyUserInfoWithRow:3];
        } else if (indexPath.row == 4) {
            [self modifyUserInfoWithRow:4];
        }
    }
}

- (void)updateUserInfoText:(NSString *)text row:(int)row {
    BmobUser *user = [BmobUser currentUser];
    if (row == 1) {
        user.username = text;
    } else if (row == 3) {
        [user setObject:text forKey:@"gender"];
    } else if (row == 4) {
        [user setObject:text forKey:@"birthday"];
    }
    [user updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            if (row == 1) {
                self.account.nickname = text;
            } else if (row == 3) {
                self.account.gender = text;
            } else if (row == 4) {
                self.account.birthday = text;
            }
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        } else {
            [MBProgressHUD showError:@"修改失败" toView:self.view];
        }
    }];
}

- (void)modifyUserInfoWithRow:(NSInteger)row {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入：" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        if (row == 1) {
            textField.placeholder = @"请输入新的用户名";
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        } else if (row == 3) {
            self.genderView = textField;
            HLGenderView *inputView = [HLGenderView genderView];
            [inputView hiddenToolBar:YES];
            textField.inputView = inputView;
        } else if (row == 4) {
            self.birthdayView = textField;
            HLBirthdayView *inputView = [HLBirthdayView birthdayView];
            [inputView hiddenToolBar:YES];
            textField.inputView = inputView;
        }
    }];
    UIAlertAction *actionY = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textF = alert.textFields.firstObject;
        if (row == 1 && [self verifyUserNameLegal:textF.text]) {
            [self updateUserInfoText:textF.text row:1];
        } else if (row == 3) {
            [self updateUserInfoText:textF.text row:3];
        } else if (row == 4) {
            [self updateUserInfoText:textF.text row:4];
        }
    }];
    UIAlertAction *actionN = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:actionY];
    [alert addAction:actionN];
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)verifyUserNameLegal:(NSString *)name {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH ' ' || SELF ENDSWITH ' '"];
    if ([predicate evaluateWithObject:name] || name.length <= 0 || name.length > 20) {
        NSString *msg = @"用户名不能以空格开头或结尾！";
        if (name.length > 20) {
            msg = @"限制20个字符以内！";
        }
        [MBProgressHUD showMessage:msg toView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view];
        });
        return NO;
    }
    return YES;
}

- (void)clickEmailCell:(NSString *)msg {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionYES = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self performSegueWithIdentifier:@"meSegue" sender:nil];
    }];
    UIAlertAction *actionNO = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:actionYES];
    [alert addAction:actionNO];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    HLForgetPwdViewController *desVc = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"meSegue"]) {
        if (self.account.emailStatus == kHLEmailStatusTypeNoBinding) {
            desVc.emailOption = kHLEmailOptionSet;
            desVc.btnTitle = @"绑定";
        } else if (self.account.emailStatus == kHLEmailStatusTypeNoVerify) {
            desVc.emailOption = kHLEmailOptionVerify;
            desVc.emailStr = self.account.email;
            desVc.btnTitle = @"验证";
        } else if (self.account.emailStatus == kHLEmailStatusTypeVerified) {
            desVc.emailOption = kHLEmailOptionReset;
            desVc.placeholder = @"请输入新的邮箱地址";
            desVc.btnTitle = @"修改";
        }
    }
}

- (HLAccount *)account {
    if (!_account) {
        self.account = [HLAccount sharedAccount];
    }
    return _account;
}

@end
