//
//  EntryTextField.m
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 06.05.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "EntryTextField.h"
#import "Keyword.h"
#import "Keyword+KeywordAccessors.h"
#import "Entry.h"
#import "Recording.h"
#import "Recording+Additions.h"

@implementation EntryTextField

@synthesize keywords;

- (id)initWithFrame:(CGRect)aRect{
    self = [super initWithFrame:aRect];
    self.keywords = [NSMutableArray arrayWithCapacity:1];
    NSLog(@"Initialised EntryTextField");
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    self.keywords = [NSMutableArray arrayWithCapacity:1];
    NSLog(@"Initialised EntryTextField");
    return self;
}

- (void)addKeyword:(Keyword *)keyword {
    if ([self.keywords count] == 0)
        self.timestamp = [NSDate date];
    [self.keywords addObject:keyword];
    [self reload];
}

- (IBAction)removeLastKeyword:(id)sender {
    if ([self.keywords count] > 0) {
        [self.keywords removeObjectAtIndex:([self.keywords count]-1)];
        [self reload];
    }
}

- (IBAction)removeAllKeywords:(id)sender {
    [self.keywords removeAllObjects];
    [self reload];
}

- (void)reload {
    self.text = @"";
    for (Keyword *word in self.keywords) {
        NSString *nextString = word.keyword;
        if (word.label != nil && ![word.label isEqualToString:@""])
            nextString = word.label;
        self.text = [NSString stringWithFormat:@"%@ %@",self.text,nextString];
    }
    [self reloadInputViews];
}

- (void)commitToRecording:(Recording *)recording {
    if (self.text == nil || [self.text isEqualToString:@""]) {
        return;
    } else {
        [recording addEntryWithTimestamp:self.timestamp keywords:keywords];
    }
}

@end
