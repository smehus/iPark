//
//  NSMutableString+AddText.m
//  iPark
//
//  Created by scott mehus on 11/24/12.
//  Copyright (c) 2012 scott mehus. All rights reserved.
//

#import "NSMutableString+AddText.h"

@implementation NSMutableString (AddText)

- (void)addText:(NSString *)text withSeparator:(NSString *)separator {
    
    if (text != nil) {
        if ([self length] > 0) {
            [self appendString:separator];
        }
        [self appendString:text];
    }
}

@end
