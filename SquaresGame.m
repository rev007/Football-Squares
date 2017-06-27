//
//  SquaresGame.m
//  Sports Squares
//
//  Created by EAGLE on 6/3/15.
//  Copyright (c) 2015 GreenVine. All rights reserved.
//

#import "SquaresGame.h"

#define RAND_FROM_TO(min, max) (min + arc4random_uniform(max - min + 1))

BOOL seedAwayTeam = YES; //flip flop seeding the away and home numbers
int awayFieldNumbersSeeded = 0;
int homeFieldNumbersSeeded = 0;
int questionBeganInQtr;
double delayInSeconds; //used in conjuction with popTime for timing effects
dispatch_time_t popTime;

@implementation SquaresGame

@synthesize delegate, playClock, homeScore, awayScore;

#pragma mark Initialization

+ (instancetype)sharedGame {
    static SquaresGame *_sharedGame = nil;
    static dispatch_once_t onceToken; //onceToken is a default name. It has nothing to do with Token.h and m.
    dispatch_once(&onceToken, ^{
        _sharedGame = [[self alloc] init];
    });
    return _sharedGame;
}

- (NSMutableArray *) tokens
{
    if (!_tokens) _tokens = [[NSMutableArray alloc] init];
    return _tokens;
}

- (NSMutableArray *) squares
{
    if (!_squares) _squares = [[NSMutableArray alloc] init];
    return _squares;
}

- (NSMutableArray *) awayFieldNumbers
{
    if (!_awayFieldNumbers) {
        _awayFieldNumbers = [[NSMutableArray alloc] initWithCapacity:FIELD_COLUMNS];
        for (int i=0; i < FIELD_COLUMNS; ++i) {
            [_awayFieldNumbers addObject:[NSNull null]];
        }
    }
    return _awayFieldNumbers;
}

- (NSMutableArray *) homeFieldNumbers
{
    if (!_homeFieldNumbers) {
        _homeFieldNumbers = [[NSMutableArray alloc] initWithCapacity:FIELD_ROWS];
        for (int i=0; i < FIELD_ROWS; ++i) {
            [_homeFieldNumbers addObject:[NSNull null]];
        }
    }
    return _homeFieldNumbers;
}

- (NSMutableArray *) questionsThisQuarter
{
    if (!_questionsThisQuarter) {
        _questionsThisQuarter = [[NSMutableArray alloc] initWithCapacity:6];
        for (int i=0; i<6; ++i) {
            [_questionsThisQuarter addObject:[NSNumber numberWithInt:0]];
        }
    }
    
//    [_questionsThisQuarter replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:0]]; //add zero to prevent crash when postponing the first quarter
    
    return _questionsThisQuarter;
}

- (NSMutableArray *) questionsAsked
{
    if (!_questionsAsked) {
        _questionsAsked = [[NSMutableArray alloc] initWithCapacity:6];
        for (int i=0; i<6; i++) {
            [_questionsAsked addObject:[NSNumber numberWithInt:0]];
        }
    }
    return _questionsAsked;
}

#pragma mark Numbers

- (void)seedNumbers {
    
    NSNumber *numberA, *numberB;
    NSMutableArray *teamNumbers;
    int slotA, slotB, notEqualNumbers;
    BOOL sameNumbers;
    BOOL emptySlot;
    
    sameNumbers = YES;
    emptySlot = NO;
    
    [self checkSlotsFull];
    
    if (!(self.awaySlotsFull && self.homeSlotsFull)) {
        if (seedAwayTeam) {
            teamNumbers = self.awayFieldNumbers;
            seedAwayTeam = NO;
        } else {
            teamNumbers = self.homeFieldNumbers;
            seedAwayTeam = YES;
        }
        
        //find a unique random number
        do {
            notEqualNumbers = 0;
            numberA = [NSNumber numberWithInt:RAND_FROM_TO(0, 9)];
            //check if the number has already been used
            for (slotB = 0; slotB < teamNumbers.count; ++slotB) {
                numberB = [teamNumbers objectAtIndex:slotB];
                if (numberA != numberB) {
                    ++notEqualNumbers;
                }
            }
            if (notEqualNumbers == FIELD_ROWS) {
                sameNumbers = NO;
            }
        } while (sameNumbers);
        
        //find an open random slot
        do {
            slotA = RAND_FROM_TO(0, FIELD_ROWS - 1);
            numberB = [teamNumbers objectAtIndex:slotA];
            if (numberB == (id)[NSNull null]) {
                emptySlot = YES;
                break;
            }
        } while (!emptySlot);
        
        //asign the number to the slot
        [teamNumbers replaceObjectAtIndex:slotA withObject:numberA];

    }
    
}

- (void)swapNumbers {
    
    NSNumber *numberA, *numberB, *numberC;
    NSMutableArray *teamNumbers;
    int slotA, slotB;
    BOOL sameSlots;
    
    sameSlots = YES;
    
    if (seedAwayTeam) {
        teamNumbers = self.awayFieldNumbers;
        seedAwayTeam = NO;
    } else {
        teamNumbers = self.homeFieldNumbers;
        seedAwayTeam = YES;
    }
    
    do {
        slotA = RAND_FROM_TO(0, FIELD_ROWS - 1);
        slotB = RAND_FROM_TO(0, FIELD_ROWS - 1);
        if (slotA != slotB) {
            numberA = [teamNumbers objectAtIndex:slotA];
            numberB = [teamNumbers objectAtIndex:slotB];
            
            [teamNumbers replaceObjectAtIndex:slotA withObject:numberB];
            [teamNumbers replaceObjectAtIndex:slotB withObject:numberA];
            
            numberC = numberA;
            numberA = numberB;
            numberB = numberC;
            sameSlots = NO;
        }
    } while (sameSlots);
}

