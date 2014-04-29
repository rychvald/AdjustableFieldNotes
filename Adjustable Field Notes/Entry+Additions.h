//
//  Entry+Additions.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 29.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "Entry.h"

@interface Entry (Additions)

+ (Entry *)createNewEntryForRecording:(Recording *)recording inContext:(NSManagedObjectContext *)context;

- (NSString *)asString;
- (void)insertObject:(AbstractWord *)value inWordsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromWordsAtIndex:(NSUInteger)idx;
- (void)addWordsObject:(AbstractWord *)value;
- (void)removeWordsObject:(AbstractWord *)value;
- (void)addWords:(NSOrderedSet *)values;
- (void)removeWords:(NSOrderedSet *)values;

@end
