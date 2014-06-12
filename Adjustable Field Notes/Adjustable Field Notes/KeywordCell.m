//
//  KeywordCell.m
//  Adjustable Field Notes
//
//  Created by Marcel Stolz on 24.04.14.
//  Copyright (c) 2014 Marcel Stolz. All rights reserved.
//

#import "KeywordCell.h"
#import "Keyword.h"
#import "Keyword+KeywordAccessors.h"

@implementation KeywordCell

@synthesize label;
@synthesize keyword;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self initMethod];
    return self;
}

- (void) initMethod {
    self.contentView.layer.cornerRadius = 5;
    self.contentView.layer.masksToBounds = YES;
}

- (Keyword *) keyword {
    return self.keyword;
}

- (void) setKeyword:(Keyword *)newKeyword {
    keyword = newKeyword;
    if (newKeyword.label == nil || [newKeyword.label isEqualToString:@""])
        self.label.text= newKeyword.keyword;
    else
        self.label.text = newKeyword.label;
    self.contentView.backgroundColor = newKeyword.parent.color;
}

@end
