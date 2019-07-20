/*
 ============================================================================
 Name        : WebViewController.m
 Version     : 1.0.0
 Copyright   :
 Description :
 ============================================================================
 */

#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "WebViewController.h"
#import "JSONKit/JSONKit.h"
#import <sys/utsname.h>
// 引入JPush功能所需头文件
#import "JPUSHService.h"
#import "JANALYTICSService.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#include <math.h>
#include <string.h>


@interface WebViewController () <WKScriptMessageHandler, UIActionSheetDelegate,WKUIDelegate,WKNavigationDelegate,UIScrollViewDelegate>
{
    IBOutlet WKWebView* _webView;
    
    NSString* _url;
    BOOL _isLoaded;
}


@end

@implementation WebViewController

@synthesize url = _url;

-(void)loadTime:(NSString*)skey :(NSString*)str{
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
    NSString *date =  [formatter stringFromDate:[NSDate date]];
    
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString* v = [[NSString alloc] initWithFormat:@"UDID:%@,\n date:%@,\n remark:%@",idfv,date,str];
    
    JANALYTICSCountEvent * event = [[JANALYTICSCountEvent alloc] init];
    event.eventID = skey;
    event.extra = @{skey:v};
    [JANALYTICSService eventRecord:event];
    NSLog(@"=========loadTime===key=%@===str=%@",skey,v);
}

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.preferences.minimumFontSize = 0.0f;
    configuration.userContentController = [WKUserContentController new];
    
    [configuration.userContentController addScriptMessageHandler:self name:@"openUrl"];
    
    
    _webView = [[WKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds configuration:configuration];
    _webView.navigationDelegate = self;
    _webView.scrollView.scrollEnabled = YES;
    [_webView setBackgroundColor:[UIColor blackColor]];
    [self reloadData];
    
    [self.view addSubview:_webView];
    
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    NSLayoutConstraint* topLayout = [NSLayoutConstraint constraintWithItem:_webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    
    NSLayoutConstraint* leadingLayout = [NSLayoutConstraint constraintWithItem:_webView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0];
    
    NSLayoutConstraint* bottomLayout = [NSLayoutConstraint constraintWithItem:_webView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    
    NSLayoutConstraint* trailingLayout = [NSLayoutConstraint constraintWithItem:_webView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0];
    
    [self.view addConstraints:@[topLayout, leadingLayout, bottomLayout, trailingLayout]];
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"===message.name=%@",message.name);
    NSLog(@"===message.body=%@",message.body);
    if ([message.name isEqualToString:@"openUrl"]) {
        [self openUrl:message.body];
    }else if ([message.name isEqualToString:@"openAppUrl"]) {
        [self openAppUrl:message.body];
    }
}


-(NSString*)getFilter:(NSString*)surl :(NSString*)from
{
    NSRange home=[surl rangeOfString:@"mobile/index"];
    if(home.location!=NSNotFound){
        if([from isEqualToString:@"start" ]){
            return @"home_loadstart";
        }else if([from isEqualToString:@"failed"]){
            return @"home_loadfailed";
        }else if([from isEqualToString:@"finish"]){
            return @"home_loadfinish";
        }else if([from isEqualToString:@"response"]){
            return @"home_loadWebResponse";
        }
        return @"home";
    }
    NSRange login=[surl rangeOfString:@"mobile/login"];
    if(login.location!=NSNotFound){
        if([from isEqualToString:@"start" ]){
            return @"login_loadstart";
        }else if([from isEqualToString:@"failed"]){
            return @"login_loadfailed";
        }else if([from isEqualToString:@"finish"]){
            return @"login_loadfinish";
        }else if([from isEqualToString:@"response"]){
            return @"login_loadWebResponse";
        }
        return @"login";
    }
    NSRange register1 =[surl rangeOfString:@"mobile/register"];
    if(register1.location!=NSNotFound){
        if([from isEqualToString:@"start" ]){
            return @"register_loadstart";
        }else if([from isEqualToString:@"failed"]){
            return @"register_loadfailed";
        }else if([from isEqualToString:@"finish"]){
            return @"register_loadfinish";
        }else if([from isEqualToString:@"response"]){
            return @"register_loadWebResponse";
        }
        
        return @"register";
    }
    NSRange play=[surl rangeOfString:@"play.html"];
    if(play.location!=NSNotFound){
        if([from isEqualToString:@"start" ]){
            return @"play_loadstart";
        }else if([from isEqualToString:@"failed"]){
            return @"play_loadfailed";
        }else if([from isEqualToString:@"finish"]){
            return @"play_loadfinish";
        }else if([from isEqualToString:@"response"]){
            return @"play_loadWebResponse";
        }
        return @"play.html";
    }
    return @"unknow";
}

#pragma mark - WKNavigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSString * url = [[webView URL] absoluteString];
    NSString* key = [self getFilter:url:@"start"];
    [self loadTime:key :url];
    NSLog(@"=========页面开始加载时调用======url=%@",url);
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    _isLoaded = YES;
    NSString * url = [[webView URL] absoluteString];
    NSString* key = [self getFilter:url:@"response"];
    [self loadTime:key:url];
    NSLog(@"=========当内容开始返回时调用======%@=",url);
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    _isLoaded = YES;
    NSString * url = [[webView URL] absoluteString];
    NSLog(@"=========页面加载完成之后调用========");
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:@"ok" forKey:@"loadFinish"];
    
    NSString* str = [[NSString alloc] initWithFormat:@"url:%@",url];
    NSString* key = [self getFilter:url:@"finish"];
    [self loadTime:key:str];
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSString * url = [[webView URL] absoluteString];
    NSLog(@"=========页面加载失败时调用======error=%@=",error);
    NSString* str = [[NSString alloc] initWithFormat:@"code:%li \n%@\n%@\n",
                     [error code],
                     [[error userInfo]objectForKey:@"NSErrorFailingURLKey"],
                     [error localizedDescription]];
    
    NSString* key = [self getFilter:url:@"failed"];
    [self loadTime:key:str];
}

