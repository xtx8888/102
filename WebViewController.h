/*
 ============================================================================
 Name        : WebViewController.h
 Version     : 1.0.0
 Copyright   :
 Description : 
 ============================================================================
 */

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController

@property (nonatomic, strong) NSString* url;

- (void)reloadData;

@end
