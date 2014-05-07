//
//  WordWrapper.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 06.05.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AbstractWord, Entry;

@interface WordWrapper : NSManagedObject

@property (nonatomic, retain) Entry *heldByEntry;
@property (nonatomic, retain) AbstractWord *word;

@end
