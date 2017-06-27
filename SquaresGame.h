//
//  SquaresGame.h
//  Sports Squares
//
//  Created by EAGLE on 6/3/15.
//  Copyright (c) 2015 GreenVine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Token.h"
#import "Trivia.h"
#import "TriviaProtocol.h"
#import "LightBulbProtocol.h"
#import "LastNumber.h"

#define FIELD_ROWS    10
#define FIELD_COLUMNS 10
#define SQUARE_COUNT   (FIELD_ROWS * FIELD_COLUMNS)

@interface SquaresGame : NSObject

+ (instancetype)sharedGame; //a singleton
@property (weak) id <TriviaProtocol, LightBulbProtocol> delegate;
@property (nonatomic, assign) BOOL awaySlotsFull;
@property (nonatomic, assign) BOOL homeSlotsFull;
@property (nonatomic, assign) BOOL playClock; //tells the timer it is counting down a response to a trivia question
@property int quarter;
@property (strong, nonatomic) NSString *awayScore;
@property (strong, nonatomic) NSString *homeScore;
@property (strong, nonatomic) NSString *phase; //create, setup, play, etc. 
@property (strong, nonatomic) NSString *mode; //trivia or classic
@property (strong, nonatomic) NSMutableArray *tokens;
@property (strong, nonatomic) NSMutableArray *squares;
@property (strong, nonatomic) NSMutableArray *awayFieldNumbers; //numbers on the field
@property (strong, nonatomic) NSMutableArray *homeFieldNumbers; //numbers on the field
@property (strong, nonatomic) Token *triviaToken; //a random token selected for the trivia question
@property (strong, nonatomic) Token *emptyToken; //this will eventually turn into the computer's tokens if not used
@property (strong, nonatomic) Trivia *triviaQuestion;
@property (strong, nonatomic) NSTimer *scoreboardTimer;
@property int timeRemaining; //in seconds
@property (strong, nonatomic) NSMutableArray *questionsThisQuarter;
@property (strong, nonatomic) NSMutableArray *questionsAsked;

- (void)seedNumbers;
- (void)swapNumbers;
- (void)getTokenPositions;
- (Token *)winningTokenFromAwayScore:(NSString *)away andHomeScore:(NSString *)home;
- (void)triviaSetup;
- (void)tickSecond;

@end
