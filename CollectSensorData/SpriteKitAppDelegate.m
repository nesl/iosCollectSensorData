//
//  SpriteKitAppDelegate.m
//  CollectSensorData
//
//  Created by Bo Jhang Ho on 3/2/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import "SpriteKitAppDelegate.h"

@interface SpriteKitAppDelegate () {
    CMMotionManager *motionManager;
    CLLocationManager *locationManager;
}

@end

@implementation SpriteKitAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    isUIUpdating = true;
    
    motionManager = [[CMMotionManager alloc] init];
    [motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
                                        withHandler:^(CMAccelerometerData *data, NSError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                //NSLog(@"get data in app delegate: delete it");
                                                [motionManager stopMagnetometerUpdates];
                                                motionManager = nil;
                                            });
                                        }];
    motionManager.accelerometerUpdateInterval = 0.02;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 1;
    
    if([CLLocationManager locationServicesEnabled]){
        [locationManager startUpdatingLocation];
    }
    else {
        NSLog(@"can't use location service");
    }
    
    CMMotionActivityManager *motionActivityManager;
    motionActivityManager = [[CMMotionActivityManager alloc] init];
    [motionActivityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMotionActivity *activity) {
        int conf = 0;
        if (activity.confidence == CMMotionActivityConfidenceMedium) conf = 1;
        if (activity.confidence == CMMotionActivityConfidenceHigh) conf = 2;
        int mid = 0;
        if (activity.stationary) mid |= 0x01;
        if (activity.walking)    mid |= 0x02;
        if (activity.running)    mid |= 0x04;
        if (activity.automotive) mid |= 0x08;
        if (activity.unknown)    mid |= 0x10;
        [LogManager inputMotionMid:mid confidence:conf timestamp:[activity.startDate timeIntervalSinceReferenceDate]];
    }];
    
    [LogManager globalInit];
    
    [NSTimer scheduledTimerWithTimeInterval:100
                                     target:self
                                   selector:@selector(reEnableLocationManager)
                                   userInfo:nil
                                    repeats:YES];
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    isUIUpdating = true;
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"I will be active");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    isUIUpdating = false;
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   // NSLog(@"I will be in background");
    /*
    motionManager = [[CMMotionManager alloc] init];
    
    [motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
                                        withHandler:^(CMAccelerometerData *data, NSError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                NSLog(@"background acc: %f %f %f", data.acceleration.x, data.acceleration.y, data.acceleration.z);
                                            });
                                        }];
    motionManager.accelerometerUpdateInterval = 0.02;

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 1;*/
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    isUIUpdating = true;
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //NSLog(@"I'm in background");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    isUIUpdating = true;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //NSLog(@"I am active");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [LogManager globalEnd];
}




- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [LogManager inputLocLat:newLocation.coordinate.latitude lon:newLocation.coordinate.longitude herror:newLocation.horizontalAccuracy timestamp:[newLocation.timestamp timeIntervalSinceReferenceDate]];
    NSLog(@"has gps data");
}

- (void)reEnableLocationManager {
    [locationManager stopUpdatingLocation];
    [locationManager startUpdatingLocation];
    NSLog(@"re-enabled");
}

@end
