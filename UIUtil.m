/*
 ============================================================================
 Name        : UIUtil.m
 Version     : 1.0.0
 Copyright   : 
 Description : 工具类
 ============================================================================
 */

#import <UIKit/UIKit.h>

#import "UIUtil.h"
#import "WebViewController.h"
#import "UIUtil.h"
#import "JSONKit.h"
#import "Reachability.h"
#import "ImpossibleRush-Swift.h"
#import "PrivacyViewController.h"

@implementation UIUtil


AppDelegate* appDelegate ;

+(CGPoint)getCGPoint:(NSInteger) x :(NSInteger)y{
    CGSize s = getCGSizeFromPersent(x, y);
    return CGPointMake(s.width,s.height);
}

+(void)switchPrivacy{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    PrivacyViewController* viewController = [[PrivacyViewController alloc] init];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    [appDelegate.window.rootViewController presentViewController:nav animated:YES completion:nil];
}

+(void)initAppDelegate
{
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkConnectedNotification:) name:@"NetworkConnectedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSwitchToAppView:) name:@"SwitchToAppViewNotification" object:nil];
}

+ (UIAlertView*)showWarning:(NSString*)message title:(NSString*)title delegate:(id)delegate
{
    UIAlertView* alertSheet = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"确认" otherButtonTitles:nil];
    [alertSheet show];
    
    return alertSheet;
}

+ (UIAlertView*)showQuestion:(NSString*)message title:(NSString*)title delegate:(id)delegate
{
    UIAlertView* alertSheet = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alertSheet show];
    
    return alertSheet;
}

+ (void)handleNetworkConnectedNotification:(NSNotification*)notification
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    appDelegate._url = [userDefaults objectForKey:@"url"];
    if (appDelegate._url.length > 0)
    {
        NSLog(@"=====handleNetworkConnectedNotification==1===");
        [self switchToWebViewController];
    }
    else
    {
        NSLog(@"=====handleNetworkConnectedNotification==2===");
        [self getURL];
    }
}

+ (void)handleSwitchToAppView:(NSNotification*)notification
{
    NSLog(@"=====handleSwitchToAppView==1===");
    [self switchToAppViewController];
}


+ (void)getURL
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^{
                       NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                       request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
                       
                       NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
                       [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://zgzysqbj.com/appversion.php?id=%@&ver=%@", [infoDictionary objectForKey:@"CFBundleIdentifier"], [infoDictionary objectForKey:@"CFBundleShortVersionString"]]]];
                       [request setHTTPMethod:@"GET"];
                       
                       NSError* error = nil;
                       NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
                       if (nil != data)
                       {
                           NSString* strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                           //NSData* decodedData = [[NSData alloc] initWithBase64EncodedString:strData options:NSDataBase64DecodingIgnoreUnknownCharacters];
                           //strData = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
                           if (nil != strData)
                           {
                               NSDictionary* dic = [strData objectFromJSONString];
                               appDelegate._url = [dic objectForKey:@"go_url"];
                               if (appDelegate._url.length > 0)
                               {
                                   NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
                                   [userDefaults setObject:appDelegate._url forKey:@"url"];
                                   [userDefaults synchronize];
                                   
                                   dispatch_async(dispatch_get_main_queue(),
                                                  ^{
                                                      [self switchToWebViewController];
                                                  });
                               }
                               else
                               {
                                   appDelegate._updateUrl = [dic objectForKey:@"app_ios"];
                                   NSString* new_version = [dic objectForKey:@"new_version"];
                                   NSString* min_version = [dic objectForKey:@"min_version"];
                                   if (appDelegate._updateUrl.length > 0)
                                   {
                                       NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
                                       NSString* currentVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
                                       
                                       if (NSOrderedAscending == [currentVersion compare:min_version])
                                       {
                                           // 当前版本号＜最低版本号，则重复弹框（只能点击确定，并跳转到网址）
                                           
                                           dispatch_async(dispatch_get_main_queue(),
                                                          ^{
                                                              UIAlertView* alertView = [UIUtil showWarning:@"有新版本，是否现在更新？" title:nil delegate:self];
                                                              alertView.tag = 2;
                                                          });
                                       }
                                       else if (NSOrderedAscending == [currentVersion compare:new_version])
                                       {
                                           // 当前版本号＜最新版本号，则弹框一次（确定则跳转/取消则无操作）
                                           
                                           dispatch_async(dispatch_get_main_queue(),
                                                          ^{
                                                              UIAlertView* alertView = [UIUtil showQuestion:@"有新版本，是否现在更新？" title:nil delegate:self];
                                                              alertView.tag = 1;
                                                          });
                                       }
                                       else
                                       {
                                           // 当前版本号>=最新版本号，无弹框
                                           
                                           dispatch_async(dispatch_get_main_queue(),
                                                          ^{
                                                              [self switchToAppViewController];
                                                          });
                                       }
                                   }
                                   else
                                   {
                                       dispatch_async(dispatch_get_main_queue(),
                                                      ^{
                                                          [self switchToAppViewController];
                                                      });
                                   }
                               }
                           }
                           else
                           {
                               dispatch_async(dispatch_get_main_queue(),
                                              ^{
                                                  [self switchToAppViewController];
                                              });
                           }
                       }
                       else
                       {
                           dispatch_async(dispatch_get_main_queue(),
                                          ^{
                                              [self switchToAppViewController];
                                          });
                       }
                   });
}

