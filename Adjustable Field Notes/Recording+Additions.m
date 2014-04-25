//
//  Recording+Additions.m
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 25.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "Recording+Additions.h"

@implementation Recording (Additions)

+ (NSArray *)getAllRecordingsInContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    //define which entity type to retrieve
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Recording" inManagedObjectContext:context];
    [request setEntity:entityDescription];
    
    //define sorting by date created
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    return array;
}

+ (Recording *)createRecordingInContext:(NSManagedObjectContext *)context {
    Recording *recording = (Recording *)[NSEntityDescription insertNewObjectForEntityForName:@"Recording" inManagedObjectContext:context];
    recording.dateCreated = [NSDate date];
    [context insertObject:recording];
    return recording;
}

@end
