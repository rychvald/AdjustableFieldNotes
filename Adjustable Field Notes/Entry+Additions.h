//
//  Entry+Additions.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 29.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "Entry.h"

@class AbstractWord;

@interface Entry (Additions)

+ (Entry *)createNewEntryForRecording:(Recording *)recording inContext:(NSManagedObjectContext *)context;

- (NSString *)asString;
- (NSString *)serialise;
- (void)addWordsObject:(AbstractWord *)value;
- (void)removeLastObject;
- (void)addWords:(NSArray *)values;

@end
