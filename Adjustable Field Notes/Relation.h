//
//  Relation.h
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 12.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AbstractWord.h"

@class Keyword;

@interface Relation : AbstractWord

@property (nonatomic, retain) Keyword *parent;

@end
