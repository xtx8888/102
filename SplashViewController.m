/*
 ============================================================================
 Name        : SplashViewController.m
 Version     : 1.0.0
 Copyright   : 
 Description : 闪屏页
 ============================================================================
 */

#import "SplashViewController.h"
#import "ImpossibleRush-Swift.h"
#import "Reachability.h"


@interface SplashViewController ()
{
    IBOutlet UIImageView* _backgroundImageView;
    IBOutlet UIView* _networkView;
    
    Reachability* _reachability;
}

@end

@implementation SplashViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    [_reachability stopNotifier];
    _reachability = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUIApplicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        _reachability = [Reachability reachabilityForInternetConnection];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReachabilityChangedNotification:) name:kReachabilityChangedNotification object:nil];
        [_reachability startNotifier];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    CGSize viewSize = appDelegate.window.bounds.size;
    NSString* viewOrientation = @"Portrait";
    NSString* launchImage = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            launchImage = dict[@"UILaunchImageName"];
        }
    }
    
    _backgroundImageView.backgroundColor = [UIColor whiteColor];
    _backgroundImageView.image = [UIImage imageNamed:launchImage];
    
    if ([_reachability isReachable])
    {
        _networkView.hidden = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkConnectedNotification" object:nil];
    }
    else
    {
        _networkView.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (IBAction)gotoSettingButtonClicked:(id)sender
{
    NSURL* url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (IBAction)reloadButtonClicked:(id)sender
{
    if ([_reachability isReachable])
    {
        _networkView.hidden = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkConnectedNotification" object:nil];
    }
    else
    {
        _networkView.hidden = NO;
    }
}

- (void)handleUIApplicationWillEnterForegroundNotification:(NSNotification*)notification
{
    if ([_reachability isReachable])
    {
        _networkView.hidden = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkConnectedNotification" object:nil];
    }
    else
    {
        _networkView.hidden = NO;
    }
}

- (void)handleReachabilityChangedNotification:(NSNotification*)notification
{
    if ([_reachability isReachable])
    {
        _networkView.hidden = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkConnectedNotification" object:nil];
    }
    else
    {
        _networkView.hidden = NO;
    }
}

@end
