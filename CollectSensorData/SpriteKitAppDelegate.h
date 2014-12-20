//
//  SpriteKitAppDelegate.h
//  CollectSensorData
//
//  Created by Bo Jhang Ho on 3/2/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CMMotionActivity.h>
#import <CoreMotion/CMMotionActivityManager.h>

#import "LogManager.h"

bool isUIUpdating;

@interface SpriteKitAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
