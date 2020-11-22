//
//  AppDelegate.m
//  FlightBriefing
//
//  Created by Johan Nyman on 2013-11-14.
//  Copyright (c) 2013 JN Avionics. All rights reserved.
//

#import "AppDelegate.h"

#import "DataStore.h"

#import "MainMenuViewController.h"
#import "SelectFlightViewController.h"



@interface AppDelegate ()

@end


@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
      

    
    /*****   Setup the Core Data Stack   *******/
    if ([DataStore setupAutoMigratingCoreDataStackAndWait]) {

        //Finish installation when stack is completed
        
        //Set up user defaults
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return YES;
}



- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"Memory warning!");
  }

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    // Saves changes in the application's managed object context before the application goes to sleep.
   
    [DataStore saveContextAsyncWithCompletion:^(BOOL success, NSError *error) {
        NSLog(@"Application Will Resign Active");
        if (success) {
            NSLog(@"You successfully saved your context.");
        } else if (error) {
            NSLog(@"Error saving context: %@", error.description);
        } else {
            NSLog(@"No changes to save.");
        }
    }];
    
    NSLog(@"Resigning active mode");
       
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // Saves changes in the application's managed object context before the application terminates.
    [DataStore saveContextAsyncWithCompletion:^(BOOL success, NSError *error) {
        NSLog(@"Application Did Enter Background");
        if (success) {
            NSLog(@"You successfully saved your context.");
        } else if (error) {
            NSLog(@"Error saving context: %@", error.description);
        } else {
            NSLog(@"No changes to save.");
        }
    }];
    
    //[AppSettings appendLog:@"Did enter background mode" withTime:YES];
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //[AppSettings appendLog:@"Will enter foreground" withTime:YES];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    
    //**************** Some logging **************//
    
    
    NSArray * allFlights = [DataStore fetchAll:[Flight entityName]];
    NSArray * allInfo = [DataStore fetchAll:[FlightInfo entityName]];
    NSString * logString = [NSString stringWithFormat:@"Database contains %zd flights and %zd flightInfos", allFlights.count, allInfo.count];
    
    NSLog(@"%@", logString);
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"Application Will Terminate");

    // Saves changes in the application's managed object context before the application terminates.
    NSError * error;
    [DataStore saveContextWithError:&error];
        
    //Reduced logging...
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    
    NSLog(@"Application quit correctly.");
}


@end
