//
//  LogManager.h
//  CollectSensorData
//
//  Created by Bo Jhang Ho on 3/18/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CMMotionActivity.h>
#import <CoreMotion/CMMotionActivityManager.h>

#include "Utility.h"

#import "ZipFile.h"
#import "ZipException.h"
#import "FileInZipInfo.h"
#import "ZipWriteStream.h"
#import "ZipReadStream.h"

bool logManagerHasBeenInitialized;
int logManagerNowFileno;
NSTimer *logManagerZipTimer;
FILE *logManagerFoutAcc, *logManagerFoutGyro, *logManagerFoutLoc, *logManagerFoutMot, *logManagerFoutNote;
bool logManagerIsWritable;

const double LOG_INTERVAL = 300.0;

@interface LogManager : NSObject

+ (void)globalInit;
+ (void)inputAccx:(double)x y:(double)y z:(double)z timestamp:(double)time;
+ (void)inputGyrox:(double)x y:(double)y z:(double)z timestamp:(double)time;
+ (void)inputLocLat:(double)lat lon:(double)lon herror:(double)error timestamp:(double)time;
+ (void)inputMotionMid:(int)mid confidence:(int)conf timestamp:(double)time;
+ (void)takeNoteSmoke;
+ (void)takeNoteRestroom;
+ (void)globalEnd;

@end
