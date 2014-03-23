//
//  Catgory.h
//  Adjustable Field Notes
//
//  Created by mars on 23.03.14.
//  Copyright (c) 2014 mars. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Category : NSObject

@property NSString* Name;
@property UIColor* color;
@property NSArray* subcategories;
@property NSArray* relations;

@end
