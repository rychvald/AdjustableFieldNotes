//
//  WordWrapper+Additions.m
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 06.05.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "WordWrapper+Additions.h"

@implementation WordWrapper (Additions)

+ createNewWordWrapperInEntry:(Entry *)entry inContext:(NSManagedObjectContext *)context {
    WordWrapper *wordwrapper = (WordWrapper *)[NSEntityDescription insertNewObjectForEntityForName:@"WordWrapper" inManagedObjectContext:context];
    wordwrapper.heldByEntry = entry;
    [context insertObject:wordwrapper];
    [context save:nil];
    return wordwrapper;
}

@end
