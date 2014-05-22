//
//  CommentInputController.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 22.05.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Entry;

@interface CommentInputController : UIViewController <UIPopoverControllerDelegate>

@property (nonatomic,retain) IBOutlet UITextView *textView;
@property (nonatomic,retain) Entry *currentEntry;

- (void)prepareForEditingEntry:(Entry *)entry fromDelegate:(id)delegate;

//delegate methods
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController;

@end
