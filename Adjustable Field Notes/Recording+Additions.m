//
//  Recording+Additions.m
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 25.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "Recording.h"
#import "Recording+Additions.h"

@implementation Recording (Additions)

+ (NSArray *)getRecordingsInContext:(NSManagedObjectContext *)context {
    Recording *recording;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recording"];
    NSArray *array = nil;
    if ([[context executeFetchRequest:request error:nil]count] == 0) {
        recording = [Recording createInitialRecordingInContext:context];
        array = @[recording];
    } else {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:YES];
        [request setSortDescriptors:@[sortDescriptor]];
        array = [context executeFetchRequest:request error:nil];
    }
    
    return array;
}

+ (NSArray *)getInactiveRecordingsForContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recording"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"active == %@",[NSNumber numberWithBool: NO]]];
    NSArray *array = nil;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    array = [context executeFetchRequest:request error:nil];
    
    return array;
}

+ (Recording *)getActiveRecordingForContext:(NSManagedObjectContext *)context {
    Recording *activeRecording = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recording"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"active == %@",[NSNumber numberWithBool: YES]]];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    if ([[context executeFetchRequest:request error:nil]count] == 0) {
        NSLog(@"Creating new initial word set as none seems to exist");
        activeRecording = [Recording createInitialRecordingInContext:context];
    } else {
        NSLog(@"Retrieving active word set");
        activeRecording = [[context executeFetchRequest:request error:nil]objectAtIndex:0];
    }
    return activeRecording;
}

+ (Recording *)createInitialRecordingInContext:(NSManagedObjectContext *)context {
    Recording *recording = (Recording *)[NSEntityDescription insertNewObjectForEntityForName:@"Recording" inManagedObjectContext:context];
    recording.name = @"Initial Recording";
    recording.dateCreated = [NSDate date];
    [recording setIsActive:YES];
    [context insertObject:recording];
    //[context save:nil];
    return recording;
}

+ (Recording *)createRecording:(NSString *)name inContext:(NSManagedObjectContext *)context {
    Recording *recording = (Recording *)[NSEntityDescription insertNewObjectForEntityForName:@"Recording" inManagedObjectContext:context];
    recording.name = name;
    recording.dateCreated = [NSDate date];
    recording.isActive = NO;
    [context insertObject:recording];
    [context save:nil];
    return recording;
}

- (BOOL)hasEntries {
    if ([self.entries count] > 0)
        return YES;
    else
        return NO;
}

- (void)addEntriesObject:(Entry *)value {
    
}

- (void)removeEntriesObject:(Entry *)value {
    
}

- (BOOL)isActive {
    [self willAccessValueForKey:@"active"];
    BOOL myuseGPS = [[self active] boolValue];
    [self didAccessValueForKey:@"active"];
    return myuseGPS;
}

- (void)setIsActive:(BOOL)newValue {
    [self willChangeValueForKey:@"active"];
    if (newValue == YES) {
        for (Recording *recording in [Recording getRecordingsInContext:self.managedObjectContext]) {
            recording.isActive = NO;
        }
    }
    [self setActive:[NSNumber numberWithBool:newValue]];
    [self didChangeValueForKey:@"active"];
}

@end
