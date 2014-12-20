//
//  SpriteKitM7Controller.m
//  CollectSensorData
//
//  Created by Bo Jhang Ho on 3/9/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import "SpriteKitM7Controller.h"

@interface SpriteKitM7Controller () {
    CMMotionActivityManager *motionActivityManager;
    CMMotionActivity *lastActivity;
    NSDateFormatter *dateFormatter;
    
    NSTimer *m7Timer;
    double stateStartTime;
    double stateStartTimeAge;
    double updateAge;
}
@end

@implementation SpriteKitM7Controller


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if([CMMotionActivityManager isActivityAvailable]) {
        motionActivityManager = [[CMMotionActivityManager alloc] init];
        /*NSDate *today = [NSDate date];
        NSDate *lastWeek = [today dateByAddingTimeInterval:-(86400*7*10)];
        [motionActivityManager queryActivityStartingFromDate:lastWeek toDate:today toQueue:[NSOperationQueue mainQueue] withHandler:^(NSArray *activities, NSError *error){
            NSLog(@"grab %tu activity data", [activities count]);
            //for (int i = 0; i < [activities count]; i++) {
            for (int i = 0; i < 1; i++) {
                CMMotionActivity *a = [activities objectAtIndex:i];
                NSString *confidence = @"low";
                if (a.confidence == CMMotionActivityConfidenceMedium) confidence = @"medium";
                if (a.confidence == CMMotionActivityConfidenceHigh) confidence = @"high";
                NSString *motion = @"unknown";
                if (a.stationary) motion = [motion stringByAppendingString:@"stationary "];
                if (a.walking) motion = [motion stringByAppendingString:@"walking "];
                if (a.running) motion = [motion stringByAppendingString:@"running "];
                if (a.automotive) motion = [motion stringByAppendingString:@"automotive "];
                
                // Now get steps as well
                NSLog(@"%@ confidence %@ type %@", [NSDateFormatter localizedStringFromDate:a.startDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle], confidence, motion);
                
            }
        }];*/
        
        NSDate *today = [NSDate date];
        NSDate *lastMinute = [today dateByAddingTimeInterval:-(600.0)];
        [motionActivityManager queryActivityStartingFromDate:lastMinute toDate:today toQueue:[NSOperationQueue mainQueue] withHandler:^(NSArray *activities, NSError *error) {
            //NSLog(@"grab %tu activity data", [activities count]);
            //for (int i = 0; i < [activities count]; i++) {
            NSLog(@"grab %tu activity data", [activities count]);
            if ([activities count] > 0) {
                NSInteger lastActivityInd = [activities count] - 1;
                [self receiveNewActivity:[activities objectAtIndex:lastActivityInd]];
            }
            //NSString *confidence = @"low";
            //if (lastActivity.confidence == CMMotionActivityConfidenceMedium) confidence = @"medium";
            //if (lastActivity.confidence == CMMotionActivityConfidenceHigh) confidence = @"high";
            //NSString *motion = @"";
            //if (lastActivity.stationary) motion = [motion stringByAppendingString:@"stationary "];
            //if (lastActivity.walking) motion = [motion stringByAppendingString:@"walking "];
            //if (lastActivity.running) motion = [motion stringByAppendingString:@"running "];
            //if (lastActivity.automotive) motion = [motion stringByAppendingString:@"automotive "];
            //if (lastActivity.unknown) motion = [motion stringByAppendingString:@"unknown "];
            
            //NSLog(@"%@ confidence %@ type %@", [NSDateFormatter localizedStringFromDate:lastActivity.startDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle], confidence, motion);
            [motionActivityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMotionActivity *activity) {
                [self receiveNewActivity:activity];
            }];
        }];
    } else {
        NSLog(@"cm not ok");
    }
    
    
    imageViewStationary.image = [UIImage imageNamed:@"a_stationary"];
    imageViewWalking.image = [UIImage imageNamed:@"a_walking"];
    imageViewRunning.image = [UIImage imageNamed:@"a_running"];
    imageViewDriving.image = [UIImage imageNamed:@"a_driving"];
    imageViewUnknown.image = [UIImage imageNamed:@"a_unknown"];
    
    view4activities.alpha = 0.0;
    progressConfidence.progress = 1.0;
    labelConfidence.text = @"high";
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSDate *today = [NSDate date];
    labelState.text = [[NSString alloc] initWithFormat:@"State start from: %@", [dateFormatter stringFromDate:today]];
    labelStateAge.text = [[NSString alloc] initWithFormat:@"Age: %@", [Utility humanReadableTimeDuration:0.0]];
    updateAge = 0.0;
    
    m7Timer = [NSTimer scheduledTimerWithTimeInterval:1
                                               target:self
                                             selector:@selector(updateStat)
                                             userInfo:nil
                                              repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)receiveNewActivity:(CMMotionActivity*)newActivity {
    //NSString *confidence = @"low";
    //if (newActivity.confidence == CMMotionActivityConfidenceMedium) confidence = @"medium";
    //if (newActivity.confidence == CMMotionActivityConfidenceHigh) confidence = @"high";
    //NSString *motion = @"";
    //if (newActivity.stationary) motion = [motion stringByAppendingString:@"stationary "];
    //if (newActivity.walking) motion = [motion stringByAppendingString:@"walking "];
    //if (newActivity.running) motion = [motion stringByAppendingString:@"running "];
    //if (newActivity.automotive) motion = [motion stringByAppendingString:@"automotive "];
    //if (newActivity.unknown) motion = [motion stringByAppendingString:@"unknown "];
    //NSLog(@"receive: %@ confidence %@ type %@", [NSDateFormatter localizedStringFromDate:newActivity.startDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle], confidence, motion);
    
    BOOL updateStateStartTime = NO;
    
    if (lastActivity == nil) {
        if (newActivity.unknown == NO) {
            [UIView beginAnimations:@"" context:nil];
            view4activities.alpha = 1.0;
            imageViewUnknown.alpha = 0.0;
            [UIView commitAnimations];
        }
        updateStateStartTime = YES;
    }
    else {
        if (lastActivity.unknown == YES && newActivity.unknown == YES);
        else if (lastActivity.unknown == YES && newActivity.unknown == NO) {
            [UIView beginAnimations:@"" context:nil];
            view4activities.alpha = 0.0;
            imageViewUnknown.alpha = 1.0;
            [UIView commitAnimations];
            updateStateStartTime = YES;
        }
        else if (lastActivity.unknown == NO && newActivity.unknown == YES) {
            [UIView beginAnimations:@"" context:nil];
            view4activities.alpha = 1.0;
            imageViewUnknown.alpha = 0.0;
            [UIView commitAnimations];
            updateStateStartTime = YES;
        }
        else if (lastActivity.stationary != newActivity.stationary || lastActivity.walking != newActivity.walking || lastActivity.running != newActivity.running || lastActivity.automotive != newActivity.automotive){
            updateStateStartTime = YES;
        }
    }
    
    if (updateStateStartTime == YES) {
        stateStartTime = [newActivity.startDate timeIntervalSinceReferenceDate];
        stateStartTimeAge = -[newActivity.startDate timeIntervalSinceNow];
        labelState.text = [[NSString alloc] initWithFormat:@"State start from: %@", [dateFormatter stringFromDate:newActivity.startDate]];
        labelStateAge.text = [[NSString alloc] initWithFormat:@"Age: %@", [Utility humanReadableTimeDuration:stateStartTimeAge]];
        lastActivity = newActivity;
        
    }
    
    if (newActivity.unknown == NO) {
        imageViewStationary.alpha = (newActivity.stationary ? 1.0 : 0.3);
        imageViewWalking.alpha =    (newActivity.walking    ? 1.0 : 0.3);
        imageViewRunning.alpha =    (newActivity.running    ? 1.0 : 0.3);
        imageViewDriving.alpha =    (newActivity.automotive ? 1.0 : 0.3);
    }
    
    switch (newActivity.confidence) {
        case CMMotionActivityConfidenceLow:
            progressConfidence.progress = 0.0;
            labelConfidence.text = @"low";
            break;
        case CMMotionActivityConfidenceMedium:
            progressConfidence.progress = 0.5;
            labelConfidence.text = @"medium";
            break;
        case CMMotionActivityConfidenceHigh:
            progressConfidence.progress = 1.0;
            labelConfidence.text = @"high";
    }
    
    [m7Timer invalidate];
    stateStartTimeAge = [[NSDate date] timeIntervalSinceReferenceDate] - stateStartTime;
    labelLastUpdate.text = [[NSString alloc] initWithFormat:@"Last update: %@", [dateFormatter stringFromDate:newActivity.startDate]];
    labelLastUpdateAge.text = [[NSString alloc] initWithFormat:@"Age: %@", [Utility humanReadableTimeDuration:0.0]];
    updateAge = 0.0;
    m7Timer = [NSTimer scheduledTimerWithTimeInterval:1
                                               target:self
                                             selector:@selector(updateStat)
                                             userInfo:nil
                                              repeats:YES];
}

- (void)updateStat {
    if (isUIUpdating) {
        stateStartTimeAge += 1.0;
        updateAge += 1.0;
    
        labelStateAge.text = [[NSString alloc] initWithFormat:@"Age: %@", [Utility humanReadableTimeDuration:stateStartTimeAge]];
        if (lastActivity != nil)
            labelLastUpdateAge.text = [[NSString alloc] initWithFormat:@"Age: %@", [Utility humanReadableTimeDuration:updateAge]];
    }
}

@end