-(void) openAppUrl:(NSString*)url
{
    NSString *encodedValue = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *itunesURL = [NSURL URLWithString:encodedValue];//[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id443904275"];
    [[UIApplication sharedApplication] openURL:itunesURL];
}
-(void)openUrl:(NSString*)url{
    NSLog(@"======openur=%@",url);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)reloadData
{
    if (!_isLoaded)
    {
        //[self getURL];
        
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]];
        [_webView loadRequest:request];
    }
}

- (void)getURL
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^{
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                       request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
                       
                       NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
                       [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://zgzysqbj.com/jetbooklet.json?ver=%@", [infoDictionary objectForKey:@"CFBundleShortVersionString"]]]];
                       [request setHTTPMethod:@"GET"];
                       
                       NSError* error = nil;
                       NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
                       if (nil != data)
                       {
                           NSString* strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                           NSData* decodedData = [[NSData alloc] initWithBase64EncodedString:strData options:NSDataBase64DecodingIgnoreUnknownCharacters];
                           strData = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
                           if (nil != strData)
                           {
                               NSDictionary* dic = [strData objectFromJSONString];
                               if (1 == [[dic objectForKey:@"showtype"] intValue])
                               {
                                   dispatch_async(dispatch_get_main_queue(),
                                                  ^{
                                                      _url = [dic objectForKey:@"image"];
                                                      
                                                      NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]];
                                                      [_webView loadRequest:request];
                                                  });
                               }
                               else if (0 == [[dic objectForKey:@"showtype"] intValue])
                               {
                                   dispatch_async(dispatch_get_main_queue(),
                                                  ^{
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"SwitchToAppViewNotification" object:nil];
                                                  });
                               }
                           }
                       }
                   });
}


- (void)webView:(WKWebView*)webView didFailNavigation:(WKNavigation*)navigation withError:(NSError*)error
{
}


- (void)webView:(WKWebView*)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential* credential))completionHandler
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        NSURLCredential* card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, card);
    }
}

@end
