//
//  SpriteKitTakeNote.h
//  CollectSensorData
//
//  Created by Bo Jhang Ho on 3/19/14.
//  Copyright (c) 2014 Bo Jhang Ho. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LogManager.h"

@interface SpriteKitTakeNote : UIViewController <UITextFieldDelegate> {
    IBOutlet UIButton *buttonUpload;
    IBOutlet UITextField *textIP;
    IBOutlet UILabel *labelUploadStatus;
    
    IBOutlet UIButton *buttonUserID;
    IBOutlet UITextField *textUserID;
    
    IBOutlet UIButton *buttonTakeSmokeNote;
    IBOutlet UILabel *labelSmokeNoteMessage;
    
    IBOutlet UIButton *buttonTakeRestroomNote;
    IBOutlet UILabel *labelRestroomNoteMessage;
    
    IBOutlet UILabel *labelFileSize;
}

- (IBAction)buttonUserIDDoubleTouchDown;
- (IBAction)textUserIDEndEnter;
- (IBAction)textfileSizeEndEnter;
- (IBAction)buttonTakeNoteSmokeTouchDown;
- (IBAction)buttonTakeNoteRestroomTouchDown;
- (IBAction)buttonUploadTouchDown;

@end
