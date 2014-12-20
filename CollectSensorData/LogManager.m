//
//  LogManager.m
//  CollectSensorData
//
//  Created by Bo Jhang Ho on 3/18/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import "LogManager.h"



@implementation LogManager

+ (void)globalInit {
    if (logManagerHasBeenInitialized)
        return ;
    
    FILE *fin = iosfopen("no", "r");
    if (fin == NULL)
        logManagerNowFileno = 0;
    else {
        fscanf(fin, "%d", &logManagerNowFileno);
        fclose(fin);
    }
    
    logManagerFoutAcc = iosfopen("acc.txt", "a");
    logManagerFoutGyro = iosfopen("gyro.txt", "a");
    logManagerFoutLoc = iosfopen("loc.txt", "a");
    logManagerFoutMot = iosfopen("mot.txt", "a");
    logManagerFoutNote = iosfopen("note.txt", "a");
    logManagerIsWritable = true;
    
    logManagerZipTimer = [NSTimer scheduledTimerWithTimeInterval:LOG_INTERVAL
                                                          target:self
                                                        selector:@selector(upload)
                                                        userInfo:nil
                                                         repeats:YES];
    logManagerHasBeenInitialized = true;
}

+ (void)inputAccx:(double)x y:(double)y z:(double)z timestamp:(double)time {
    if (logManagerIsWritable)
        fprintf(logManagerFoutAcc, "%f %f %f %f\n", time, x, y, z);
}

+ (void)inputGyrox:(double)x y:(double)y z:(double)z timestamp:(double)time {
    if (logManagerIsWritable)
        fprintf(logManagerFoutGyro, "%f %f %f %f\n", time, x, y, z);
}

+ (void)inputLocLat:(double)lat lon:(double)lon herror:(double)error timestamp:(double)time {
    if (logManagerIsWritable)
        fprintf(logManagerFoutLoc, "%f %f %f %f\n", time, lat, lon, error);
}

+ (void)inputMotionMid:(int)mid confidence:(int)conf timestamp:(double)time {
    while (!logManagerIsWritable);
    fprintf(logManagerFoutMot, "%f %d %d\n", time, mid, conf);
}

+ (void)takeNoteSmoke {
    while (!logManagerIsWritable);
    fprintf(logManagerFoutNote, "%f 0\n", CFAbsoluteTimeGetCurrent());
}

+ (void)takeNoteRestroom {
    while (!logManagerIsWritable);
    fprintf(logManagerFoutNote, "%f 1\n", CFAbsoluteTimeGetCurrent());
}

+ (void)globalEnd {
    fclose(logManagerFoutAcc);
    fclose(logManagerFoutGyro);
    fclose(logManagerFoutLoc);
    fclose(logManagerFoutMot);
    fclose(logManagerFoutNote);
}

+ (void)upload {
    
    logManagerIsWritable = false;
    [NSThread sleepForTimeInterval:0.01];
    
    fclose(logManagerFoutAcc);
    fclose(logManagerFoutGyro);
    fclose(logManagerFoutLoc);
    fclose(logManagerFoutMot);
    fclose(logManagerFoutNote);
    
    
    char zipFileNameC[20];
    sprintf(zipFileNameC, "%08d.zip", logManagerNowFileno);
    NSString *zipPathName = getPathName(zipFileNameC);
    //char zipPathNameC[100];
    //sprintf(zipPathNameC, "%08d.zip", logManagerNowFileno);
    
    double t1 = CFAbsoluteTimeGetCurrent();
    
    @try {
        //NSLog(@"begin zip");
        ZipFile *zipFile= [[ZipFile alloc] initWithFileName:zipPathName mode:ZipFileModeCreate];
        ZipWriteStream *stream;
        NSString *content;
        
        //NSLog(@"zip 1");
        stream = [zipFile writeFileInZipWithName:@"acc.txt" compressionLevel:ZipCompressionLevelDefault];
        content = [NSString stringWithContentsOfFile:getPathName("acc.txt") encoding:NSUTF8StringEncoding error:NULL];
        [stream writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        
        //NSLog(@"zip 2");
        stream = [zipFile writeFileInZipWithName:@"gyro.txt" compressionLevel:ZipCompressionLevelDefault];
        content = [NSString stringWithContentsOfFile:getPathName("gyro.txt") encoding:NSUTF8StringEncoding error:NULL];
        [stream writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        
        //NSLog(@"zip 3");
        stream = [zipFile writeFileInZipWithName:@"loc.txt" compressionLevel:ZipCompressionLevelDefault];
        content = [NSString stringWithContentsOfFile:getPathName("loc.txt") encoding:NSUTF8StringEncoding error:NULL];
        [stream writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        
        stream = [zipFile writeFileInZipWithName:@"mot.txt" compressionLevel:ZipCompressionLevelDefault];
        content = [NSString stringWithContentsOfFile:getPathName("mot.txt") encoding:NSUTF8StringEncoding error:NULL];
        [stream writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        
        stream = [zipFile writeFileInZipWithName:@"note.txt" compressionLevel:ZipCompressionLevelDefault];
        content = [NSString stringWithContentsOfFile:getPathName("note.txt") encoding:NSUTF8StringEncoding error:NULL];
        [stream writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
        
        [zipFile close];
    } @catch (id e) {
		//[self performSelectorOnMainThread:@selector(log:) withObject:@"Caught a generic exception (see logs), /terminating..." waitUntilDone:YES];
        
		NSLog(@"Exception caught: %@ - %@", [[e class] description], [e description]);
	}

    double t2 = CFAbsoluteTimeGetCurrent();
    NSLog(@"zip time: %lf", t2 - t1);
    
    logManagerFoutAcc = iosfopen("acc.txt", "w");
    logManagerFoutGyro = iosfopen("gyro.txt", "w");
    logManagerFoutLoc = iosfopen("loc.txt", "w");
    logManagerFoutMot = iosfopen("mot.txt", "w");
    logManagerFoutNote = iosfopen("note.txt", "w");
    logManagerIsWritable = true;
    
    logManagerNowFileno++;
    FILE *ftmp = iosfopen("no", "w");
    fprintf(ftmp, "%d", logManagerNowFileno);
    fclose(ftmp);
    
    
    // do something about motion file
    
    /*
    NSLog(@"network begin");
    
    NSString *urlString = @"http://172.17.5.61";
    NSString *filename = [[NSString alloc] initWithFormat:@"%08d.zip", logManagerNowFileno-1];
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
    
    NSData *zipData = [[NSFileManager defaultManager] contentsAtPath:getPathName([filename UTF8String])];
    [postbody appendData:zipData];
    
    //[postbody appendData:[@"1234test1234" dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postbody];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", returnString);
    */

}


@end
