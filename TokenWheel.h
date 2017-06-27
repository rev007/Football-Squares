//
//  TokenWheel.h
//  Sports Squares
//
//  Created by EAGLE on 6/4/15.
//  Copyright (c) 2015 GreenVine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WheelProtocol.h"

@interface TokenWheel : UIControl

@property (weak) id <WheelProtocol> delegate;
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIColor *hubColor;
@property(strong, nonatomic) NSString *colorName;
@property CGAffineTransform startTransform;
@property int numberOfPetals;
@property int lengthOfPetal;
@property int widthOfPetal;
@property int petalNumber; // The petal resting at zero radians.
@property int hubRadius;
@property int colorIndex;
-(void)newColor;


// This method is called from the ViewController to initialize everything
- (id)initWithFrame:(CGRect)frame andDelegate:(id)del withPetals:(int)petalsNumber withLength:(int)petalLength withWidth:(int)petalWidth withRadius:(int)centerRadius;

@end
