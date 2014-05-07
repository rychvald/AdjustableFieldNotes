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
    self.backgroundView.backgroundColor = [UIColor purpleColor];
}

@end
