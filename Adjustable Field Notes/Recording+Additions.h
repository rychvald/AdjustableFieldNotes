//
//  Recording+Additions.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 25.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "Recording.h"

@interface Recording (Additions)

+ (NSArray *)getRecordingsInContext:(NSManagedObjectContext *)context;
+ (NSArray *)getInactiveRecordingsForContext:(NSManagedObjectContext *)context;
+ (Recording *)getActiveRecordingForContext:(NSManagedObjectContext *)context;
+ (Recording *)createInitialRecordingInContext:(NSManagedObjectContext *)context;
+ (Recording *)createRecording:(NSString *)recording inContext:(NSManagedObjectContext *)context;
- (BOOL)hasEntries;
- (void)addEntryWithTimestamp:(NSDate *)timestamp keywords:(NSMutableArray *)keywords;

- (void)addEntriesObject:(Entry *)value;
- (void)removeEntriesObject:(Entry *)value;
- (BOOL)isActive;
- (void)setIsActive:(BOOL)newValue;

@end
