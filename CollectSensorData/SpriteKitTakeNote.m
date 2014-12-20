//
//  SpriteKitTakeNote.m
//  CollectSensorData
//
//  Created by Bo Jhang Ho on 3/19/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import "SpriteKitTakeNote.h"

@interface SpriteKitTakeNote () {
    NSDateFormatter *dateFormatter;
    char ip[100];
    char userID[100];
    NSTimer *filesizeTimer;
}

@end


@implementation SpriteKitTakeNote

- (void)viewDidLoad {
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd HH:mm:ss"];
    textIP.delegate = self;
    textUserID.delegate = self;
    //buttonUserID.adjustsImageWhenDisabled = NO;
    //buttonUserID.adjustsImageWhenHighlighted = NO;
    [buttonUserID setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    textUserID.alpha = 0.0;
    textUserID.autocorrectionType = UITextAutocorrectionTypeNo;
    textUserID.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    FILE *fupload = iosfopen("upload", "r");
    if (fupload == NULL) {
        fupload = iosfopen("upload", "w");
        [self randomGenerateUerID];
        fprintf(fupload, "172.17.5.61 %s", userID);
        fclose(fupload);
        fupload = iosfopen("upload", "r");
    }
    fscanf(fupload, "%s %s", ip, userID);
    fclose(fupload);
    [buttonUserID setTitle:[NSString stringWithCString:userID encoding:NSASCIIStringEncoding] forState:UIControlStateNormal];
    //NSLog(@"ip:%@", [NSString stringWithCString:ip encoding:NSASCIIStringEncoding]);
    textIP.text = [NSString stringWithCString:ip encoding:NSASCIIStringEncoding];
    
    filesizeTimer = [NSTimer scheduledTimerWithTimeInterval:600
                                                     target:self
                                                   selector:@selector(updateFileSize)
                                                   userInfo:nil
                                                    repeats:YES];
    [self updateFileSize];
}

- (IBAction)buttonUserIDDoubleTouchDown {
    textUserID.alpha = 1.0;
    buttonUserID.alpha = 0.0;
    textUserID.text = buttonUserID.currentTitle;
    [textUserID becomeFirstResponder];
    //NSLog(@"detect it");
}

- (IBAction)textUserIDEndEnter {
    const char *tp = [textUserID.text UTF8String];
    int tlen = 0;
    for (int i = 0; tp[i] != '\0' && tlen < 8; i++) {
        if ('a' <= tp[i] && tp[i] <= 'z')
            userID[tlen++] = tp[i];
        else if ('0' <= tp[i] && tp[i] <= '9')
            userID[tlen++] = tp[i];
        else if ('A' <= tp[i] && tp[i] <= 'Z')
            userID[tlen++] = tp[i] - 'A' + 'a';
    }
    userID[tlen] = '\0';
    if (tlen == 0)
        [self randomGenerateUerID];
    [buttonUserID setTitle:[NSString stringWithCString:userID encoding:NSASCIIStringEncoding] forState:UIControlStateNormal];
    FILE *fupload = iosfopen("upload", "w");
    fprintf(fupload, "%s %s", ip, userID);
    fclose(fupload);
    textUserID.alpha = 0.0;
    buttonUserID.alpha = 1.0;
    //NSLog(@"leave");
}

- (IBAction)textfileSizeEndEnter {
    const char *tp = [textIP.text UTF8String];
    if (strlen(tp) < 20)
        strcpy(ip, tp);
    FILE *fupload = iosfopen("upload", "w");
    fprintf(fupload, "%s %s", ip, userID);
    fclose(fupload);
}

- (IBAction)buttonTakeNoteSmokeTouchDown {
    [LogManager takeNoteSmoke];
    labelSmokeNoteMessage.text = [dateFormatter stringFromDate:[NSDate date]];
}


- (IBAction)buttonTakeNoteRestroomTouchDown {
    [LogManager takeNoteRestroom];
    labelRestroomNoteMessage.text = [dateFormatter stringFromDate:[NSDate date]];
}

- (IBAction)buttonUploadTouchDown {
    buttonUpload.alpha = 0;
    labelUploadStatus.text = @"calculating...";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int minNo = logManagerNowFileno;
        int maxNo = logManagerNowFileno;
        int nr = 0;
        char fileNameC[100];
        for (int i = logManagerNowFileno; i >= 0; i--) {
            sprintf(fileNameC, "%08d.zip", i);
            if (iosfileExist(fileNameC)) {
                minNo = i;
                nr++;
            }
        }
        NSLog(@"find %d files to upload (%d-%d)", nr, minNo, maxNo);
        
        NSLog(@"network begin");
    
        NSString *urlString = [[NSString alloc] initWithFormat:@"http://%s", ip];
        NSLog(@"upload to %@", urlString);
        int trial = 0;
        int i;
        for (i = minNo; i <= maxNo && trial < 2; i++) {
            sprintf(fileNameC, "%08d.zip", i);
            if (iosfileExist(fileNameC)) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    labelUploadStatus.text = [[NSString alloc] initWithFormat:@"Upload: %08d.zip (%d/%d)", i, i - minNo + 1, maxNo - minNo + 1];
                });
                
                NSString *inFilename = [[NSString alloc] initWithFormat:@"%08d.zip", i];
                NSString *outFilename = [[NSString alloc] initWithFormat:@"%s_%08d.zip", userID, i];
                NSMutableURLRequest *request= [[NSMutableURLRequest alloc] init];
                [request setURL:[NSURL URLWithString:urlString]];
                [request setHTTPMethod:@"POST"];
                NSString *boundary = @"---------------------------14737809831466499882746641449";
                NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
                [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
                NSMutableData *postbody = [NSMutableData data];
                [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"iagreewithyou\"; filename=\"%@\"\r\n", outFilename] dataUsingEncoding:NSUTF8StringEncoding]];
                [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                
                NSData *zipData = [[NSFileManager defaultManager] contentsAtPath:getPathName([inFilename UTF8String])];
                [postbody appendData:zipData];
                
                //[postbody appendData:[@"1234test1234" dataUsingEncoding:NSUTF8StringEncoding]];
                [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [request setHTTPBody:postbody];
                
                NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                if (returnData == nil) {
                    trial++;
                    NSLog(@"network connection failed (%d)", trial);
                    continue;
                }
                
                NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                //const char *ptr = [returnString UTF8String];
                //int len = strlen(ptr);
                //for (int i = 0; i < len; i++)
                //    NSLog(@"%c (%d)", ptr[i], (int)ptr[i]);
                if ([returnString isEqualToString:@"okdes\n"]) {
                    NSLog(@"should delete %s", fileNameC);
                    iosfileDelete(fileNameC);
                }
                NSLog(@"end upload %@ with message: %@", outFilename, returnString);
                trial = 0;
            }
        }
        
        if (trial > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                labelUploadStatus.text = [[NSString alloc] initWithFormat:@"Upload failed (%d files uploaded)", i - minNo + 1];
            });
            NSLog(@"upload abort");
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                labelUploadStatus.text = [[NSString alloc] initWithFormat:@"Upload complete (%d files uploaded)", maxNo - minNo + 1];
            });
            NSLog(@"upload %d files", nr);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            buttonUpload.alpha = 1;
            [self updateFileSize];
        });
    });
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)randomGenerateUerID {
    userID[0] = 'u';
    for (int i = 1; i <= 3; i++)
        userID[i] = '0' + arc4random() % 10;
}

- (void)updateFileSize {
    char fileNameC[100];
    NSInteger size = 0;
    for (int i = logManagerNowFileno; i >= 0; i--) {
        sprintf(fileNameC, "%08d.zip", i);
        size += iosfileSize(fileNameC);
    }
    double sizef = (double)size;
    sizef /= 1024.0;
    if (sizef < 0.1)
        labelFileSize.text = [[NSString alloc] initWithFormat:@"Total file size: %.1fKB", sizef];
    else {
        sizef /= 1024.0;
        if (sizef < 1000.0)
            labelFileSize.text = [[NSString alloc] initWithFormat:@"Total file size: %.1fMB", sizef];
        else {
            sizef /= 1024.0;
            labelFileSize.text = [[NSString alloc] initWithFormat:@"Total file size: %.1fGB", sizef];
        }
    }
}

@end

