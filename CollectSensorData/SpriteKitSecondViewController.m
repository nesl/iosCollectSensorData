//
//  SpriteKitSecondViewController.m
//  CollectSensorData
//
//  Created by Bo Jhang Ho on 3/2/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import "SpriteKitSecondViewController.h"


@interface SpriteKitSecondViewController ()

@end

@implementation SpriteKitSecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //NSLog(@"second view begin didLoad");
    
    locationFreqConsulter = [[FrequencyConsulter alloc] init];
    [locationFreqConsulter setConsiderSec:600.0];
    
    //NSLog(@"second view begin didLoad2");
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 1;
    
    //NSLog(@"second view begin didLoad3");
    
    if([CLLocationManager locationServicesEnabled]){
        [locationManager startUpdatingLocation];
    }
    else {
        NSLog(@"can't use location service");
    }
    
    //NSLog(@"second view begin didLoad4");
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd HH:mm:ss"];
    
    //NSLog(@"successfully load");
    
    double latt = 34.069320;
    double latb = 34.068517;
    double lonl = -118.443380;
    double lonr = -118.442545;
    
    CLLocation *l1 = [[CLLocation alloc] initWithLatitude:latt longitude:lonl];
    CLLocation *l2 = [[CLLocation alloc] initWithLatitude:latt longitude:lonr];
    CLLocation *l3 = [[CLLocation alloc] initWithLatitude:latb longitude:lonl];
    CLLocation *l4 = [[CLLocation alloc] initWithLatitude:latb longitude:lonr];
    NSLog(@"top edge: %f", [l1 distanceFromLocation:l2]);
    NSLog(@"button edge: %f", [l3 distanceFromLocation:l4]);
    NSLog(@"left edge: %f", [l1 distanceFromLocation:l3]);
    NSLog(@"right edge: %f", [l2 distanceFromLocation:l4]);
    
    // horizontal distance: 77.079 m
    // vertical distance: 89.071 m
    // v / h = 1.15558
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    //NSLog(@"latitude %+.6f, longitude %+.6f\n",
    //      newLocation.coordinate.latitude,
    //      newLocation.coordinate.longitude);
    //NSLog(@"Horizontal Accuracy:%f", newLocation.horizontalAccuracy);
    
    labelLat.text = [[NSString alloc] initWithFormat:@"Latitude: %.6f", newLocation.coordinate.latitude];
    labelLatErr.text = [[NSString alloc] initWithFormat:@"%.2fm", newLocation.horizontalAccuracy];
    labelLon.text = [[NSString alloc] initWithFormat:@"Longitude: %.6f", newLocation.coordinate.longitude];
    labelLonErr.text = [[NSString alloc] initWithFormat:@"%.2fm", newLocation.horizontalAccuracy];
    labelAlt.text = [[NSString alloc] initWithFormat:@"Altitude: %.6f", newLocation.altitude];
    labelAltErr.text = [[NSString alloc] initWithFormat:@"%.2fm", newLocation.verticalAccuracy];
    labelTimestamp.text = [[NSString alloc] initWithFormat:@"Timestamp: %.1f", [newLocation.timestamp timeIntervalSinceReferenceDate]];
    labelTimestampExp.text = [dateFormatter stringFromDate:newLocation.timestamp];
    labelAge.text = [[NSString alloc] initWithFormat:@"Age of last sample: %@", [Utility humanReadableTimeDuration:howRecent]];
    labelUpdateDistance.text = [[NSString alloc] initWithFormat:@"How far from last sample: %.1fm", [newLocation distanceFromLocation:oldLocation]];
    [locationFreqConsulter trigger];
    labelLocationHz.text = [[NSString alloc] initWithFormat:@"Sampling rate: %.2lf Hz", locationFreqConsulter.hz];
    nrOfSample++;
    labelSampleCount.text = [[NSString alloc] initWithFormat:@"Already got %d sample(s)", nrOfSample];
    
    //Optional: turn off location services once we've gotten a good location
    sampleAge = (int)howRecent;
    if (locTimer != nil)
        [locTimer invalidate];
    locTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                target:self
                                              selector:@selector(updateLocationHz)
                                              userInfo:nil
                                               repeats:YES];
}

- (void)updateLocationHz {
    sampleAge++;
    labelAge.text = [[NSString alloc] initWithFormat:@"Age of last sample: %@", [Utility humanReadableTimeDuration:sampleAge]];
    [locationFreqConsulter update];
    labelLocationHz.text = [[NSString alloc] initWithFormat:@"Sampling rate: %.2lf Hz", locationFreqConsulter.hz];
}



@end
