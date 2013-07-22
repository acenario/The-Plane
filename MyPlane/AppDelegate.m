//
//  AppDelegate.m
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/6/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "AppDelegate.h"
#import "UserInfo.h"
#import "RemindersViewController.h"
#import "FriendsQueryViewController.h"

@implementation AppDelegate


- (void)customizeApp {
    UIColor *barColor = [UIColor colorFromHexCode:@"FF4100"];
    //UIColor *tintColor = [UIColor colorFromHexCode:@"FF7140"];
    UIColor *barButtonColor = [UIColor colorFromHexCode:@"A62A00"];
    //UIColor *barButtonSelectedColor = [UIColor colorFromHexCode:@"FF7140"];
    UIColor *barButtonSelectedColor = [UIColor colorFromHexCode:@"FF9773"];
    UIImage *barImage = [UIImage imageWithColor:barColor cornerRadius:0];

    
    UITabBar *tabBarAppearance = [UITabBar appearance];
    [tabBarAppearance setBackgroundImage:[UIImage imageNamed:@"tabbarBackground"]];
    [tabBarAppearance setSelectionIndicatorImage:[UIImage imageNamed:@"tabBarSelectionIndicator"]];
    //[tabBarAppearance setTintColor:barColor];
    [tabBarAppearance setSelectedImageTintColor:barColor];
    //UIImage *barImage = [UIImage imageNamed:@"navbar2"];
     [[UISearchBar appearance] setBackgroundImage:barImage];
    [[UINavigationBar appearance] configureFlatNavigationBarWithColor:barColor];
    //[[UISearchBar appearance] setBackgroundColor:barColor];

    
    [UIBarButtonItem configureFlatButtonsWithColor:barButtonSelectedColor
                                  highlightedColor:barButtonColor
                                      cornerRadius:3
                                   whenContainedIn:[UINavigationBar class], nil];
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [self customizeApp];
    //[application setStatusBarStyle:UIStatusBarStyleBlackOpaque];

    
    [UserInfo registerSubclass];

    [Parse setApplicationId:@"eG1erDMSBskOUbLbiQJVCN9f8oWazzCWeQ2qg9Fb"
                  clientKey:@"nklHXrOh7SAgnhvfJYC0zjqjFLkkt9OVGQ8U7uyK"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    NSString *friendAdd = [notificationPayload objectForKey:@"f"];
    NSString *reminderAdd = [notificationPayload objectForKey:@"r"];
    
    if ([friendAdd isEqualToString:@"add"]) {
         [[NSNotificationCenter defaultCenter] postNotificationName:@"increaseFriend" object:nil];
        
    
    }
    
    if ([reminderAdd isEqualToString:@"n"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadObjects" object:nil];
        
    }

    
//    PFQuery *pushQuery = [PFInstallation query];
//    [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
//    
//    // Send push notification to query
//    [PFPush sendPushMessageToQueryInBackground:pushQuery
//                                   withMessage:@"Hello World!"];
    
    
    
    return YES;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
}



- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    
    
    NSString *friendAdd = [userInfo objectForKey:@"f"];
    NSString *reminderAdd = [userInfo objectForKey:@"r"];
    
    if ([friendAdd isEqualToString:@"add"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"increaseFriend" object:nil];
        
        
        NSLog(@"Friend Added! Time to Reload!");
        
    }
    
    if ([reminderAdd isEqualToString:@"n"]) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        if (currentInstallation.badge != 0) {
            currentInstallation.badge = 0;
            [currentInstallation saveEventually];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadObjects" object:nil];
    }
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
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