- (void)checkSlotsFull {
    
    self.awaySlotsFull = YES;
    self.homeSlotsFull = YES;
    NSNumber *number;
    
    for (int i=0; i < self.awayFieldNumbers.count; ++i) {
        number = [self.awayFieldNumbers objectAtIndex:i];
        if (number == (id)[NSNull null]) {
            self.awaySlotsFull = NO;
        }
    }
    
    for (int i=0; i < self.homeFieldNumbers.count; ++i) {
        number = [self.homeFieldNumbers objectAtIndex:i];
        if (number == (id)[NSNull null]) {
            self.homeSlotsFull = NO;
        }
    }
}

#pragma mark Tokens

- (Token *)winningTokenFromAwayScore:(NSString *)away andHomeScore:(NSString *)home {
    
    [self getTokenPositions];
    Token *token;
    
    for (int i=0; i < self.squares.count; ++i) {
        token = [self.squares objectAtIndex:i];
        if ([token.column isEqualToString:[LastNumber lastNumberOfScore:away]]) {
            if ([token.row isEqualToString:[LastNumber lastNumberOfScore:home]]) {
                return token;
            }
        }
    }
    return nil;
    
}

- (void)getTokenPositions {
    Token *token;
    for (int i=0; i < self.squares.count; ++i) {
        token = [self.squares objectAtIndex:i];
        int row = i / FIELD_ROWS;
        token.row = [NSString stringWithFormat:@"%@", [self.homeFieldNumbers objectAtIndex:row]];
        int column = i % FIELD_COLUMNS;
        token.column = [NSString stringWithFormat:@"%@", [self.awayFieldNumbers objectAtIndex:column]];
    }    
}

#pragma mark Trivia

- (void)triviaSetup {
    
    if ([self.mode isEqualToString:@"trivia"]) {
        
        //assign a number of questions to ask if the current quarter doesn't have any yet
        if ([self.questionsThisQuarter[self.quarter] intValue] == 0) {
            //pick the max number of questions for the quarter
            [self.questionsThisQuarter replaceObjectAtIndex:self.quarter withObject:[NSNumber numberWithInt:RAND_FROM_TO(1, 3)]];
        }
        
        if ([self.questionsThisQuarter[self.quarter] intValue] - [self.questionsAsked[self.quarter] intValue] > 0) {
            [self.delegate switchLightBulbs]; //turn on light bulbs
            [self triviaCountdown];
        }
    }
    
}

- (void)triviaCountdown {
    
    //assign a random countdown timer for the next question (in seconds)
    if (self.timeRemaining <= 0) {
        int i = RAND_FROM_TO(120, 300) / 60; //120, 300, /60... testing 30, 30, /30
        self.timeRemaining = i * 60 + 1; //60... testing 30
    }
    
    //start the timer
    [self startScoreboardTimer];
    //randomly select a player to ask a question
    if (!playClock) {
        int i = RAND_FROM_TO(0, (int)self.tokens.count - 1);
        self.triviaToken = [self.tokens objectAtIndex:i];
    }
    
}

#pragma mark Time

- (void)startScoreboardTimer {
    
    if (!self.scoreboardTimer) {
        self.scoreboardTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tickSecond) userInfo:nil repeats:YES];
    }
    
}

- (void)tickSecond {
    
    self.timeRemaining--;
    [self.delegate updateScoreboardTimer]; //notify that the time has changed
    
    if (self.timeRemaining <= 0) {
        //stop the timer
        [self.scoreboardTimer invalidate];
        self.scoreboardTimer = nil;
        
        if (!playClock) {
            //time to answer a question
            self.timeRemaining = 40 + 1; //40
            [self startScoreboardTimer];
            playClock = YES;
            questionBeganInQtr = self.quarter;
            NSLog(@"a question was asked in quarter %i", questionBeganInQtr);
            
        } else {
            
            //done with question
            int i;
            
            //if questionsThisQuarter - questionsAsked = 0 then the question wasn't asked here
            //therefore add the questionAsked to the quarter that it was asked in
            
            if ([self.questionsThisQuarter[self.quarter] intValue] - [self.questionsAsked[self.quarter] intValue] <= 0) {
                NSLog(@"you shouldn't add question asked to qtr#%i", self.quarter);
                //add the question asked to the quarter where it was originally asked
                i = [self.questionsAsked[questionBeganInQtr] intValue];
                [self.questionsAsked replaceObjectAtIndex:questionBeganInQtr withObject:[NSNumber numberWithInt:++i]];
            } else {
                i = [self.questionsAsked[self.quarter] intValue];
                [self.questionsAsked replaceObjectAtIndex:self.quarter withObject:[NSNumber numberWithInt:++i]];
            }
            
            NSLog(@"#questions asked qtr#%i = %@", self.quarter, self.questionsAsked[self.quarter]);
            
            //introduce a delay and then turn off a lightbulb
            delayInSeconds = 0.0;
            popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.delegate switchLightBulbs]; //turn off a lightbulb
            });
            playClock = NO;
            
            //introduce a delay and then restart the game clock
            delayInSeconds = 0.0;
            popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                if ([self.questionsThisQuarter[self.quarter] intValue] - [self.questionsAsked[self.quarter] intValue] > 0) {
                    [self triviaCountdown];
                }
            });
        }
    }
    
}

@end