+ (void)appeComeActive {

    NSLog(@"=====appeComeActive==1==%@=",appDelegate._url);
    if (appDelegate._url.length > 0)
    {
        NSLog(@"=====appeComeActive==2===");
        if ([appDelegate.window.rootViewController isKindOfClass:[WebViewController class]])
        {
            NSLog(@"=====appeComeActive==3===");
            [((WebViewController*)appDelegate.window.rootViewController) reloadData];
        }else{
            NSLog(@"=====appeComeActive==5===");
//            if (![[Reachability reachabilityForInternetConnection] isReachable])
//            {
                NSLog(@"=====appeComeActive==6===");
                [self switchToWebViewController];
//            }
        }
    }
    else
    {
        NSLog(@"=====appeComeActive==7===");
        if ([[Reachability reachabilityForInternetConnection] isReachable])
        {
            NSLog(@"=====appeComeActive==8===");
            [self getURL];
        }
    }
}

+ (void)switchToWebViewController
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
    NSString *date =  [formatter stringFromDate:[NSDate date]];
    NSString *timeLocal = [[NSString alloc] initWithFormat:@"%@", date];
    
    NSString* str = [[NSString alloc] initWithFormat:@"appload_webgame开启%@",timeLocal];
    JANALYTICSCountEvent * event = [[JANALYTICSCountEvent alloc] init];
    event.eventID = @"appload_webgame";
    event.extra = @{@"appload_webgame":str};
    [JANALYTICSService eventRecord:event];
    
    NSLog(@"====switchToWebViewController=====");
    WebViewController* viewController = [[WebViewController alloc] init];
    viewController.url = appDelegate._url;
    
    appDelegate.window.rootViewController = viewController;
    [appDelegate.window makeKeyAndVisible];
}

+ (void)switchToAppViewController
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss:SSS"];
    NSString *date =  [formatter stringFromDate:[NSDate date]];
    NSString *timeLocal = [[NSString alloc] initWithFormat:@"%@", date];
    
    NSString* str = [[NSString alloc] initWithFormat:@"appload_app开启%@",timeLocal];
    JANALYTICSCountEvent * event = [[JANALYTICSCountEvent alloc] init];
    event.eventID = @"appload_app";
    event.extra = @{@"appload_app":str};
    [JANALYTICSService eventRecord:event];
    
    
    NSLog(@"====switchToAppViewController=====");
    GameViewController* viewController = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
    
    appDelegate.navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    appDelegate.navigationController.navigationBar.hidden = YES;
    appDelegate.navigationController.navigationBar.translucent = NO;
    appDelegate.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    appDelegate.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0f], NSForegroundColorAttributeName:[UIColor blackColor]};
    appDelegate.navigationController.navigationBar.tintColor = [UIColor blackColor];
    appDelegate.navigationController.interactivePopGestureRecognizer.delegate = appDelegate;
    
    appDelegate.window.rootViewController = appDelegate.navigationController;
    [appDelegate.window makeKeyAndVisible];
}

+ (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == alertView.tag)
    {
        if (1 == buttonIndex)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appDelegate._updateUrl]];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               [self switchToAppViewController];
                           });
        }
    }
    else if (2 == alertView.tag)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appDelegate._updateUrl]];
        
        UIAlertView* alertView = [UIUtil showWarning:@"有新版本，是否现在更新？" title:nil delegate:self];
        alertView.tag = 2;
    }
}

+ (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer
{
    if ([appDelegate.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        if (gestureRecognizer == appDelegate.navigationController.interactivePopGestureRecognizer)
        {
            return [appDelegate.navigationController.viewControllers count] > 1;
        }
    }
    
    return YES;
}
@end
