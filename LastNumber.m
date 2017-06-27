//
//  LastNumber.m
//  Sports Squares
//
//  Created by EAGLE on 5/15/16.
//  Copyright © 2016 GreenVine. All rights reserved.
//

#import "LastNumber.h"

@implementation LastNumber

+ (NSString *)lastNumberOfScore:(NSString *)score {
    
    NSCharacterSet* numberCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSString *lastCharacter;
    unichar aCharacter;
    
    if ([score length] > 0) {
        lastCharacter = [score substringFromIndex:[score length] -1];
        aCharacter = [lastCharacter characterAtIndex:0];
        if (![numberCharSet characterIsMember:aCharacter]) {
            lastCharacter = @"?";
        }
    } else {
        lastCharacter = @"?";
    }
    return lastCharacter;
    
}

@end
