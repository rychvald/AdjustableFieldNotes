//
//  Entry+Additions.m
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 29.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "Entry+Additions.h"
#import "Entry.h"
#import "Recording.h"
#import "Recording+Additions.h"
#import "AbstractWord.h"

@implementation Entry (Additions)

#pragma mark - Initialisation Methods

+ (Entry *)createNewEntryForRecording:(Recording *)recording inContext:(NSManagedObjectContext *)context {
    Entry *newEntry = (Entry *)[NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:context];
    newEntry.timestamp = [NSDate date];
    newEntry.recording = recording;
    [context insertObject:newEntry];
    [context save:nil];
    return newEntry;
}

#pragma mark - Helper Methods

- (NSString *)asString {
    NSString *string = @"";
    if ([self.words count] == 0) {
        string = @"";
    } else {
        for (AbstractWord *word in self.words) {
            string = [string stringByAppendingFormat:@" %@",word.keyword];
        }
    }
    return string;
}

#pragma mark - Accessor Methods

- (void)insertObject:(AbstractWord *)value inWordsAtIndex:(NSUInteger)idx {
    NSMutableOrderedSet *newSet = [[NSMutableOrderedSet alloc]initWithOrderedSet:self.words];
    [newSet insertObject:value atIndex:idx];
    self.words = [[NSOrderedSet alloc]initWithOrderedSet:newSet];
}

- (void)removeObjectFromWordsAtIndex:(NSUInteger)idx{
    NSMutableOrderedSet *newSet = [[NSMutableOrderedSet alloc]initWithOrderedSet:self.words];
    [newSet removeObjectAtIndex:idx];
    self.words = [[NSOrderedSet alloc]initWithOrderedSet:newSet];
}

- (void)addWordsObject:(AbstractWord *)value {
    NSMutableOrderedSet *newSet = [[NSMutableOrderedSet alloc]initWithOrderedSet:self.words];
    [newSet addObject:value];
    self.words = [[NSOrderedSet alloc]initWithOrderedSet:newSet];
}

- (void)removeWordsObject:(AbstractWord *)value {
    NSMutableOrderedSet *newSet = [[NSMutableOrderedSet alloc]initWithOrderedSet:self.words];
    [newSet removeObject:value];
    self.words = [[NSOrderedSet alloc]initWithOrderedSet:newSet];
}

- (void)addWords:(NSOrderedSet *)values {
    for (AbstractWord *word in values) {
        [self addWordsObject:word];
    }
}

- (void)removeWords:(NSOrderedSet *)values {
    for (AbstractWord *word in values) {
        [self removeWordsObject:word];
    }
}

@end
