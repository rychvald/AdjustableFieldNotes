//
//  CommentInputController.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 22.05.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import <UIKit/UIKit.h>

//class used for comment input popover, when adding entries to a recording
@class Entry;

//protocol for releasing selected table view cell (containg last entry) when closing the popover
@protocol CommentInputDelegate <NSObject>

- (void) releaseSelection;

@end

@interface CommentInputController : UIViewController <UIPopoverControllerDelegate>

@property (nonatomic,retain) IBOutlet UITextView *textView;
@property (nonatomic,retain) Entry *currentEntry;
@property (nonatomic,retain) UIPopoverController *popoverVC;
@property (nonatomic,retain) id<CommentInputDelegate> delegate;

- (void)prepareForEditingEntry:(Entry *)entry fromDelegate:(id)myDelegate withPopover:(UIPopoverController *)popover;

//delegate methods
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController;
- (IBAction)clearButtonPressed:(id)sender;
- (IBAction)closeAndSaveButtonPressed:(id)sender;

@end
