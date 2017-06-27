//
//  ViewController.h
//  Sports Squares
//
//  Created by EAGLE on 6/3/15.
//  Copyright (c) 2015 GreenVine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SquaresGame.h"
#import "TokenWheel.h"
#import "SquaresAudio.h"

@class Token;
@class TokenWheel;

@interface ViewController : UIViewController <WheelProtocol, TriviaProtocol, LightBulbProtocol, UITextFieldDelegate, CAAnimationDelegate> {
//modifiers (@public, @protected, @private) only work for compiling... runtime is a different story
@private
    CGRect  squareFrames[SQUARE_COUNT]; //square area that tokens can move to
    CGRect  sidelineFrames[FIELD_COLUMNS]; //areas to put away number views
    CGRect  endzoneFrames[FIELD_ROWS]; //areas to put home number views
    CGRect  grassFrames[SQUARE_COUNT]; //rectangular area between yard lines
    Token   *token;
    Token   *heldToken;
    Token   *movedToken; //token that was moved after answering correctly
    TokenWheel *wheel;
    int     closestSquare;
    int     previousClosestSquare; //saved to when closestSquare changes
    int     nextEmptySquare; //next square to fill
    int     closestEmptySquare; //closest empty square to the touch location
    int     activeTokenIndex; //something is about to happen to this token
    
}

@end

