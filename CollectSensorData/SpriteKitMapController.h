//
//  SpriteKitMapController.h
//  CollectSensorData
//
//  Created by Bo Jhang Ho on 3/8/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SpriteKitMapController : UIViewController <UIScrollViewDelegate, CLLocationManagerDelegate> {
    IBOutlet UIScrollView *scrollView;
    
    CLLocationManager *locationManager;
    
}

//- (IBAction)buttonTest;

@end
