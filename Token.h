//
//  Token.h
//  Sports Squares
//
//  Created by EAGLE on 6/3/15.
//  Copyright (c) 2015 GreenVine. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKIt/UIKit.h>

@interface Token : CALayer

@property(nonatomic) int tokenIndex;
@property(strong, nonatomic) NSString *playerName;
@property(strong, nonatomic) NSString *colorName;
@property(strong, nonatomic) NSString *character;
@property(strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *row;
@property (strong, nonatomic) NSString *column;
@property(nonatomic, assign) int imageNumber; //delete
@property(nonatomic, assign) BOOL isLocked; //flag to prevent actions
@property(nonatomic, assign) BOOL isInvalid; //flag to prevent duplicates

- (void)pickUp;
- (void)putDown;
- (void)startWobble;
- (void)stopWobble;
- (void)rollAway;

@end
