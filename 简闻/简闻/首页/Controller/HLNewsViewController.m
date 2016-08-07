//
//  HLNewsViewController.m
//  简闻
//
//  Created by 韩露露 on 16/6/2.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLNewsViewController.h"
#import "HLToolBar.h"

@interface HLNewsViewController () <HLToolBarDelegate, UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) HLToolBar *myToolBar;

- (IBAction)clickCancel:(UIBarButtonItem *)sender;
- (IBAction)navigationBtn:(UIBarButtonItem *)sender;
@end

@implementation HLNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cancelBtn.imageInsets = UIEdgeInsetsMake(10, -5, 7, 10);
    
    self.webView.delegate = self;
    self.webView.scrollView.bounces = NO;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [self.webView loadRequest:request];
    
    [self setupToolBar];
}

- (void)setupToolBar {
    self.myToolBar = [HLToolBar toolBar];
    self.myToolBar.delegate = self;
    [self.view addSubview:self.myToolBar];
    self.myToolBar.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.myToolBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:44];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.myToolBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.myToolBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.myToolBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self.view addConstraints:@[height, left, right,bottom]];
}

- (void)toolBar:(HLToolBar *)toolBar didClickBtn:(HLToolBarType)type {
    if (type == kHLToolBarTypeBack) {
        if (self.webView.canGoBack) {
            [self.webView goBack];
        }
    } else if (type == kHLToolBarTypeGo) {
        if (self.webView.canGoForward) {
            [self.webView goForward];
        }
    } else if (type == kHLToolBarTypeRefresh) {
        self.myToolBar.refreshing = !self.webView.isLoading;
        if (self.webView.isLoading) {
            [self.webView stopLoading];
        } else {
            [self.webView reload];
        }
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.myToolBar.enableBack = self.webView.canGoBack;
    self.myToolBar.enableGo = self.webView.canGoForward;
    self.myToolBar.refreshing = self.webView.isLoading;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.myToolBar.enableBack = self.webView.canGoBack;
    self.myToolBar.enableGo = self.webView.canGoForward;
    self.myToolBar.refreshing = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.myToolBar.enableBack = self.webView.canGoBack;
    self.myToolBar.enableGo = self.webView.canGoForward;
    self.myToolBar.refreshing = NO;
}

- (IBAction)clickCancel:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)navigationBtn:(UIBarButtonItem *)sender {
    sender.enabled = NO;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.hao123.com"]];
    [self.webView loadRequest:request];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
}

- (void)setUrl:(NSString *)url {
    _url = url;
}
@end
