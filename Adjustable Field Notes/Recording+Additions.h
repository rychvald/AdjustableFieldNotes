//
//  Recording+Additions.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 25.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "Recording.h"

@interface Recording (Additions)

+ (NSArray *)getAllRecordingsInContext:(NSManagedObjectContext *)context;
+ (Recording *)createRecordingInContext:(NSManagedObjectContext *)context;

@end
