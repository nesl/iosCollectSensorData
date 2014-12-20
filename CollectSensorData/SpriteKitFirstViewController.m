//
//  SpriteKitFirstViewController.m
//  CollectSensorData
//
//  Created by Bo Jhang Ho on 3/2/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import "SpriteKitFirstViewController.h"

@interface SpriteKitFirstViewController () {
    UIBackgroundTaskIdentifier backgroundTask;
    int count;
}
@end

@implementation SpriteKitFirstViewController

@synthesize motionManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    accFreqConsulter = [[FrequencyConsulter alloc] init];
    [accFreqConsulter setConsiderSec:60.0];
    gyroFreqConsulter = [[FrequencyConsulter alloc] init];
    [gyroFreqConsulter setConsiderSec:60.0];
    
    motionManager = [[CMMotionManager alloc] init];

    [motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
                                        withHandler:^(CMAccelerometerData *data, NSError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [LogManager inputAccx:data.acceleration.x y:data.acceleration.y z:data.acceleration.z timestamp:CFAbsoluteTimeGetCurrent()];
                                                if (isUIUpdating) {
                                                    [self getAccelerometerDataX:data.acceleration.x
                                                                          dataY:data.acceleration.y
                                                                          dataZ:data.acceleration.z];
                                                }
                                                //NSLog(@"(%d) receive %lf %lf %lf", count, data.acceleration.x, data.acceleration.y, data.acceleration.z);
                                                //NSLog(@"%f", data.timestamp);
                                                //count++;
                                                //NSLog(@"%f", ([UIApplication sharedApplication].backgroundTimeRemaining));
                                            });
                                        }];
    motionManager.accelerometerUpdateInterval = 0.02;
    
    [motionManager startGyroUpdatesToQueue:[[NSOperationQueue alloc] init]
                                        withHandler:^(CMGyroData *data, NSError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                //NSLog(@"gyro");
                                                [LogManager inputGyrox:data.rotationRate.x y:data.rotationRate.y z:data.rotationRate.z timestamp:CFAbsoluteTimeGetCurrent()];
                                                if (isUIUpdating) {
                                                    [self getGyroDataX:data.rotationRate.x
                                                                 dataY:data.rotationRate.y
                                                                 dataZ:data.rotationRate.z];
                                                }
                                            });
                                        }];
    motionManager.gyroUpdateInterval = 0.02;
    
    /*
    FILE *fin = iosfopen("test.txt", "r");
    if (fin != NULL) {
        int t;
        fscanf(fin, "%d", &t);
        NSLog(@"read number %d", t);
        fclose(fin);
    }
    FILE *fout = iosfopen("test.txt", "a");
    fprintf(fout, " 35");
    fclose(fout);
    NSLog(@"current file size: %zd", [Utility iosFileSize:"test.txt"]);
    */
    /*
    FILE *fout;
    fout = iosfopen("a.txt", "w");
    fprintf(fout, "good day commander");
    fclose(fout);
    
    fout = iosfopen("b.txt", "w");
    fprintf(fout, "hello cindy");
    fclose(fout);
    
    fout = iosfopen("c.txt", "w");
    fprintf(fout, "several\nlines\nhelloworld");
    fclose(fout);
  
    NSString *txtFileContents = [NSString stringWithContentsOfFile:getPathName("c.txt") encoding:NSUTF8StringEncoding error:NULL];
    NSLog(@"%@", txtFileContents);

    
    
    @try {
        NSString *zipPathName = getPathName("test.zip");
        ZipFile *zipFile= [[ZipFile alloc] initWithFileName:zipPathName mode:ZipFileModeCreate];
        ZipWriteStream *stream;
        NSString *content;

        stream = [zipFile writeFileInZipWithName:@"a.txt" compressionLevel:ZipCompressionLevelNone];
        content = [NSString stringWithContentsOfFile:getPathName("a.txt") encoding:NSUTF8StringEncoding error:NULL];
        [stream writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];

        stream = [zipFile writeFileInZipWithName:@"b.txt" compressionLevel:ZipCompressionLevelNone];
        content = [NSString stringWithContentsOfFile:getPathName("b.txt") encoding:NSUTF8StringEncoding error:NULL];
        [stream writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];

        stream = [zipFile writeFileInZipWithName:@"c.txt" compressionLevel:ZipCompressionLevelNone];
        content = [NSString stringWithContentsOfFile:getPathName("c.txt") encoding:NSUTF8StringEncoding error:NULL];
        [stream writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        
        [zipFile close];
    } @catch (id e) {
		//[self performSelectorOnMainThread:@selector(log:) withObject:@"Caught a generic exception (see logs), /terminating..." waitUntilDone:YES];
        
		NSLog(@"Exception caught: %@ - %@", [[e class] description], [e description]);
	}

    
    NSString *urlString = @"http://172.17.5.61";
    NSString *filename = @"test.zip";
    NSMutableURLRequest *request= [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"iagreewithyou\"; filename=\"%@\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSData *zipData = [[NSFileManager defaultManager] contentsAtPath:getPathName("test.zip")];
    [postbody appendData:zipData];
    
    //[postbody appendData:[@"1234test1234" dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postbody];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", returnString);
    
    backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"Background handler called. Not running background tasks anymore.");
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }];*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*- (IBAction)buttonTestAccTouchDown {
    double valx = [self getRandomNumberMin:-1.0 max:1.0];
    double valy = [self getRandomNumberMin:-1.0 max:1.0];
    double valz = [self getRandomNumberMin:-1.0 max:1.0];
    [self getAccelerometerDataX:valx dataY:valy dataZ:valz];
   
}*/

- (void)getAccelerometerDataX:(double)x dataY:(double)y dataZ:(double)z {
    labelAccx.text = [[NSString alloc] initWithFormat:@"%.2lf", x];
    labelAccy.text = [[NSString alloc] initWithFormat:@"%.2lf", y];
    labelAccz.text = [[NSString alloc] initWithFormat:@"%.2lf", z];
    [progressViewAccx setProgress:(x + 1.0) / 2.0 animated:NO];
    [progressViewAccy setProgress:(y + 1.0) / 2.0 animated:NO];
    [progressViewAccz setProgress:(z + 1.0) / 2.0 animated:NO];
    [accFreqConsulter trigger];
    labelAccHz.text = [[NSString alloc] initWithFormat:@"Sampling rate: %.2lf Hz", accFreqConsulter.hz];
    //NSLog(@"(%d) receive %lf %lf %lf %lf", count, x, y, z, [UIApplication sharedApplication].backgroundTimeRemaining);
    count++;
}

- (void)getGyroDataX:(double)x dataY:(double)y dataZ:(double)z {
    labelGyrox.text = [[NSString alloc] initWithFormat:@"%.2lf", x];
    labelGyroy.text = [[NSString alloc] initWithFormat:@"%.2lf", y];
    labelGyroz.text = [[NSString alloc] initWithFormat:@"%.2lf", z];
    [progressViewGyrox setProgress:(x + 3.0) / 6.0 animated:NO];
    [progressViewGyroy setProgress:(y + 3.0) / 6.0 animated:NO];
    [progressViewGyroz setProgress:(z + 3.0) / 6.0 animated:NO];
    [gyroFreqConsulter trigger];
    labelGyroHz.text = [[NSString alloc] initWithFormat:@"Sampling rate: %.2lf Hz", gyroFreqConsulter.hz];
    //NSLog(@"(%d) receive %lf %lf %lf %lf", count, x, y, z, [UIApplication sharedApplication].backgroundTimeRemaining);
    
}



@end
