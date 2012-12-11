//
//  AppDelegate.m
//  WFNavigation
//
//  Created by 滕 松 on 12-12-11.
//  Copyright (c) 2012年 shawnt22@gmail.com. All rights reserved.
//

#import "AppDelegate.h"
#import "BaseViewController.h"

@implementation AppDelegate
@synthesize wfNavigationController;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    WFNavigationController *_nav = [[WFNavigationController alloc] init];
    [self.window setRootViewController:_nav];
    self.wfNavigationController = _nav;
    [_nav release];
    
    UIButton *_push = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _push.frame = CGRectMake(ceilf((self.wfNavigationController.view.bounds.size.width - 100)/2), 200, 100, 44);
    _push.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_push setTitle:@"push" forState:UIControlStateNormal];
    [_push addTarget:self action:@selector(pushItemAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.wfNavigationController.view addSubview:_push];
    
    return YES;
}
- (void)pushItemAction:(id)sender {
    BaseViewController *_item = [[BaseViewController alloc] init];
    [self.wfNavigationController pushItem:_item Direction:[BaseViewController gestureDirection] Type:[BaseViewController animationType] Animated:YES];
    [_item release];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
