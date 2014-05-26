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
#import "WordWrapper.h"
#import "WordWrapper+Additions.h"

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
    NSArray *wordsArray = [self getWordsArray];
    if ([wordsArray count] == 0) {
        string = @"";
    } else {
        for (AbstractWord *word in wordsArray) {
            string = [string stringByAppendingFormat:@" %@",word.keyword];
        }
    }
    return string;
}

- (NSArray *)getWordsArray {
    NSMutableArray *wordsArray = [NSMutableArray arrayWithCapacity:0];
    for (WordWrapper *wrapper in self.wordwrappers) {
        [wordsArray addObject:wrapper.word];
    }
    return wordsArray;
}

- (NSString *)serialise {
    NSArray *wordsArray = [self getWordsArray];
    NSString *serialisedEntry = [NSString stringWithFormat:@"%@,",self.timestamp.description];
    for (AbstractWord *word in wordsArray) {
        serialisedEntry = [serialisedEntry stringByAppendingFormat:@"%@,",word.keyword];
    }
    [serialisedEntry stringByAppendingString:self.comment];
    return serialisedEntry;
}

#pragma mark - Accessor Methods

- (void)addWordsObject:(AbstractWord *)value {
    NSMutableOrderedSet *newSet = [[NSMutableOrderedSet alloc]initWithOrderedSet:self.wordwrappers];
    WordWrapper *wordwrapper = [WordWrapper createNewWordWrapperInEntry:self inContext:self.managedObjectContext];
    wordwrapper.word = value;
    [newSet addObject:wordwrapper];
    self.wordwrappers = [[NSOrderedSet alloc]initWithOrderedSet:newSet];
}

- (void)removeLastObject {
    NSMutableOrderedSet *newSet = [[NSMutableOrderedSet alloc]initWithOrderedSet:self.wordwrappers];
    [newSet removeObjectAtIndex:([newSet count]-1)];
    self.wordwrappers = [[NSOrderedSet alloc]initWithOrderedSet:newSet];
}

- (void)addWords:(NSArray *)values {
    for (AbstractWord *word in values) {
        [self addWordsObject:word];
    }
}

@end
