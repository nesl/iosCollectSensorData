//
//  SpriteKitSecondViewController.h
//  CollectSensorData
//
//  Created by Bo Jhang Ho on 3/2/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "FrequencyConsulter.h"
#import "Utility.h"
#import "LogManager.h"

@interface SpriteKitSecondViewController : UIViewController <CLLocationManagerDelegate> {
    IBOutlet UILabel *labelLat;
    IBOutlet UILabel *labelLatErr;
    IBOutlet UILabel *labelLon;
    IBOutlet UILabel *labelLonErr;
    IBOutlet UILabel *labelAlt;
    IBOutlet UILabel *labelAltErr;
    IBOutlet UILabel *labelTimestamp;
    IBOutlet UILabel *labelTimestampExp;
    IBOutlet UILabel *labelAge;
    IBOutlet UILabel *labelUpdateDistance;
    IBOutlet UILabel *labelLocationHz;
    IBOutlet UILabel *labelSampleCount;
    
    CLLocationManager *locationManager;
    NSDateFormatter *dateFormatter;
    FrequencyConsulter *locationFreqConsulter;
    
    NSTimer *locTimer;
    int sampleAge;
    int nrOfSample;
}

@end
