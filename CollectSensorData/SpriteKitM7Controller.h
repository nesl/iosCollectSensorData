//
//  SpriteKitM7Controller.h
//  CollectSensorData
//
//  Created by Bo Jhang Ho on 3/9/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CMMotionActivity.h>
#import <CoreMotion/CMMotionActivityManager.h>

#import "SpriteKitAppDelegate.h"
#import "Utility.h"

@interface SpriteKitM7Controller : UIViewController {
    IBOutlet UILabel *labelConf;
    IBOutlet UIView *view4activities;
    IBOutlet UIImageView *imageViewStationary;
    IBOutlet UIImageView *imageViewWalking;
    IBOutlet UIImageView *imageViewRunning;
    IBOutlet UIImageView *imageViewDriving;
    IBOutlet UIImageView *imageViewUnknown;
    
    IBOutlet UIProgressView *progressConfidence;
    IBOutlet UILabel *labelConfidence;
    
    IBOutlet UILabel *labelState;
    IBOutlet UILabel *labelStateAge;
    IBOutlet UILabel *labelLastUpdate;
    IBOutlet UILabel *labelLastUpdateAge;
}

@end
