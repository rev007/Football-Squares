//
//  AppDelegate.m
//  Sports Squares
//
//  Created by EAGLE on 6/3/15.
//  Copyright (c) 2015 GreenVine. All rights reserved.
//

#import "AppDelegate.h"

#define debug 1

@interface AppDelegate ()

@end

@implementation AppDelegate

- (CoreDataHelper*)cdh {
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (!_coreDataHelper) {
        _coreDataHelper = [CoreDataHelper new];
        [_coreDataHelper setupCoreData];
    }
    return _coreDataHelper;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //you can potentially do something here to make the audio not pause when adding that first token (per stack exchange)
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[self cdh] saveContext]; //core data helper
    
    //queue up the trivia alarms
    NSDate *triviaAlarm = [NSDate dateWithTimeIntervalSinceNow:10];
    [self scheduleNotifications:triviaAlarm];


}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
//    [self clearNotifications:application];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[self cdh] saveContext];
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"the alarm fired and you shouldn't see anything!!!");
}

//-(void)clearNotifications:(UIApplication *)application {
//    
//    NSArray*    oldNotifications = [application scheduledLocalNotifications];
//    
//    [self clearNotifications:application];
//    
//    //clear the old notifications too
//    if ([oldNotifications count] > 0) {
//        [application cancelAllLocalNotifications]; //cancels the delivery of all scheduled notifications
//    }
//
//    
//}

- (void)scheduleNotifications:(NSDate*)theDate
{
    //    UIApplication* app = [UIApplication sharedApplication];
    //    NSArray*    oldNotifications = [app scheduledLocalNotifications];
    //
    //    // Clear out the old notification before scheduling a new one.
    //    if ([oldNotifications count] > 0)
    //        [app cancelAllLocalNotifications];
    //
    //    // Create a new notification.
    //    UILocalNotification *alarm = [[UILocalNotification alloc] init];
    //    if (alarm)
    //    {
    //        alarm.fireDate = theDate;
    //        alarm.timeZone = [NSTimeZone defaultTimeZone];
    //        alarm.repeatInterval = 0;
    //        alarm.soundName = UILocalNotificationDefaultSoundName;
    ////        alarm.soundName = @"whistle.aif";
    //        alarm.alertBody = @"Time to wake up!";
    //
    //        [app scheduleLocalNotification:alarm];
    ////        [app presentLocalNotificationNow:alarm];
    //    }
    //
    //    NSLog(@"Alarm: %@", theDate);
    //    NSLog(@"Fire: %@", alarm);
    
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = theDate;
    //    localNotification.alertBody = [NSString stringWithFormat:@"Alert Fired at %@", theDate];
    localNotification.alertBody = @"trivia time!";
    //    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.soundName = @"whistle.aif";
    localNotification.applicationIconBadgeNumber = 5;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
}


@end
