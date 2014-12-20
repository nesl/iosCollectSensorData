//
//  FrequencyConsulter.m
//  CollectSensorData
//
//  Created by Bo Jhang Ho on 3/2/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import "FrequencyConsulter.h"

@implementation FrequencyConsulter

@synthesize hz;

- (id)init {
    self = [super init];
    maxConsiderSec = 60.0;
    return self;
}

- (void)setConsiderSec:(double)sec {
    maxConsiderSec = sec;
}

- (void)trigger {
    double now = CFAbsoluteTimeGetCurrent();
    timePool[ei % 100] = now;
    ei++;
    while (si < ei) {
        if (ei - si == 100 || now - timePool[si % 100] > maxConsiderSec)
            si++;
        else
            break;
    }
    if (ei - si < 2)
        hz = 0.0;
    else
        hz = 1.0 / ((now - timePool[si % 100]) / (ei - si));
    //NSLog(@"%f", hz);
    //hz++;
}

- (void)update {
    double now = CFAbsoluteTimeGetCurrent();
    while (si < ei) {
        if (now - timePool[si % 100] > maxConsiderSec)
            si++;
        else
            break;
    }
    if (ei - si < 2)
        hz = 0.0;
    else
        hz = 1.0 / ((now - timePool[si % 100]) / (ei - si));
    //NSLog(@"%f", hz);
    //hz++;
}

@end
