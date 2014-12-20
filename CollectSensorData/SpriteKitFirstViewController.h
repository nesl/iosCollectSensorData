//
//  SpriteKitFirstViewController.h
//  CollectSensorData
//
//  Created by Bo Jhang Ho on 3/2/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

#import "SpriteKitAppDelegate.h"

#import "FrequencyConsulter.h"
#import "Utility.h"

#import "ZipFile.h"
#import "ZipException.h"
#import "FileInZipInfo.h"
#import "ZipWriteStream.h"
#import "ZipReadStream.h"


@interface SpriteKitFirstViewController : UIViewController {
    IBOutlet UILabel *labelAccx;
    IBOutlet UILabel *labelAccy;
    IBOutlet UILabel *labelAccz;
    IBOutlet UIProgressView *progressViewAccx;
    IBOutlet UIProgressView *progressViewAccy;
    IBOutlet UIProgressView *progressViewAccz;
    IBOutlet UILabel *labelAccHz;
    
    IBOutlet UILabel *labelGyrox;
    IBOutlet UILabel *labelGyroy;
    IBOutlet UILabel *labelGyroz;
    IBOutlet UIProgressView *progressViewGyrox;
    IBOutlet UIProgressView *progressViewGyroy;
    IBOutlet UIProgressView *progressViewGyroz;
    IBOutlet UILabel *labelGyroHz;
    
    FrequencyConsulter *accFreqConsulter;
    FrequencyConsulter *gyroFreqConsulter;
    
    //double lastAccx, lastAccy, lastAccz;
}

@property (strong, nonatomic) CMMotionManager *motionManager;
//@property double lastAccx, lastAccy, lastAccz;


//- (IBAction)buttonTestAccTouchDown;


@end
