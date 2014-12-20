//
//  FrequencyConsulter.h
//  CollectSensorData
//
//  Created by Bo Jhang Ho on 3/2/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FrequencyConsulter : NSObject {
    double timePool[100];
    int si;
    int ei;
    double hz;
    double maxConsiderSec;
}

@property (readonly) double hz;

- (void)setConsiderSec:(double)sec;
- (void)trigger;
- (void)update;

@end
