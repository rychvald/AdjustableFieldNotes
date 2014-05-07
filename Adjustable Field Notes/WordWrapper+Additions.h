//
//  WordWrapper+Additions.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 06.05.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "WordWrapper.h"

@interface WordWrapper (Additions)

+ createNewWordWrapperInEntry:(Entry *)entry inContext:(NSManagedObjectContext *)context;

@end
