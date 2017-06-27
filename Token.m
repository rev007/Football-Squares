//
//  Token.m
//  Sports Squares
//
//  Created by EAGLE on 6/3/15.
//  Copyright (c) 2015 GreenVine. All rights reserved.
//

#import "Token.h"

@interface Token ()
- (CAKeyframeAnimation *)wobbleSideways;
- (CAKeyframeAnimation *)wobbleUpAndDown;
@end

@implementation Token

@synthesize tokenIndex, playerName;

- (id)init
{
    self = [super init];
    if (self)
    {
        // Do something.
    }
    return self;
}

#pragma mark - Grab & Release Animation

- (void)pickUp
{
    // Rewrite so it doesn't look exactly like Tiles code.
    self.opacity = 0.6f;
    [self setValue:[NSNumber numberWithFloat:1.25f] forKeyPath:@"transform.scale"];
    
}

- (void)moveCloseToFront
{
    //reset the zPosition to almost the top
    CALayer *superlayer = self.superlayer;
    int z = (int)[superlayer.sublayers count];
//    NSLog(@"sublayers = %i", z);
    [self removeFromSuperlayer];
    [superlayer insertSublayer:self atIndex:(z - 2)];
    
}

- (void)moveToBack
{
    //reset the zPosition to the bottom
    CALayer *superlayer = self.superlayer;
    [self removeFromSuperlayer];
    [superlayer insertSublayer:self atIndex:1]; //still need to be in front of field, wheel and animateLayer... atIndex:3
}

- (void)putDown
{
    //begin a new transaction
//    [CATransaction begin];
//    [CATransaction setCompletionBlock:^{
//        [self moveToBack]; //transform warning if this isn't done last?
//    }];
    self.opacity = 1.0f;
    [self setValue:[NSNumber numberWithFloat:1.0f] forKeyPath:@"transform.scale"];
    
    //commit the transaction
//    [CATransaction commit];
}

#pragma mark - Wobbling Animation

- (void)startWobble
{
    CAAnimation *sidewaysAnimation = [self wobbleSideways];
    [self addAnimation:sidewaysAnimation forKey:@"x"];
    
    CAAnimation *upAndDownAnimation = [self wobbleUpAndDown];
    [self addAnimation:upAndDownAnimation forKey:@"y"];
}

- (void)stopWobble
{
    [self removeAnimationForKey:@"x"];
    [self removeAnimationForKey:@"y"];
}

- (CAKeyframeAnimation *)wobbleSideways
{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    anim.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:-0.05f],
                   [NSNumber numberWithFloat:0.05f],
                   nil];
    anim.duration = 0.09f + ((tokenIndex % 10) * 0.01f);
    anim.autoreverses = YES;
    anim.repeatCount = HUGE_VALF; // Infinity proxy.
    
    return anim;
}
- (CAKeyframeAnimation *)wobbleUpAndDown
{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.y"];
    anim.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:-1.0f],
                   [NSNumber numberWithFloat:1.0f],
                   nil];
    anim.duration = 0.07f + ((tokenIndex % 10) * 0.01f);
    anim.autoreverses = YES;
    anim.repeatCount = HUGE_VALF; // Infinity proxy.
    anim.additive = YES;
    
    return anim;
}

#pragma mark - Collision Animation

- (void)rollAway{}

@end
