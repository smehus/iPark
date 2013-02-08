//
//  HudView.m
//  iPark
//
//  Created by scott mehus on 11/4/12.
//  Copyright (c) 2012 scott mehus. All rights reserved.
//

#import "HudView.h"

@implementation HudView

@synthesize text;

+ (HudView *)hudInView:(UIView *)view animated:(BOOL)animated
{
    HudView *hudView = [[HudView alloc] initWithFrame:view.bounds];
    hudView.opaque = NO;
    
    [view addSubview:hudView];
    view.userInteractionEnabled = NO;
    

    [hudView showAnimated:animated];
    return hudView;
}

- (void)drawRect:(CGRect)rect {
    
    const CGFloat boxWidth = 150.0f;
    const CGFloat boxHeight = 150.0f;
    
    CGRect boxRect = CGRectMake(
                                roundf(self.bounds.size.width - boxWidth) / 2.0f,
                                roundf(self.bounds.size.height - boxHeight) / 2.0f,
                                boxWidth, boxHeight);
    
    UIBezierPath *roundRect = [UIBezierPath bezierPathWithRoundedRect:boxRect cornerRadius:75.0f];
    [[UIColor colorWithRed:0.0f green:0.4f blue:1.0f alpha:0.6f] setFill];
    [roundRect fill];
    
   
    
    
    [[UIColor whiteColor] set];
    
    UIFont *font = [UIFont boldSystemFontOfSize:24.0f];
    CGSize textSize = [self.text sizeWithFont:font];
    
    CGPoint textPoint = CGPointMake(
                                    self.center.x - roundf(textSize.width / 2.0f),
                                    self.center.y - roundf(textSize.height / 2.0f) + boxHeight / 24.0f);
    
    [self.text drawAtPoint:textPoint withFont:font];
    
}

- (void)showAnimated:(BOOL)animated {
    
    if (animated) {
        self.alpha = 0.0f;
        self.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        self.alpha = 1.0f;
        self.transform = CGAffineTransformIdentity;
        
        [UIView commitAnimations];
    }
}














@end
