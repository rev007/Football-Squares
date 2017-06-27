//
//  ViewController.m
//  Sports Squares
//
//  Created by EAGLE on 6/3/15.
//  Copyright (c) 2015 GreenVine. All rights reserved.
//

#import "ViewController.h"

#define TOKEN_WIDTH  44.0f
#define TOKEN_HEIGHT TOKEN_WIDTH
#define TOKEN_MARGIN_X 36.0f //width of grass square is 80 points... 80 - TOKEN_WIDTH = 36
#define TOKEN_MARGIN_Y 6.0f //height of grass square is 50 points... 50 - TOKEN_HEIGHT = 6
#define GRASS_WIDTH 74.0f //width of grass rectangle is 80 points
#define GRASS_HEIGHT 50.0f //height of grass rectangle is 50 points
#define GRASS_MARGIN_X 6.0f //width of yard line is 6 points
#define GRASS_MARGIN_Y 0.0f //there is no vertical divider between grass rectangles
#define DEALING_PILE_X 538.0f //x origin of where tokens are dealt
#define DEALING_PILE_Y 74.0f //y origin of where tokens are dealt
#define FIELD_ORIGIN_X 206.0f //x origin of field
#define FIELD_ORIGIN_Y 251.0f //y origin of field
#define TOKEN_ORIGIN_X 220.0f //field begins at point 205.5
#define TOKEN_ORIGIN_Y 254.0f //field begins at point 251
#define FIRST_TOKEN_ROW (TOKEN_ORIGIN_Y + TOKEN_HEIGHT / 2) //determines if a token is on the field
#define RAND_FROM_TO(min, max) (min + arc4random_uniform(max - min + 1))
const int zPosAlmostBack = 5; //z-position very close to the back
const int zPosRest = 100; //z-position for resting tokens between the field and whatever views/layers are closer to the front
const int zPosFootball = 150; //z-position for the tiny winning football
const int zPosGlide = 200; //z-position for gliding above the resting tokens
const int zPosAlmostFront = 299; //z-position very close to the front
const int zPosFront = 400; //z-position to the front

BOOL gameJustStarted; //create some one-time effects if the game has just begun with a valid score
BOOL menuPressed;
BOOL tokenFromPile;
BOOL tokenFromField;
BOOL tokenDragged;
BOOL wheelWasRotated;
BOOL colorChangedByUser; //color changed but no token added to the field - keep that color if the wheel rotates
BOOL skipAnimation; //when false, smooths animation as token begins tracking touches
BOOL firstToken;
BOOL firstSound; //use to synch initial sounds
BOOL allTokensOnField;
BOOL allTokensLocked; //lock 'em all down... note this isn't a property lock
BOOL timerPaused;
BOOL correctGuess;
BOOL quarterChanged;
BOOL scoreChanged; //the score actually changed to a new valid set of numbers (not just a score text field getting touched)
BOOL endNumberChanged; //ending number in a score has changed to a different value
BOOL silentWhistle; //prevent the whistle from sounding
int activeKeyAnimations; //counter for animations that have a key
int targetCount; //generic reusable target value
int tokenMovedDuringQuarter; //lock scores for earlier quarters after a token has moved
NSString *startingRow; //starting row of a token that was just picked up
NSString *startingColumn; //starting column of a token that was just picked up
NSString *endingRow; //ending row of a token that was put down
NSString *endingColumn; //ending column of a token that was put down
NSString *clockTime; //time left on the scoreboard clock
CGRect pile; //where the tokens are stacked
CGRect cashRegister;
UIImageView *tinySelectionFootball; //displays which game mode is playing when the menu button is pressed
UITextField *homeQtrTextField; //any home quarter text field
UITextField *awayQtrTextField; //any away quarter text field

@interface ViewController ()
//everything declared in the class extension is private... no other classes can work with them (unless by mistake)
//methods may not be though... only ivars... you'll have to experiment to see
@property (strong, nonatomic) SquaresGame *game;
@property (strong, nonatomic) SquaresAudio *audioPlayer;
@property (copy, nonatomic) NSArray *characters;
@property (copy, nonatomic) NSArray *characterNames;
@property (strong, nonatomic) NSArray *homeQtrScores;
@property (strong, nonatomic) NSArray *awayQtrScores;
@property (strong, nonatomic) NSMutableArray *sidelineNumbers; //used to hold the views representing away team numbers
@property (strong, nonatomic) NSMutableArray *endzoneNumbers; //used to hold the view representing home team numbers
@property (strong, nonatomic) CALayer *animateLayer; //an animated layer that won't respond to touches
@property (strong, nonatomic) UITouch *heldTokenTouch; //the touch that picked up a token
@property(strong, nonatomic) NSTimer *viewControllerTimer;
@property (strong, nonatomic) UIImageView *tinyWinningFootball; //indicates which square is currently the winning square
@property (weak, nonatomic) IBOutlet UIButton *menu;
@property (weak, nonatomic) IBOutlet UIButton *start;
@property (weak, nonatomic) IBOutlet UITextField *playerNameField;
@property (weak, nonatomic) IBOutlet UITextField *clockNumbers;
@property (weak, nonatomic) IBOutlet UITextField *firstQtr;
@property (weak, nonatomic) IBOutlet UITextField *secondQtr;
@property (weak, nonatomic) IBOutlet UITextField *thirdQtr;
@property (weak, nonatomic) IBOutlet UITextField *fourthQtr;
@property (weak, nonatomic) IBOutlet UITextField *finalQtr;
@property (weak, nonatomic) IBOutlet UITextField *home1stQtrField;
@property (weak, nonatomic) IBOutlet UITextField *home2ndQtrField;
@property (weak, nonatomic) IBOutlet UITextField *home3rdQtrField;
@property (weak, nonatomic) IBOutlet UITextField *home4thQtrField;
@property (weak, nonatomic) IBOutlet UITextField *homeFinalQtrField;
@property (weak, nonatomic) IBOutlet UITextField *away1stQtrField;
@property (weak, nonatomic) IBOutlet UITextField *away2ndQtrField;
@property (weak, nonatomic) IBOutlet UITextField *away3rdQtrField;
@property (weak, nonatomic) IBOutlet UITextField *away4thQtrField;
@property (weak, nonatomic) IBOutlet UITextField *awayFinalQtrField;
@property (weak, nonatomic) IBOutlet UIImageView *pennants;
@property (weak, nonatomic) IBOutlet UIImageView *pennant1stQtrImage;
@property (weak, nonatomic) IBOutlet UIImageView *pennant2ndQtrImage;
@property (weak, nonatomic) IBOutlet UIImageView *pennant3rdQtrImage;
@property (weak, nonatomic) IBOutlet UIImageView *pennant4thQtrImage;
@property (weak, nonatomic) IBOutlet UIImageView *pennantFinalQtrImage;
@property (weak, nonatomic) IBOutlet UITextField *pennant1stQtrName;
@property (weak, nonatomic) IBOutlet UITextField *pennant2ndQtrName;
@property (weak, nonatomic) IBOutlet UITextField *pennant3rdQtrName;
@property (weak, nonatomic) IBOutlet UITextField *pennant4thQtrName;
@property (weak, nonatomic) IBOutlet UITextField *pennantFinalQtrName;
@property (weak, nonatomic) IBOutlet UITextField *pennant1stQtrNote;
@property (weak, nonatomic) IBOutlet UITextField *pennant2ndQtrNote;
@property (weak, nonatomic) IBOutlet UITextField *pennant3rdQtrNote;
@property (weak, nonatomic) IBOutlet UITextField *pennant4thQtrNote;
@property (weak, nonatomic) IBOutlet UITextField *pennantFinalQtrNote;
@property (weak, nonatomic) IBOutlet UIImageView *sideline;
@property (weak, nonatomic) IBOutlet UITextField *triviaInfo;
@property (weak, nonatomic) IBOutlet UIImageView *triviaPlayerImage;
@property (weak, nonatomic) IBOutlet UITextField *triviaPlayerName;
@property (weak, nonatomic) IBOutlet UITextField *triviaQuestion;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
@property (weak, nonatomic) IBOutlet UITextView *backboard;
@property (weak, nonatomic) IBOutlet UIImageView *bulb1;
@property (weak, nonatomic) IBOutlet UIImageView *bulb2;
@property (weak, nonatomic) IBOutlet UIImageView *bulb3;
@property (weak, nonatomic) IBOutlet UITextView *helpView;

@end

@implementation ViewController

@synthesize sidelineNumbers, endzoneNumbers, animateLayer, heldTokenTouch, viewControllerTimer, tinyWinningFootball;

#pragma mark Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    //setup listening for keyboard notifications
    [self registerForKeyboardNotifications];
    
    //update the appearance of the status bar
    [self setNeedsStatusBarAppearanceUpdate];
    
    //assign z-positions
    self.backboard.layer.zPosition = zPosAlmostFront;
    self.triviaQuestion.layer.zPosition = zPosAlmostFront;
    self.button1.layer.zPosition = zPosAlmostFront;
    self.button2.layer.zPosition = zPosAlmostFront;
    self.button3.layer.zPosition = zPosAlmostFront;
    self.helpView.layer.zPosition = zPosAlmostFront;
    self.start.layer.zPosition = zPosFront;
    
    //hide pennants
    self.pennant1stQtrNote.alpha = 0;
    self.pennant2ndQtrNote.alpha = 0;
    self.pennant3rdQtrNote.alpha = 0;
    self.pennant4thQtrNote.alpha = 0;
    self.pennantFinalQtrNote.alpha = 0;
    self.pennants.alpha = 0;
        
    self.game.phase = @"create"; //this game phase means the squares and tokens haven't been created yet
    self.game.mode = @"trivia"; //the default game mode
    self.game.delegate = self; //SquaresGame uses TriviaProtocol and LightBulbProtocol to update things like the timer label on the scoreboard, etc.
    activeTokenIndex = 0;
    
    if ([self.game.phase isEqualToString:@"create"]) {
        
        //add the token wheel to the field
        wheel = [[TokenWheel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 200.0f) andDelegate:self withPetals:10 withLength:80 withWidth:32 withRadius:32];
        wheel.center = CGPointMake(690, 95);
        [self.view addSubview:wheel];
        self.game.emptyToken = [[Token alloc] init];
        self.game.emptyToken.tokenIndex = -1;
        self.game.triviaQuestion = [[Trivia alloc] init];
        [self createSquares];
        [self createNumberViews];
        [self createTokens];
        
        //create the little football that tracks where the winning spot on the field is
        tinyWinningFootball = [[UIImageView alloc] initWithFrame:CGRectMake(543.0f, 463.0f, 74.0f, 50.0f)];
        tinyWinningFootball.image = [UIImage imageNamed:@"football.png"];
        tinyWinningFootball.layer.zPosition = zPosAlmostBack;
        [self.view addSubview:tinyWinningFootball];
        
        //create another football for the menu checkmark
        tinySelectionFootball = [[UIImageView alloc] initWithFrame:CGRectMake(463.0f, 383.0f, 74.0f, 50.0f)];
        tinySelectionFootball.image = [UIImage imageNamed:@"football.png"];
        tinySelectionFootball.alpha = 0;
        [self.view addSubview:tinySelectionFootball];
        
        //initialize sound
        self.audioPlayer = [[SquaresAudio alloc] init];
        
        //this block makes sure your audio session is active even though apple tries to do it for you...
        //you should put this in a method, register for notifications, and reactivate your session if it is interrupted
        NSError *activationError = nil;
        BOOL success = [[AVAudioSession sharedInstance] setActive: YES error:
                        &activationError];
        if (!success) {
            NSLog(@"your audio session didn't work!!!");
            /* handle the error in activationError */ }
        
        self.game.phase = @"setup";
        self.game.quarter = 0; //quarter 0 will have "empty" text in the text field array
        targetCount = 0;
        //disable updating the score
        [self disableScoreButtons];
        [self activateNextToken];

    } else {
        [self recreateTokens];
    }

}

- (SquaresGame *)game
{
    if (!_game) _game = [SquaresGame sharedGame];
    
    return _game;
}

//this is lazy instantiation using the getter... is this necessary?
- (NSArray *)characters
{
    if (!_characters) {
        _characters = @[@"monkey", @"cub", @"goat", @"rhino", @"squirrel",
                        @"gopher", @"chicken", @"bear", @"dinosaur", @"rabbit"];
    }
    
    return _characters;
    
}

//this is lazy instantiation using the getter... is this necessary?
- (NSArray *)characterNames
{
    if (!_characterNames) {
        _characterNames = @[@"Monkey Bob", @"Fanboy", @"Endzone Pete", @"Ref Rhino", @"Boom Boom",
                        @"Scoops", @"Doodle", @"Chainsaw", @"Junior", @"Coach Wynn"];
    }
    
    return _characterNames;
    
}

- (NSArray *)homeQtrScores
{
    //home1stQtrField is in the array twice so i didn't have to deal with trying to match the 0 index to the 1st quarter, etc.
    if (!_homeQtrScores) {
        _homeQtrScores = @[_home1stQtrField, _home1stQtrField, _home2ndQtrField, _home3rdQtrField, _home4thQtrField, _homeFinalQtrField];
    }
    
    return _homeQtrScores;
    
}

- (NSArray *)awayQtrScores
{
    //away1stQtrField is in the array twice so i didn't have to deal with trying to match the 0 index to the 1st quarter, etc.
    if (!_awayQtrScores) {
        _awayQtrScores = @[_away1stQtrField, _away1stQtrField, _away2ndQtrField, _away3rdQtrField, _away4thQtrField, _awayFinalQtrField];
    }
    
    return _awayQtrScores;
    
}

- (void)createSquares {
    
    for (int row = 0; row < FIELD_ROWS; ++row) {
        for (int col = 0; col < FIELD_COLUMNS; ++col) {
            int index = (row * FIELD_COLUMNS) + col;
            
            CGRect squareFrame = CGRectMake(TOKEN_ORIGIN_X + col * (TOKEN_MARGIN_X + TOKEN_WIDTH),
                                            TOKEN_ORIGIN_Y + row * (TOKEN_MARGIN_Y + TOKEN_HEIGHT),
                                            TOKEN_WIDTH, TOKEN_HEIGHT);
            squareFrames[index] = squareFrame;
            
            //create a grass layer representing an empty square
            CGRect grassFrame = CGRectMake(FIELD_ORIGIN_X + col * (GRASS_MARGIN_X + GRASS_WIDTH),
                                            FIELD_ORIGIN_Y + row * (GRASS_MARGIN_Y + GRASS_HEIGHT),
                                            GRASS_WIDTH, GRASS_HEIGHT);
            
            grassFrames[index] = grassFrame;
        }
    }

}

- (void)createNumberViews {
    
    UIImageView *fieldNumberImageView;
    
    sidelineNumbers = [NSMutableArray array];
    endzoneNumbers = [NSMutableArray array];
    
    //away team
    for (int col = 0; col < FIELD_COLUMNS; ++col) {
        fieldNumberImageView = [[UIImageView alloc] init];
        fieldNumberImageView.frame = CGRectMake(FIELD_ORIGIN_X + col * 80.0f, 195.0f, 74.0f, 50.0f);
        fieldNumberImageView.contentMode = UIViewContentModeCenter;
        sidelineNumbers[col] = fieldNumberImageView;
        [self.view addSubview:fieldNumberImageView];
    }
    
    //home team
    for (int row = 0; row < FIELD_ROWS; ++row) {
        fieldNumberImageView = [[UIImageView alloc] init];
        fieldNumberImageView.frame = CGRectMake(129.0f, FIELD_ORIGIN_Y + row * 50.0f, 200.0f - 129.0f, 50.0f);
        fieldNumberImageView.contentMode = UIViewContentModeCenter;
        endzoneNumbers[row] = fieldNumberImageView;
        [self.view addSubview:fieldNumberImageView];
    }
}

- (void)createTokens {
    
    token = [[Token alloc] init];

    pile = CGRectMake(DEALING_PILE_X, DEALING_PILE_Y, TOKEN_WIDTH, TOKEN_HEIGHT); //where the tokens are initially dealt
    
    cashRegister = pile;
    
//    cashRegister = CGRectMake(TOKEN_ORIGIN_X - (TOKEN_MARGIN_X + TOKEN_WIDTH),
//                              TOKEN_ORIGIN_Y - (TOKEN_MARGIN_Y + TOKEN_HEIGHT + 10), //this 10 is just what I chose to make it look good
//                              TOKEN_WIDTH, TOKEN_HEIGHT); //where the tokens are put when removed from the field
    
    animateLayer = [CALayer layer];
    animateLayer.frame = cashRegister;
    animateLayer.hidden = YES;

    for (int index = 0; index < SQUARE_COUNT; ++index) {
        
        self.game.squares[index]=self.game.emptyToken; //each index contains a pointer to the same token object
        self.game.tokens[index] = [[Token alloc] init]; //each index contains a pointer to a different token object
        token = self.game.tokens[index];
        token.tokenIndex = index;
        token.frame = pile; //all tokens start at the pile
        token.hidden = YES; //token is beneath the pile so it can't be touched yet
        token.cornerRadius = 8;
        
        if ([token respondsToSelector:@selector(setContentsScale:)])
        {
            token.contentsScale = [[UIScreen mainScreen] scale];
        }
        [self.view.layer addSublayer:token];
        firstToken = TRUE; //prevents push animation color on the first token
    }
}

- (void)recreateTokens {
    for (int i = 0; i < [self.game.tokens count]; ++i) {
        token = self.game.tokens[i];
        [self.view.layer addSublayer:token]; //add the layer to the view controller's view
        if ([self.game.phase isEqualToString:@"setup"]) {
            if (token.hidden == NO) {
                activeTokenIndex++;
            };
        }
    }
}

#pragma mark Updates

- (void)activateNextToken {
        
    //make the next token in the pile available
    for (int i=0; i < [self.game.tokens count]; ++i) {
        if ([self.game.tokens[i] isHidden]) {
            self.start.alpha = 0.0; //hide the start button
            wheel.alpha = 1.0; //show the wheel
            token = self.game.tokens[i];
            activeTokenIndex = i;
            [self changeCharacter]; //make the token the same character as the wheel
            [self changeColor]; //make the token the same color as the hub
            colorChangedByUser = NO; //next time the wheel spins suggest a color
            [self changeName]; //make the token the same name as the player name field
            token.zPosition = zPosRest;
            if (firstToken) {
                [self changeName];
                firstToken = FALSE;
            }
            [self.game.tokens[i] setHidden:NO];
            token.isLocked = NO;
            break;
        } else if (i == [self.game.tokens count] - 1) {
            allTokensOnField = YES; //the field is full
            wheel.alpha = 0.0; //hide the wheel
            
            if (menuPressed) {
                [self hideMenu];
            }
            
            //display the start button with a short fade in
            [UIView animateWithDuration:0.5 animations:^{
                self.start.alpha = 1.0;}
                             completion:NULL];
            
            self.playerNameField.alpha = 0.0; //hide the player name
            [self moveTokensToBackground]; //move the tokens to the background so trivia buttons aren't blocked
        }
    }
    
}

- (void)hubTouched {
    token = self.game.tokens[activeTokenIndex];
    colorChangedByUser = YES;
    [self changeColor];
    [self changeNameField];
    [self changeName];
    
}

- (void)wheelRotated {
    wheelWasRotated = YES;
    token = self.game.tokens[activeTokenIndex];
    [self changeCharacter];
    [self changeColor];
    [self changeNameField];
    [self changeName];
    
}

- (void)changeColor {
    if (!firstToken) {
        //add a custom action
        CATransition *transition = [CATransition animation];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromLeft;
        token.actions = @{@"backgroundColor": transition};
    }
    
    if (!colorChangedByUser && wheelWasRotated) {
        //suggest a color that suits the character
        int charIndex = wheel.petalNumber;
        wheel.colorIndex = charIndex;
        [wheel newColor];
    }
    
    token.backgroundColor = wheel.hubColor.CGColor;
    token.colorName = wheel.colorName;
    
}

- (void)changeCharacter {
    NSString *character = self.characters[wheel.petalNumber];
    token.image = [UIImage imageNamed:character];
    token.contents = (__bridge id)([token.image CGImage]);
    token.character = character;
}

- (void)changeName {
    token = self.game.tokens[activeTokenIndex];
    token.playerName = self.playerNameField.text;
}

- (void)changeNameField {
    
    //when this method is called the token character and color already match the wheel
    //the name to give to the playerNameField is being determined here
    //the playerNameField will be updated at the very end
    //note that the token name isn't changed here... just the playerNameField
    //you shouldn't rearrange the order of this code because some things have to happen before or after others
    
    Token *namingToken;
    NSString *finalName; //will be passed down through the chain and placed in playerNameField at the end
    NSString *wheelCharacter;
    NSString *wheelName;
    int charIndex = wheel.petalNumber;
    
    namingToken = self.game.tokens[activeTokenIndex];
    finalName = self.playerNameField.text;
    wheelCharacter = self.characters[charIndex];
    wheelName = self.characterNames[charIndex];
    
    namingToken.isInvalid = NO;
    
    if (wheelWasRotated) {
        //is current player text field a default name?
        if ([self defaultName:finalName]) {
            finalName = wheelName;
        }
        
        //is current player text field = "enter name"?
        if ([finalName isEqualToString:@"enter name"]) {
            finalName = wheelName;
        }
        
        //is current player text field a custom name?
        if (![self defaultName:finalName]) {
            //has the custom name already been played?
            if (![self uniqueName:finalName]) {
                finalName = wheelName;
            }
        }
    }
    
    //don't allow player text field name if used on another token that varies in character OR color
    if ([self hasLookWithSameName:namingToken nameToCompare:finalName]) {
        NSLog(@"a different token with same name is already on the field");
        finalName = @"enter name";
    }
    
    //is the token character AND color already on the field?
    NSMutableArray *friendlyCritters = [self findMatchingTokens:namingToken];
    if (friendlyCritters.count > 0) {
        Token *critter = [friendlyCritters objectAtIndex:0];
        finalName = critter.playerName;
    }
    
    if (![self uniqueCharacter:namingToken.character]) {
        NSLog(@"this is not a unique character!");
    }
    
    if (![self uniqueColor:namingToken.colorName]) {
        NSLog(@"this is not a unique color!");
    }
    
    //don't allow a blank name to be used
    if ([finalName isEqualToString:@""]) {
        finalName = @"enter name";
    }
    
    self.playerNameField.text = finalName;
    if ([finalName isEqualToString:@"enter name"]) {
        namingToken.isInvalid = YES;
    }
    wheelWasRotated = NO;
    
}

- (void)updateSquareNumbers {
    
    BOOL squareNumbersFilledIn;
    NSNumber *squareNumber;
    NSString *squareNumberImageName;
    UIImage *squareNumberImage;
    UIImageView *squareNumberImageView;
    CATransition *transition;
    
    //generate numbers
    if (!(self.game.awaySlotsFull && self.game.homeSlotsFull)) {
        [self.game seedNumbers];
        [self tweakTimerCadence];
    } else {
        [self.game swapNumbers];
        [self tweakTimerCadence];
        //wrap up
        if (targetCount == 42) {
            //stop the timer and beep sounds
            [viewControllerTimer invalidate];
            viewControllerTimer = nil;
            //stop the audio player
            [self.audioPlayer halfSecondBeeps];
            [self.audioPlayer singleBeep]; //play a single beep
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateSquareNumbers) userInfo:nil repeats:NO];
        } else if (targetCount > 42) {
            //stop the timer and beep sounds
            [viewControllerTimer invalidate];
            viewControllerTimer = nil;
            //stop the audio player
            [self.audioPlayer singleBeep];
            //enable updating the score
            [self enableScoreButtons];
        }
    }
    
    transition = [CATransition animation];
    transition.type = kCATransitionFade;
    
    squareNumbersFilledIn = YES;
    
    //synch first beep to appearance of first number
    if (firstSound) {
        [self.audioPlayer halfSecondBeeps];
        firstSound = NO;
    }
    
    //update the field
    for (int i = 0; i < FIELD_COLUMNS; ++i) {
        //away team
        squareNumber = self.game.awayFieldNumbers[i];
        squareNumberImageName = [NSString stringWithFormat:@"away%@.png", squareNumber];
        squareNumberImage = [UIImage imageNamed:squareNumberImageName];
        squareNumberImageView = sidelineNumbers[i];
        [squareNumberImageView.layer addAnimation:transition forKey:nil];
        squareNumberImageView.image = squareNumberImage;
        
        if (squareNumberImageView.image == nil) {
            squareNumbersFilledIn = NO;
        }
    }
    
    for (int i = 0; i < FIELD_ROWS; ++i) {
        //home team
        squareNumber = self.game.homeFieldNumbers[i];
        squareNumberImageName = [NSString stringWithFormat:@"home%@.png", squareNumber];
        squareNumberImage = [UIImage imageNamed:squareNumberImageName];
        squareNumberImageView = endzoneNumbers[i];
        [squareNumberImageView.layer addAnimation:transition forKey:nil];
        squareNumberImageView.image = squareNumberImage;
        
        if (squareNumberImageView.image == nil) {
            squareNumbersFilledIn = NO;
        }
    }
}

- (void)tweakTimerCadence {
    
    double timerCadence;
    UIImageView *squareNumberImageView;
    int awayNumbersFilled;
    int homeNumbersFilled;
    int squareNumbersFilled; //lowest count of square numbers filled
    float percentNumbersFilled;
    
    timerCadence = viewControllerTimer.timeInterval;
    awayNumbersFilled = 0;
    homeNumbersFilled = 0;
    squareNumbersFilled = 0;
    
    for (int i = 0; i < FIELD_COLUMNS; ++i) {
        squareNumberImageView = sidelineNumbers[i];
        if (!(squareNumberImageView.image == nil)) {
            awayNumbersFilled++;
        }
    }
    
    for (int i = 0; i < FIELD_ROWS; ++i) {
        squareNumberImageView = endzoneNumbers[i];
        if (!(squareNumberImageView.image == nil)) {
            homeNumbersFilled++;
        }
    }
    
    if (homeNumbersFilled < awayNumbersFilled) {
        squareNumbersFilled = homeNumbersFilled;
    } else {
        squareNumbersFilled = awayNumbersFilled;
    }
    
    percentNumbersFilled = ((float)squareNumbersFilled / (float)FIELD_ROWS) * 100.0;
    NSLog(@"percent filled = %.0f", percentNumbersFilled);
    squareNumbersFilled = percentNumbersFilled / 10;
    
    switch (squareNumbersFilled) {
            
        case 2:
            //increase timer cadence
            if (timerCadence == 0.5) {
                [viewControllerTimer invalidate];
                viewControllerTimer = nil;
                viewControllerTimer = [NSTimer scheduledTimerWithTimeInterval:0.33 target:self selector:@selector(updateSquareNumbers) userInfo:nil repeats:YES];
                //stop the audio player
                [self.audioPlayer halfSecondBeeps];
                //start the audio player
                [self.audioPlayer thirdSecondBeeps];
            }
            break;
            
        case 5:
            //increase timer cadence
            if (timerCadence == 0.33) {
                [viewControllerTimer invalidate];
                viewControllerTimer = nil;
                viewControllerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSquareNumbers) userInfo:nil repeats:YES];
                //stop the audio player
                [self.audioPlayer thirdSecondBeeps];
                //start the audio player
                [self.audioPlayer tenthSecondBeeps];
            }
            break;
            
        case 10:
            ++targetCount;
            
            switch (targetCount) {
                case 35:
                    //increase timer cadence
                    [viewControllerTimer invalidate];
                    viewControllerTimer = nil;
                    viewControllerTimer = [NSTimer scheduledTimerWithTimeInterval:0.33 target:self selector:@selector(updateSquareNumbers) userInfo:nil repeats:YES];
                    //stop the audio player
                    [self.audioPlayer tenthSecondBeeps];
                    //start the audio player
                    [self.audioPlayer thirdSecondBeeps];
                    break;
                    
                case 40:
                    //increase timer cadence
                    [viewControllerTimer invalidate];
                    viewControllerTimer = nil;
                    viewControllerTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateSquareNumbers) userInfo:nil repeats:YES];
                    //stop the audio player
                    [self.audioPlayer thirdSecondBeeps];
                    //start the audio player
                    [self.audioPlayer halfSecondBeeps];
                    break;

                default:
                    break;
            }
            
        default:
            break;
    }
    
}

- (void)showcaseWinners {
    
    for (int scoreboardQuarter=1; scoreboardQuarter<6; ++scoreboardQuarter) {
        if (scoreboardQuarter <= self.game.quarter) {
            homeQtrTextField = self.homeQtrScores[scoreboardQuarter];
            awayQtrTextField = self.awayQtrScores[scoreboardQuarter];
            //showcase winners if a home or away score is enabled
            if ([self.homeQtrScores[scoreboardQuarter] isEnabled] || [self.awayQtrScores[scoreboardQuarter] isEnabled]) {
            
                //get the winning token
                token = [self.game winningTokenFromAwayScore:awayQtrTextField.text andHomeScore:homeQtrTextField.text];
                
                //move the tiny football to the winning token
                if (!(token.position.y < FIRST_TOKEN_ROW)) { //don't move it unless it's actually on the field
                    if (scoreboardQuarter == self.game.quarter) {
                        if (CGPointEqualToPoint(tinyWinningFootball.center, token.position)) {
//                            [self.audioPlayer ringUp];
//                            NSLog(@"equal... register sound");
                        } else {
                            [self.audioPlayer scoreChange];
//                            NSLog(@"not equal... ding!");
                        }
                        
                        [UIView animateWithDuration:0.50 animations:^{
                            tinyWinningFootball.center = token.position;
                        }];
                    }
                }
                
                switch (scoreboardQuarter) {
                    case 1:
                        self.pennant1stQtrImage.image = token.image;
                        self.pennant1stQtrName.text = token.playerName;
                        self.pennant1stQtrNote.alpha = 0;
                        if (token == nil && self.pennants.alpha == 1) {
                            self.pennant1stQtrNote.alpha = 1;
                        }
                        break;
                        
                    case 2:
                        self.pennant2ndQtrImage.image = token.image;
                        self.pennant2ndQtrName.text = token.playerName;
                        self.pennant2ndQtrNote.alpha = 0;
                        if (token == nil && self.pennants.alpha == 1) {
                            self.pennant2ndQtrNote.alpha = 1;
                        }
                        break;
                        
                    case 3:
                        self.pennant3rdQtrImage.image = token.image;
                        self.pennant3rdQtrName.text = token.playerName;
                        self.pennant3rdQtrNote.alpha = 0;
                        if (token == nil && self.pennants.alpha == 1) {
                            self.pennant3rdQtrNote.alpha = 1;
                        }
                        break;
                        
                    case 4:
                        self.pennant4thQtrImage.image = token.image;
                        self.pennant4thQtrName.text = token.playerName;
                        self.pennant4thQtrNote.alpha = 0;
                        if (token == nil && self.pennants.alpha == 1) {
                            self.pennant4thQtrNote.alpha = 1;
                        }
                        break;
                        
                    case 5:
                        self.pennantFinalQtrImage.image = token.image;
                        self.pennantFinalQtrName.text = token.playerName;
                        self.pennantFinalQtrNote.alpha = 0;
                        if (token == nil && self.pennants.alpha == 1) {
//                            if (token == nil && !self.game.playClock) {

                            self.pennantFinalQtrNote.alpha = 1;
                        }
                        break;
                        
                    default:
                        break;
                }
            }
        }
    }
    
}

- (void)removeWinner {
    
        switch (self.game.quarter) {
            case 1:
                self.pennant1stQtrImage.image = nil;
                self.pennant1stQtrName.text = nil;
                if (self.pennants.alpha == 1) {
                    self.pennant1stQtrNote.alpha = 1;
                }
                break;
                
            case 2:
                self.pennant2ndQtrImage.image = nil;
                self.pennant2ndQtrName.text = nil;
                if (self.pennants.alpha == 1) {
                    self.pennant2ndQtrNote.alpha = 1;
                }
                break;
                
            case 3:
                self.pennant3rdQtrImage.image = nil;
                self.pennant3rdQtrName.text = nil;
                if (self.pennants.alpha == 1) {
                    self.pennant3rdQtrNote.alpha = 1;
                }
                break;
                
            case 4:
                self.pennant4thQtrImage.image = nil;
                self.pennant4thQtrName.text = nil;
                if (self.pennants.alpha == 1) {
                    self.pennant4thQtrNote.alpha = 1;
                }
                break;
                
            case 5:
                self.pennantFinalQtrImage.image = nil;
                self.pennantFinalQtrName.text = nil;
                if (self.pennants.alpha == 1) {
                    self.pennantFinalQtrNote.alpha = 1;
                }
                break;
                
            default:
                break;
        }
    
}

//called by TriviaProtocol
- (void)updateScoreboardTimer {
    
    int minutes = self.game.timeRemaining / 60;
    int seconds = self.game.timeRemaining - minutes * 60;
    
    clockTime = [NSString stringWithFormat:@"%2d:%.2d", minutes, seconds];
    
    //when a wrong answer is given the clock shows -0:01... this prevents that from happening
    if (self.game.timeRemaining <= 0) {
        clockTime = @"0:00";
    }
    
    //update the scoreboard clock
    [self.clockNumbers setText:clockTime];
    
    if (self.game.timeRemaining == 0) {
    
        if (!self.game.playClock) {
            [self.menu setUserInteractionEnabled:NO]; //disable the menu button so it can't be pressed
            
            //hide the start button with a short fade out
            [UIView animateWithDuration:1.0 animations:^{
                self.menu.alpha = 0.0;}
                             completion:NULL];

            [self showTrivia];
        } else {
            [self hideTrivia];
            [self.menu setUserInteractionEnabled:YES]; //enable the menu button so it can be pressed
            
            //display the start button with a short fade in
            [UIView animateWithDuration:0.5 animations:^{
                self.menu.alpha = 1.0;}
                             completion:NULL];
        }
        
        //release any held token
        if (heldToken) {
            [self letGoToken];
        }
        
        //lock all of the tokens so you can't apply a touch to them
        allTokensLocked = YES;
        
        //stop tokens wobble
        for (int i = 0; i < SQUARE_COUNT; ++i) {
            token = self.game.squares[i];
            [token stopWobble];
        }
        
        movedToken = nil;
        if (!silentWhistle) {
            [self.audioPlayer whistle];
        }
        [self enableScoreButtons];
    }
    
}

//called by TriviaProtocol
- (void)switchLightBulbs {
    switch ([self.game.questionsThisQuarter[self.game.quarter] intValue] - [self.game.questionsAsked[self.game.quarter] intValue]) {
        case 3:
            self.bulb1.image = [UIImage imageNamed:@"bulbOn.png"];
            self.bulb2.image = [UIImage imageNamed:@"bulbOn.png"];
            self.bulb3.image = [UIImage imageNamed:@"bulbOn.png"];
            break;
        
        case 2:
            self.bulb1.image = [UIImage imageNamed:@"bulbOn.png"];
            self.bulb2.image = [UIImage imageNamed:@"bulbOn.png"];
            self.bulb3.image = [UIImage imageNamed:@"bulbOff.png"];
            break;
            
        case 1:
            self.bulb1.image = [UIImage imageNamed:@"bulbOn.png"];
            self.bulb2.image = [UIImage imageNamed:@"bulbOff.png"];
            self.bulb3.image = [UIImage imageNamed:@"bulbOff.png"];
            break;
            
        default:
            self.bulb1.image = [UIImage imageNamed:@"bulbOff.png"];
            self.bulb2.image = [UIImage imageNamed:@"bulbOff.png"];
            self.bulb3.image = [UIImage imageNamed:@"bulbOff.png"];
            break;
    }
}

#pragma mark Matching

- (BOOL)uniqueName:(NSString *)name {
    
    Token *fieldToken;
    BOOL nameIsUnique = YES;
    
    for (fieldToken in self.game.tokens) {
        if (fieldToken != self.game.tokens[activeTokenIndex]) {
            if ([fieldToken.playerName isEqualToString:name]) {
                nameIsUnique = NO;
            }
        }
    }
    
    return nameIsUnique;
    
}

- (BOOL)uniqueCharacter:(NSString *)character {
    
    Token *fieldToken;
    BOOL characterIsUnique = YES;
    
    for (fieldToken in self.game.tokens) {
        if (fieldToken != self.game.tokens[activeTokenIndex]) {
            if ([fieldToken.character isEqualToString:character]) {
                characterIsUnique = NO;
            }
        }
    }
    
    return characterIsUnique;
    
}

- (BOOL)uniqueColor:(NSString *)color {
    
    Token *fieldToken;
    BOOL colorIsUnique = YES;
    
    for (fieldToken in self.game.tokens) {
        if (fieldToken != self.game.tokens[activeTokenIndex]) {
            if ([fieldToken.colorName isEqualToString:color]) {
                colorIsUnique = NO;
            }
        }
    }
    
    return colorIsUnique;
    
}

- (BOOL)defaultName:(NSString *)name {
    
    //this method returns true if the name passed in matches a default wheel name
    
    BOOL nameIsDefault = NO;
    
    for (NSString *charName in self.characterNames) {
        if ([name isEqualToString:charName]) {
            nameIsDefault = YES;
        }
    }
    
    return nameIsDefault;
}

- (NSMutableArray *)findMatchingTokens:(Token *)lonerToken {
    
    //this method returns an array of tokens that match the character AND color of the token passed in
    
    NSMutableArray *friendTokens = [NSMutableArray array];
    
    for (Token *aToken in self.game.tokens) {
        if (aToken != lonerToken) {
            if ([aToken.character isEqualToString:lonerToken.character] && [aToken.colorName isEqualToString:lonerToken.colorName]) {
                [friendTokens addObject:aToken];
            }
        }
    }
    
    return friendTokens;
    
}

- (BOOL)hasLookWithSameName:(Token *)someToken nameToCompare:(NSString *)someName {
    
    //this method returns true if different tokens (character OR color) have the same name
    
    BOOL lookIsSame = NO;
    
    for (Token *fieldToken in self.game.tokens) {
        if (fieldToken != someToken) {
            if ([fieldToken.playerName isEqualToString:someName]) {
                if ([fieldToken.character isEqualToString:someToken.character] || [fieldToken.colorName isEqualToString:someToken.colorName]) {
                    lookIsSame = YES;
                }
            }
        }
    }
    
    return lookIsSame;
    
}

#pragma mark Scoring

- (void)scoreWasChanged {
    
    int scoreboardQuarter;
    UITextField *oldHomeQtrTextField;
    UITextField *oldAwayQtrTextField;
    
    oldHomeQtrTextField = self.homeQtrScores[self.game.quarter];
    oldAwayQtrTextField = self.awayQtrScores[self.game.quarter];
    scoreboardQuarter = [self latestQuarterWithScore];
    
    if (![homeQtrTextField.text isEqualToString: self.game.homeScore] || ![awayQtrTextField.text isEqualToString:self.game.awayScore]) {
        scoreChanged = YES;
        if (!([[LastNumber lastNumberOfScore:homeQtrTextField.text] isEqualToString:[LastNumber lastNumberOfScore:self.game.homeScore]] &&
            [[LastNumber lastNumberOfScore:awayQtrTextField.text] isEqualToString:[LastNumber lastNumberOfScore:self.game.awayScore]])) {
            NSLog(@"score ends with a different number");
            endNumberChanged = YES;
        }
    }
    
    //manually stop a quarter by deleting the scores
    if (![oldHomeQtrTextField hasText] && ![oldAwayQtrTextField hasText]) {
        [self postponeQuarter:scoreboardQuarter];
            oldHomeQtrTextField = nil;
            oldAwayQtrTextField = nil;
    }
    
    //new quarter
    if (scoreboardQuarter > self.game.quarter) {
        
        //show the quarters in the pennants when the game starts
        if (self.game.quarter == 0 && !gameJustStarted) {
            //display the pennant notes
            self.pennant1stQtrNote.alpha = 1;
            self.pennant2ndQtrNote.alpha = 1;
            self.pennant3rdQtrNote.alpha = 1;
            self.pennant4thQtrNote.alpha = 1;
            self.pennantFinalQtrNote.alpha = 1;
            gameJustStarted = YES;
            
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"My Alert"
                                                                           message:@"This is an alert."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
        
        //write the old game scores to the old quarter on the scoreboard
        if ((self.game.quarter > 0) && (scoreboardQuarter != self.game.quarter)) {
            oldHomeQtrTextField.text = self.game.homeScore;
            oldAwayQtrTextField.text = self.game.awayScore;
        }
        
        self.game.quarter = scoreboardQuarter;
        quarterChanged = YES;
        [self highlightActiveQuarter];
        [self.game triviaSetup];
        [self switchLightBulbs];
        
        //if new quarter doesn't have any questions then...
        
        //why is this being called all the time? why stop trivia if it isn't happening?
        
        //if trivia is cancelled, doesn't the game know that?
        
        //doesn't the game know that a question was asked but was never subtracted from a quarter?
        
        //doesn't the game know the last time a question was asked?
        
        //doesn't the game know which quarter was the one where a question was last asked but never answered?
        
        //it should!!!
        
        
        //you've moved forward to a quarter with no questions
        //if the regular clock is running you need to stop it
        //if the playclock is running you need to stop it AND remove all visible trivia AND add a questionAsked to the appropriate quarter
        if ([self.game.questionsThisQuarter[self.game.quarter] intValue] - [self.game.questionsAsked[self.game.quarter] intValue] <= 0) {
            if (self.game.scoreboardTimer) {
                if (!self.game.playClock) {
                    [self.game.scoreboardTimer invalidate];
                    self.game.scoreboardTimer = nil;
                    
                    //test block
                    self.game.timeRemaining = 0;
                    silentWhistle = YES; //because the player made the clock go to zero and there is no need to give them a signal
                    //you dont want trivia to be asked
                    self.game.playClock = YES;
                    //dont forget to hit the pause marker for updateScoreboardTimer
                    [self updateScoreboardTimer];
                    //now set the play clock boolean to no so that things start off right next time a user makes a change
                    self.game.playClock = NO;
                    
                    
                    
                    
                } else {
                    [self.game.scoreboardTimer invalidate];
                    self.game.scoreboardTimer = nil;
                    self.game.timeRemaining = 0;
                    [self hideTrivia];
                    [self.menu setUserInteractionEnabled:YES]; //enable the menu button so it can be pressed
                    
                    //display the start button with a short fade in
                    [UIView animateWithDuration:0.5 animations:^{
                        self.menu.alpha = 1.0;}
                                     completion:NULL];
                    
                    [self.game tickSecond];


                    
                }
            }
        }
        
    }
    
    //same or new quarter
    if (scoreboardQuarter >= self.game.quarter) {
        
        //update the game with the new scores
        self.game.homeScore = homeQtrTextField.text;
        self.game.awayScore = awayQtrTextField.text;
        
    }
    
    [self addQuestionMarks];
    
    if (scoreChanged && !endNumberChanged) {
        //ring the bell by itself
        NSLog(@"ding!");
//        [self.audioPlayer bell];
//    } else {
//        NSLog(@"both qtr and score changed");
//        [self showcaseWinners];
    }
    
    NSLog(@"(qtrChanged: %@)", quarterChanged? @"YES": @"NO");
    NSLog(@"(scoreChanged: %@)", scoreChanged? @"YES": @"NO");

    [self showcaseWinners];
    [self lockScoreButtons];
    quarterChanged = NO;
    scoreChanged = NO;
    endNumberChanged = NO;
    
}

- (int)latestQuarterWithScore {
    
    for (int latestQuarter=5; latestQuarter>0; --latestQuarter) {
        
        homeQtrTextField = self.homeQtrScores[latestQuarter];
        awayQtrTextField = self.awayQtrScores[latestQuarter];
        
        //figure out the latest quarter with a complete score
        if ([homeQtrTextField hasText] && [awayQtrTextField hasText]) {
            if (![homeQtrTextField.text isEqualToString:@"?"] && ![awayQtrTextField.text isEqualToString:@"?"]) {
                return latestQuarter;
            }
        }
    }
    
    return 0;
    
}

- (void)highlightActiveQuarter {
    
    //return all quarter numbers to their default font size on the scoreboard
    self.firstQtr.font = [UIFont fontWithName:@"CCMadScientist" size:28.0];
    self.secondQtr.font = [UIFont fontWithName:@"CCMadScientist" size:28.0];
    self.thirdQtr.font = [UIFont fontWithName:@"CCMadScientist" size:28.0];
    self.fourthQtr.font = [UIFont fontWithName:@"CCMadScientist" size:28.0];
    self.finalQtr.font = [UIFont fontWithName:@"CCMadScientist" size:28.0];
    
    //enlarge the latest quarter with a complete score on the scoreboard
    switch (self.game.quarter) {
            
        case 1:
            self.firstQtr.font = [UIFont fontWithName:@"CCMadScientist" size:44.0];
            break;
            
        case 2:
            self.secondQtr.font = [UIFont fontWithName:@"CCMadScientist" size:44.0];
            break;
            
        case 3:
            self.thirdQtr.font = [UIFont fontWithName:@"CCMadScientist" size:44.0];
            break;
            
        case 4:
            self.fourthQtr.font = [UIFont fontWithName:@"CCMadScientist" size:44.0];
            break;
            
        case 5:
            self.finalQtr.font = [UIFont fontWithName:@"CCMadScientist" size:44.0];
            break;
            
        default:
            break;
            
    }
    
}

- (void)addQuestionMarks {
    
    //add "?" if a quarter is missing a score
    
    for (int scoreboardQuarter=5; scoreboardQuarter>0; --scoreboardQuarter) {
        
        homeQtrTextField = self.homeQtrScores[scoreboardQuarter];
        awayQtrTextField = self.awayQtrScores[scoreboardQuarter];
        
        if (![homeQtrTextField.text isEqualToString:@"x"]) { //don't replace locked quarter symbols
            if (![homeQtrTextField hasText] && [awayQtrTextField hasText]) {
                homeQtrTextField.text = @"?";
            }
            if (![awayQtrTextField hasText] && [homeQtrTextField hasText]) {
                awayQtrTextField.text = @"?";
            }
            if ((![homeQtrTextField hasText] && ![awayQtrTextField hasText]) && (scoreboardQuarter < self.game.quarter)) {
                homeQtrTextField.text = @"?";
                awayQtrTextField.text = @"?";
            }
        }
    }
    
}

- (void)postponeQuarter:(int)scoreboardQuarter {
    
    if (tokenMovedDuringQuarter == self.game.quarter) {
//        NSLog(@"sorry pal, you can't stop this quarter... a token was already moved");
    } else {
//        NSLog(@"this quarter has been postponed!");
        silentWhistle = YES;
        if ([self.game.questionsThisQuarter[scoreboardQuarter] intValue] - [self.game.questionsAsked[scoreboardQuarter] intValue] == 0) {
//            NSLog(@"stop the clock and trivia!!!");
            //stop the timer
            [self.game.scoreboardTimer invalidate];
            self.game.scoreboardTimer = nil;
            self.game.timeRemaining = 0;
            
            if (self.game.playClock) {
                //remove a question because it was displayed and now you're moving to a quarter with no questions left
                int i = [self.game.questionsAsked[self.game.quarter] intValue];
                [self.game.questionsAsked replaceObjectAtIndex:self.game.quarter withObject:[NSNumber numberWithInt:++i]];
            }
            
            self.game.playClock = YES; //so updateScoreboardTimer will hide trivia if it's shown
            [self updateScoreboardTimer];
            self.game.playClock = NO; //so SquaresGame is ready to count down to a new question
            self.bulb1.image = [UIImage imageNamed:@"bulbOff.png"];
            self.bulb2.image = [UIImage imageNamed:@"bulbOff.png"];
            self.bulb3.image = [UIImage imageNamed:@"bulbOff.png"];
        } else {
//            NSLog(@"keep the clocks rolling");
        }
        //remove character picture and name
        [self removeWinner];
        self.game.quarter = 0;
        [self enableScoreButtons];
        silentWhistle = NO;
    }
    
}

- (void)enableScoreButtons {
    for (int i=1; i<6; ++i) {
            [self.homeQtrScores[i] setEnabled:YES];
//            [self.homeQtrScores[i] setBackgroundColor:[UIColor whiteColor]];
            [self.awayQtrScores[i] setEnabled:YES];
//            [self.awayQtrScores[i] setBackgroundColor:[UIColor whiteColor]];
    }
    [self lockScoreButtons];
}

- (void)disableScoreButtons {
    for (int i=1; i<6; ++i) {
            [self.homeQtrScores[i] setEnabled:NO];
//            [self.homeQtrScores[i] setBackgroundColor:[UIColor yellowColor]];
            [self.awayQtrScores[i] setEnabled:NO];
//            [self.awayQtrScores[i] setBackgroundColor:[UIColor yellowColor]];
    }
    [self lockScoreButtons];
}

- (void)lockScoreButtons {
    
    UITextField *qtrTextFieldHome;
    UITextField *qtrTextFieldAway;

    //lock score buttons that are before the current quarter
    if ([self.game.mode isEqualToString:@"trivia"]) {
        for (int i=1; i<6; ++i) {
            qtrTextFieldHome = self.homeQtrScores[i];
            qtrTextFieldAway = self.awayQtrScores[i];
            if (i == self.game.quarter) {
                [self.homeQtrScores[i] setEnabled:YES];
//                [self.homeQtrScores[i] setBackgroundColor:[UIColor greenColor]];
                [self.awayQtrScores[i] setEnabled:YES];
//                [self.awayQtrScores[i] setBackgroundColor:[UIColor greenColor]];
            }
            if (i < self.game.quarter) {
                //if neither home or away has a ? then make them both magenta
                if (!([qtrTextFieldHome.text isEqualToString:@"?"] || [qtrTextFieldAway.text isEqualToString:@"?"])) {
                    //do something
                    [self.homeQtrScores[i] setEnabled:NO];
//                    [self.homeQtrScores[i] setBackgroundColor:[UIColor magentaColor]];
                    [self.awayQtrScores[i] setEnabled:NO];
//                    [self.awayQtrScores[i] setBackgroundColor:[UIColor magentaColor]];
                }
            }
            //can't go back once a token is moved
            if (i < tokenMovedDuringQuarter) {
                [self.homeQtrScores[i] setEnabled:NO];
//                [self.homeQtrScores[i] setBackgroundColor:[UIColor redColor]];
                if (![qtrTextFieldHome hasText] || [qtrTextFieldHome.text isEqualToString:@"?"]) {
                    qtrTextFieldHome.text = @"x";
                }
                [self.awayQtrScores[i] setEnabled:NO];
//                [self.awayQtrScores[i] setBackgroundColor:[UIColor redColor]];
                if (![qtrTextFieldAway hasText] || [qtrTextFieldAway.text isEqualToString:@"?"]) {
                    qtrTextFieldAway.text = @"x";
                }
            }
        }
    }
}

#pragma mark Touches Began

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"a touch began");
    
    if (!heldToken) {
        
        UITouch *touch = [touches anyObject];
        
        //get touch position relative to main view
        CGPoint point = [touch locationInView:self.view];
        
        //get touched layer
        CALayer *hitLayer = [self layerForTouch:touch]; //note that layerForTouch won't return anything if the token is locked!
        
        //get layer kind using hitTest (if token isn't locked!)
        if ([hitLayer isKindOfClass:[Token class]]) {
            token = (Token*)hitLayer; //cast to a token class
            //check if token is currently locked
            if (token.isLocked || allTokensLocked) {
                //don't allow interaction
                if (token.isLocked && !allTokensLocked) {
                    NSLog(@"token is locked!");
                } else if (!token.isLocked && allTokensLocked) {
                    NSLog(@"all tokens are locked");
                } else {
                    NSLog(@"individual token is locked AND all tokens are locked");
                }
            } else if (token.isInvalid) {
                //do something
                NSLog(@"you can't move this token because it is invalid");
            } else {
                //allow interaction
                NSLog(@"token is not locked or invalid");
                //track the touch that picked up the token
                heldTokenTouch = touch;
                [self tokenTouchBegan: token];
            }
            
        } else {
            
            //move next token to empty square (grass was touched)
            token = self.game.tokens[activeTokenIndex];
            
            if ([self.game.phase isEqualToString:@"setup"] && !(allTokensLocked || token.isInvalid)) {
                
                NSLog(token.isInvalid ? @"invalid grass token" : @"good grass token");
                for (int index = 0; index < SQUARE_COUNT; ++index) {
                    if (CGRectContainsPoint(grassFrames[index], point) && self.game.squares[index] == self.game.emptyToken) {
                        token = self.game.tokens[activeTokenIndex];
                        //name the token
                        [self changeName];
                        int x = token.tokenIndex;
                        NSLog(@"token index = %i", x);
                        token.zPosition = zPosGlide;
//                        [token moveToFront];
//                        if (menuPressed) {
//                            token.zPosition = zPosAlmostFront;
//                        } else {
//                            token.zPosition = zPosFront;
//                        }
                        [CATransaction begin];
                        [CATransaction setCompletionBlock:^{
                            //point to the correct token again
                            token = [self.game.tokens objectAtIndex:x];
                            //allow interaction
                            token.isLocked = NO;
//                            [token moveToBack];
//                            token.zPosition = zPosRest;
                        }];
                        [CATransaction setAnimationDuration:0.25]; //normally 0.25
                        token.isLocked = YES;
                        token.frame = squareFrames[index];
                        [CATransaction commit];
                        self.game.squares[index] = token;
                        [self activateNextToken];
                    }
                }
            }
        }
    }
    
}

- (CALayer *)layerForTouch:(UITouch *)touch {
    
    UIView *view = self.view;
    
    CGPoint location = [touch locationInView:view];
    location = [view convertPoint:location toView:nil];
    
    for (int i = 0; i < [self.game.tokens count]; ++i) {
        token = self.game.tokens[i];
        
        //note that if the token is locked then the hitLayer won't know what class it is
        if (CGRectContainsPoint(token.frame, location) && !token.isLocked) {
            return token.modelLayer;
        }
    }
    
    return nil;
    
}

- (void)tokenTouchBegan:(Token *)hitLayer {
    
    heldToken = hitLayer;
    
    NSLog(@"name = %@", heldToken.playerName);
    NSLog(@"color = %@", heldToken.colorName);
    NSLog(@"character = %@", heldToken.character);
    NSLog(@"token index = %i", heldToken.tokenIndex);
    NSLog(token.isInvalid ? @"invalid token" : @"good token");
//    NSLog(@"z-position = %f", heldToken.zPosition);

    //lock all other tokens if player just answered a trivia question correctly
    if (correctGuess) {
        [self lockAllOtherTokens];
        [self hideTrivia];
    }
    
    closestSquare = [self squareIndexForToken:heldToken.tokenIndex];
    previousClosestSquare = closestSquare;
    if (heldToken.position.y >= FIRST_TOKEN_ROW) {
        tokenFromField = YES;
        //remove held token from square and replace with empty token
        self.game.squares[closestSquare] = self.game.emptyToken;
    } else if ([NSStringFromCGRect(heldToken.frame) isEqualToString:NSStringFromCGRect(pile)]) {
        tokenFromPile = YES;
    }
    [self findNextEmptySquare];
//    if (menuPressed) {
//        heldToken.zPosition = zPosAlmostFront;
//    } else {
//        heldToken.zPosition = zPosFront;
//    }
//    [heldToken moveToFront];
    heldToken.zPosition = zPosAlmostFront;
    [heldToken pickUp];
    skipAnimation = FALSE; //smooth the starting animation of the token
    if ([self.game.phase isEqualToString:@"play"]) {
        [self.game getTokenPositions];
        //save the starting row and column so you can see if it was moved to a new spot when let go
        startingRow = heldToken.row;
        startingColumn = heldToken.column;
        [self startTokensWiggling];
    }
}

- (void)findNextEmptySquare {
    for (int index = 0; index < SQUARE_COUNT; ++index) {
        token = self.game.squares[index];
        if (token == self.game.emptyToken) {
            nextEmptySquare = index;
            break;
        }
    }
}

- (int)squareIndexForToken:(int)heldTokenIndex {
    for (int index = 0; index < SQUARE_COUNT; ++index) {
        if ([self.game.squares[index] tokenIndex] == heldTokenIndex) {
            return index;
        }
    }
    return 0;
}

#pragma mark Touches Moved

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (heldToken) {
        
        heldToken.zPosition = zPosFront;
        
        UIView *view = self.view;
        CGPoint location;
        location = [heldTokenTouch locationInView:view];
        
        [self moveHeldTokenToTouch:location];
        [self moveUnheldTokensAwayFromPoint:location];
        closestEmptySquare = [self indexOfClosestEmptySquareToPoint:location];
        tokenDragged = YES;
        
    }
}

- (void)moveHeldTokenToTouch:(CGPoint)location {
    
    [CATransaction begin];
    [CATransaction setDisableActions:skipAnimation]; //disable implicit animations for this transaction
    heldToken.position = location;
    [CATransaction commit];
    skipAnimation = TRUE; //makes tracking fast (no lag)
}

- (void)moveUnheldTokensAwayFromPoint:(CGPoint)location {
    
    if ([self.game.phase isEqualToString:@"play"]) {
        
        closestSquare = [self indexOfClosestSquareToPoint:location];
        
        //don't move other tokens until closestSquare changes
        if (closestSquare != previousClosestSquare) {
            
            if (closestSquare < previousClosestSquare) {
                for (int i = previousClosestSquare; i > closestSquare; --i) {
                    [self moveToken:i neighbor:-1];
                }
            }
            else if (previousClosestSquare < closestSquare) {
                for (int i = previousClosestSquare; i < closestSquare; ++i) {
                    [self moveToken:i neighbor:+1];
                }
            }
            
            previousClosestSquare = closestSquare;
            self.game.squares[previousClosestSquare] = self.game.emptyToken;

        }
    }
}

- (void)moveToken:(int) i neighbor:(int)offset {
    
    Token *unheldToken = self.game.squares[i+offset];
    
    unheldToken.zPosition = zPosAlmostFront;
//    [unheldToken moveCloseToFront];
    
    float travelTime = RAND_FROM_TO(1, 3);
    int twists = RAND_FROM_TO(1, 3);
    int twistDirection = RAND_FROM_TO(-1, 1);
    
    //create an animation to rotate a token
    CABasicAnimation *rotateToken = [CABasicAnimation animation];
    rotateToken.keyPath = @"transform.rotation";
    rotateToken.repeatCount = twists;
    if (twists > 0) {rotateToken.duration = travelTime / twists;}
    else {rotateToken.duration = travelTime;}
    if (!(twistDirection == 0)) {rotateToken.byValue = @(M_PI * 2 * twistDirection);}
    [unheldToken addAnimation:rotateToken forKey:nil];
    
    //create a path
    UIBezierPath *path = [self createPath:unheldToken.modelLayer toSquare:squareFrames[i]];
    
    //create the keyframe animation to move a token
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position";
    animation.duration = travelTime;
    animation.path = path.CGPath;
    animation.delegate = self;
    
    //manage keypath animations
    NSString *strKey = [unheldToken.animationKeys objectAtIndex:0];
    activeKeyAnimations++;
    
    if ([strKey isEqual:@"bezier1"]) {
        [unheldToken addAnimation:animation forKey:@"bezier2"];
        [unheldToken removeAnimationForKey:strKey];
        
    } else if ([strKey  isEqual: @"bezier2"]) {
        [unheldToken addAnimation:animation forKey:@"bezier1"];
        [unheldToken removeAnimationForKey:strKey];
        
    } else {
        [unheldToken addAnimation:animation forKey:@"bezier1"];
    }
    
    //begin a new transaction
    [CATransaction begin];
    [CATransaction setDisableActions:YES]; //disable implicit animations for this transaction
    unheldToken.frame = squareFrames[i];
    self.game.squares[i] = unheldToken;
    [CATransaction commit];

}

- (int)indexOfClosestSquareToPoint:(CGPoint)point {
    int index = 0;
    float minDist = FLT_MAX;
    for (int i = 0; i < SQUARE_COUNT; ++i) {
        CGRect squareFrame = squareFrames[i];
        
        float dx = point.x - CGRectGetMidX(squareFrame);
        float dy = point.y - CGRectGetMidY(squareFrame);
        
        float dist = (dx * dx) + (dy * dy);
        if (dist < minDist) {
            index = i;
            minDist = dist;
        }
    }
    return index;
}

- (int)indexOfClosestEmptySquareToPoint:(CGPoint)point {
    int index = 0;
    float minDist = FLT_MAX;
    for (int i = 0; i < SQUARE_COUNT; ++i) {
        CGRect squareFrame = squareFrames[i];
        
        float dx = point.x - CGRectGetMidX(squareFrame);
        float dy = point.y - CGRectGetMidY(squareFrame);
        
        float dist = (dx * dx) + (dy * dy);
        if (dist < minDist && self.game.squares[i] == self.game.emptyToken) {
            index = i;
            minDist = dist;
        }
    }
    return index;
}

- (UIBezierPath *)createPath:(Token *)moveToken toSquare:(CGRect)square {
    
    CGPoint startPoint = [(Token *)moveToken.presentationLayer position]; //casting token to avoid position confusion with AVFoundation
    CGPoint squarePoint = CGPointMake(square.origin.x + square.size.width / 2,
                                      square.origin.y + square.size.height / 2);
    
    UIBezierPath *tokenPath = [[UIBezierPath alloc] init];
    
    //decide path style (straight or curved)
    int i =RAND_FROM_TO(1, 10);
    
    if (i > 3) {
        
        //randomize some numbers
        int randomX1, randomX2, randomY1, randomY2;
        
        randomX1 = RAND_FROM_TO(182, 1024);
        randomX2 = RAND_FROM_TO(182, 1024);
        randomY1 = RAND_FROM_TO(224, 768);
        randomY2 = RAND_FROM_TO(224, 768);
        
        //create a curved path
        [tokenPath moveToPoint:startPoint];
        [tokenPath addCurveToPoint:squarePoint
                     controlPoint1:CGPointMake(randomX1, randomY1)
                     controlPoint2:CGPointMake(randomX2, randomY2)];
        
    } else {
        
        //create a straight path
        [tokenPath moveToPoint:startPoint];
        [tokenPath addLineToPoint:squarePoint];
        
    }
    
    return tokenPath;
    
}

#pragma mark Touches Ended

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (heldToken) {
        for (UITouch *touch in touches) {
            if (touch == heldTokenTouch) {
                [self letGoToken];
                break;
            }
        }
    }
}

- (void)letGoToken {
    
    if ([self.game.phase isEqualToString:@"play"]) {
        heldToken.frame = squareFrames[closestSquare];
        self.game.squares[closestSquare] = heldToken;
        [heldToken putDown];
        heldToken.zPosition = zPosRest;
//        [heldToken moveToBack];
        if (activeKeyAnimations == 0) {
            [self stopTokensWiggling];
        }
        //show the current winner of the current quarter
        [self showcaseWinners];
        
    } else if ([self.game.phase isEqualToString:@"setup"]) {
        //prevent naming a token and not hitting return on the keyboard exploit
        //is the token character AND color already on the field?
        NSMutableArray *friendlyCritters = [self findMatchingTokens:heldToken];
        if (friendlyCritters.count > 0) {
            Token *critter = [friendlyCritters objectAtIndex:0];
            heldToken.playerName = critter.playerName;
        }

        if (tokenDragged) {
            //token dragged from field to top section
            if (tokenFromField && heldToken.position.y < FIRST_TOKEN_ROW) {
                [heldToken putDown];
//                heldToken.zPosition = zPosAlmostFront;
//                [heldToken moveToBack];
                heldToken.isLocked = YES;
                [self removeToken:heldToken];
            //token dragged from anywhere and put down in the area of the field
            } else {
                self.game.squares[closestEmptySquare] = heldToken;
                int x = heldToken.tokenIndex; //you need to point to the token again in the completion block
                [heldToken putDown];
                heldToken.zPosition = zPosGlide;
                [CATransaction begin];
                [CATransaction setCompletionBlock:^{
                    token = [self.game.tokens objectAtIndex:x]; //point to the correct token again
                    token.isLocked = NO; //allow interaction
                    token.zPosition = zPosRest;
//                    [token moveToBack]; //move to back so other moving tokens are in front
                }];
                [CATransaction setAnimationDuration:0.25]; //normally 0.25
                heldToken.isLocked = YES;
                heldToken.frame = squareFrames[closestEmptySquare];
                [CATransaction commit];
                
            }
        } else {
            //token was tapped
            if (tokenFromField) {
                [heldToken putDown];
                heldToken.isLocked = YES;
                [self removeToken:heldToken];
            } else {
                self.game.squares[nextEmptySquare] = heldToken;
                int x = heldToken.tokenIndex;
                heldToken.zPosition = zPosGlide;
                [heldToken putDown];
                [CATransaction begin];
                [CATransaction setCompletionBlock:^{
                    //point to the correct token again
                    token = [self.game.tokens objectAtIndex:x];
                    //allow interaction
                    token.isLocked = NO;
                    //move to back so other moving tokens are in front
//                    token.zPosition = zPosRest;
                }];
                [CATransaction setAnimationDuration:0.25]; //normally 0.25
                heldToken.isLocked = YES;
                heldToken.frame = squareFrames[nextEmptySquare];
                NSLog(@"z-position = %f", heldToken.zPosition);
                [CATransaction commit];
            }
        }
        if (tokenFromPile) {
            [self activateNextToken];
//            [self.audioPlayer ringUp];
        }
    }
    //update the token row and column properties
    [self.game getTokenPositions];
    endingRow = heldToken.row;
    endingColumn = heldToken.column;
    if ([self.game.phase isEqualToString:@"play"]) {
        //see if the token was actually moved
        if (![startingRow isEqualToString:endingRow] || ![startingColumn isEqualToString:endingColumn]) {
            tokenMovedDuringQuarter = self.game.quarter;
            //prior quarters need to be permanently locked
            [self lockScoreButtons];
        }
    }
    
    //last moved token = held token
    heldToken = nil;
    tokenDragged = NO;
    tokenFromField = NO;
    tokenFromPile = NO;

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

#pragma mark Token Animation

- (void)startTokensWiggling {
    
    //turn on line shift audio if no tracked animations are underway
    if (activeKeyAnimations == 0) {
        [self.audioPlayer lineShift];
    }
    
    for (int i = 0; i < SQUARE_COUNT; ++i) {
        token = self.game.squares[i];
        if (token != heldToken) {
            [token startWobble];
        }
    }
}

- (void)stopTokensWiggling {
    
    //turn off line shift audio
    [self.audioPlayer lineShift];
    
    for (int i = 0; i < SQUARE_COUNT; ++i) {
        token = self.game.squares[i];
        if (!(token == movedToken)) {
            [token stopWobble];
        }
    }
}

- (void)removeToken:(Token *)droppedToken {
    
    //strip the property settings of the token that is being removed
    droppedToken.playerName = @"";
    droppedToken.colorName = @"";
    droppedToken.character = @"";
    
    //remove any previous animateLayer and place it back on top
    [animateLayer removeFromSuperlayer];
    [self.view.layer addSublayer:animateLayer];
    animateLayer.position = droppedToken.position;
    animateLayer.backgroundColor = droppedToken.backgroundColor;
    animateLayer.contents = droppedToken.contents;
    animateLayer.cornerRadius = droppedToken.cornerRadius;
    animateLayer.zPosition = zPosGlide;
//    if (menuPressed) {
//        animateLayer.zPosition = zPosAlmostFront;
//    } else {
//        animateLayer.zPosition = zPosFront;
//    }
//    animateLayer.zPosition = MAXFLOAT;
    animateLayer.hidden = NO;
    
    //begin a new transaction
    [CATransaction begin];
    [CATransaction setDisableActions:YES]; //disable implicit animations for this transaction
    droppedToken.hidden = YES;
    droppedToken.frame = pile;
    //commit the transaction
    [CATransaction commit];
    
    //create a path
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:animateLayer.position];
    CGPoint registerPoint = CGPointMake(cashRegister.origin.x + cashRegister.size.width / 2,
                                        cashRegister.origin.y + cashRegister.size.height / 2);
    [linePath addLineToPoint:registerPoint];
    
    //begin a new transaction
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        //fade token after remove
        [CATransaction setAnimationDuration:1.0]; //default is 0.25 seconds
        animateLayer.hidden = YES;
    }];
    
    //create the keyframe animation to remove a token
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position";
    animation.duration = 0.25; //normally 0.25
    animation.path = linePath.CGPath;
    animateLayer.position = registerPoint; //ending position after the animation
    [animateLayer addAnimation:animation forKey:nil];
    
    //commit the transaction
    [CATransaction commit];
    
    if (allTokensOnField) {
        allTokensOnField = false;
        self.playerNameField.alpha = 1;
        [self activateNextToken];
    }
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    activeKeyAnimations--;

    //log that the animation stopped
//    NSLog(@"The animation stopped (finished: %@)", flag? @"YES": @"NO");
    if (flag) {
        [self moveTokensToBackground];
    }
    if (!heldToken && activeKeyAnimations == 0) {
        [self stopTokensWiggling];
    }
}

- (void)moveTokensToBackground {
    
    for (token in self.game.tokens) {
        if (token == heldToken) {
        }
        if (token.animationKeys.count <= 2) {
            if (token != heldToken) {
                token.zPosition = zPosRest;
//                [token moveToBack];
            }
        }
    }
}

#pragma mark Trivia

- (void)showTrivia {
    
    NSString *answer1, *answer2, *answer3;
    
    correctGuess = NO;
    
    self.triviaInfo.text = @"This trivia question is for...";
    
    //dismiss the keyboard so trivia can be seen
    [self.view endEditing:YES];
    
    //disable updating the score while trivia is being asked
    [self disableScoreButtons];
    
    //set the name and image of the player selected to answer the trivia question
    token = self.game.triviaToken;
    self.triviaPlayerName.text = token.playerName;
    self.triviaPlayerImage.image = token.image;
    UIColor *tokenColor = [UIColor colorWithCGColor:token.backgroundColor];
    self.triviaPlayerImage.backgroundColor = tokenColor;
    
    //retrieve a question
    [self.game.triviaQuestion randomQuestion];
    self.triviaQuestion.text = self.game.triviaQuestion.question;
    
    //randomize what each button label gets
    int a = RAND_FROM_TO(1, 3);
    switch (a) {
        case 1:
            answer1 = self.game.triviaQuestion.correctAnswer;
            break;
            
        case 2:
            answer1 = self.game.triviaQuestion.wrongAnswer1;
            break;
            
        case 3:
            answer1 = self.game.triviaQuestion.wrongAnswer2;
            break;
            
        default:
            break;
    }
    
    int b;
    do {
        b = RAND_FROM_TO(1, 3);
    } while (b == a);
    
    switch (b) {
        case 1:
            answer2 = self.game.triviaQuestion.correctAnswer;
            break;
            
        case 2:
            answer2 = self.game.triviaQuestion.wrongAnswer1;
            break;
            
        case 3:
            answer2 = self.game.triviaQuestion.wrongAnswer2;
            break;
            
        default:
            break;
    }
    
    int c;
    do {
        c = RAND_FROM_TO(1, 3);
    } while ((c == a) || (c == b));
    
    switch (c) {
        case 1:
            answer3 = self.game.triviaQuestion.correctAnswer;
            break;
            
        case 2:
            answer3 = self.game.triviaQuestion.wrongAnswer1;
            break;
            
        case 3:
            answer3 = self.game.triviaQuestion.wrongAnswer2;
            break;
            
        default:
            break;
    }
    
    //assign answers to buttons
    [UIView setAnimationsEnabled:NO]; //keeps weird fade in animation from happening when title changes
    [self.button1 setTitle:answer1 forState:UIControlStateNormal];
    [self.button1 layoutIfNeeded];
    [self.button2 setTitle:answer2 forState:UIControlStateNormal];
    [self.button2 layoutIfNeeded];
    [self.button3 setTitle:answer3 forState:UIControlStateNormal];
    [self.button3 layoutIfNeeded];
    [UIView setAnimationsEnabled:YES];
    
    //dim the pennants and sideline
    self.pennant1stQtrName.alpha = 0;
    self.pennant2ndQtrName.alpha = 0;
    self.pennant3rdQtrName.alpha = 0;
    self.pennant4thQtrName.alpha = 0;
    self.pennantFinalQtrName.alpha = 0;
    self.pennant1stQtrImage.alpha = 0;
    self.pennant2ndQtrImage.alpha = 0;
    self.pennant3rdQtrImage.alpha = 0;
    self.pennant4thQtrImage.alpha = 0;
    self.pennantFinalQtrImage.alpha = 0;
    self.pennant1stQtrNote.alpha = 0;
    self.pennant2ndQtrNote.alpha = 0;
    self.pennant3rdQtrNote.alpha = 0;
    self.pennant4thQtrNote.alpha = 0;
    self.pennantFinalQtrNote.alpha = 0;
    self.pennants.alpha = 0;
    self.sideline.alpha = 0;
    
    self.triviaQuestion.layer.zPosition = zPosFront;
    self.button1.layer.zPosition = zPosFront;
    self.button2.layer.zPosition = zPosFront;
    self.button3.layer.zPosition = zPosFront;

    
    
    
    //luminate the trivia
    self.triviaInfo.alpha = 1;
    self.triviaPlayerImage.alpha = 1;
    self.triviaPlayerName.alpha = 1;
    self.triviaQuestion.alpha = 1;
    self.button1.alpha = 1;
    self.button2.alpha = 1;
    self.button3.alpha = 1;
    
}

- (void)hideTrivia {
    
    //dim the trivia
    self.triviaInfo.alpha = 0;
    self.triviaPlayerImage.alpha = 0;
    self.triviaPlayerName.alpha = 0;
    self.triviaQuestion.alpha = 0;
    self.button1.alpha = 0;
    self.button2.alpha = 0;
    self.button3.alpha = 0;
    
    //luminate the pennants and sideline
    self.pennant1stQtrName.alpha = 1;
    self.pennant2ndQtrName.alpha = 1;
    self.pennant3rdQtrName.alpha = 1;
    self.pennant4thQtrName.alpha = 1;
    self.pennantFinalQtrName.alpha = 1;
    self.pennant1stQtrImage.alpha = 1;
    self.pennant2ndQtrImage.alpha = 1;
    self.pennant3rdQtrImage.alpha = 1;
    self.pennant4thQtrImage.alpha = 1;
    self.pennantFinalQtrImage.alpha = 1;
    self.pennants.alpha = 1;
    self.sideline.alpha = 1;
    
    //show pennant quarters
    if (!self.pennant1stQtrImage.image) {
        self.pennant1stQtrNote.alpha = 1;
    }
    if (!self.pennant2ndQtrImage.image) {
        self.pennant2ndQtrNote.alpha = 1;
    }
    if (!self.pennant3rdQtrImage.image) {
        self.pennant3rdQtrNote.alpha = 1;
    }
    if (!self.pennant4thQtrImage.image) {
        self.pennant4thQtrNote.alpha = 1;
    }
    if (!self.pennantFinalQtrImage.image) {
        self.pennantFinalQtrNote.alpha = 1;
    }
    
    //enable updating the score
    [self enableScoreButtons];
        
}

- (void)dimTriviaButtons {
    self.triviaQuestion.alpha = 0;
    self.button1.alpha = 0;
    self.button2.alpha = 0;
    self.button3.alpha = 0;
    
}

- (void)stopTrivia {
    silentWhistle = YES;
    //stop the timer
    [self.game.scoreboardTimer invalidate];
    self.game.scoreboardTimer = nil;
    self.game.timeRemaining = 0;
    self.game.playClock = YES; //so updateScoreboardTimer will hide trivia if it's shown
    [self updateScoreboardTimer];
    self.game.playClock = NO; //so SquaresGame is ready to count down to a new question
    silentWhistle = NO;
    
}

- (IBAction)triviaAnswerOneSelected:(id)sender {
    
    if (menuPressed) {
        self.game.mode = @"trivia";
        tinySelectionFootball.frame = CGRectMake(463.0f, 383.0f, 74.0f, 50.0f);
    } else {
        if (self.button1.currentTitle == self.game.triviaQuestion.correctAnswer) {
            [self correctAnswer];
        } else {
            [self wrongAnswer];
        }
    }
}

- (IBAction)triviaAnswerTwoSelected:(id)sender {
    
    if (menuPressed) {
        self.game.mode = @"classic";
        tinySelectionFootball.frame = CGRectMake(463.0f, 423.0f, 74.0f, 50.0f);
    } else {
        if (self.button2.currentTitle == self.game.triviaQuestion.correctAnswer) {
            [self correctAnswer];
        } else {
            [self wrongAnswer];
        }
    }
}

- (IBAction)triviaAnswerThreeSelected:(id)sender {
    
    if (menuPressed) {
        [self dimTriviaButtons];
        //dim the checkmark football
        tinySelectionFootball.alpha = 0;
        //display help
        self.helpView.alpha = 1;
    } else {
        if (self.button3.currentTitle == self.game.triviaQuestion.correctAnswer) {
            [self correctAnswer];
        } else {
            [self wrongAnswer];
        }
    }
}

- (void)correctAnswer {
    NSLog(@"correct!");
    correctGuess = YES;
    self.triviaInfo.text = @"correct! you can move one of your tokens until the timer runs out.";
    [self dimTriviaButtons];
    [self unlockCorrectAnswerTokens];
    
}

- (void)wrongAnswer {
    correctGuess = NO;
    self.triviaInfo.text = @"sorry! that is not the corrrect answer.";
    self.game.timeRemaining = 0.0;
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self hideTrivia];
        [self.menu setUserInteractionEnabled:YES]; //enable the menu button so it can be pressed
        
        //display the start button with a short fade in
        [UIView animateWithDuration:0.5 animations:^{
            self.menu.alpha = 1.0;}
                         completion:NULL];
    });
    
}

- (void)unlockCorrectAnswerTokens {
    
    Token *tempToken;
    NSString *playerName;
    
    playerName = [NSString stringWithString:self.game.triviaToken.playerName];
    allTokensLocked = NO;
    
    for (tempToken in self.game.tokens) {
        if ([tempToken.playerName isEqualToString:playerName]) {
            tempToken.isLocked = NO;
            [tempToken startWobble];
        } else {
            tempToken.isLocked = YES;
        }
    }
    
}

- (void)lockAllOtherTokens {
    
    Token *tempToken;
    
    for (tempToken in self.game.tokens) {
        if (!(tempToken == heldToken)) {
            tempToken.isLocked = YES;
        } else {
            movedToken = heldToken; //keep the moved token wobbling so players can find it after
        }
    }
    
}

#pragma mark Miscellaneous

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//added by eagle
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent; //changes the status of the style bar to light text
}

- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    //any text field change will automatically call this method
    
    if (textField == self.playerNameField ) {
        NSLog(@"hey the player name field was pressed!");
    }
    
    if ([self.game.phase isEqualToString:@"setup"]) {
        token = self.game.tokens[activeTokenIndex];
        [self changeNameField];
        //make the token have the same name as the player name field
        [self changeName];
    }
    
    //done button was pressed - dismiss keyboard
    [textField resignFirstResponder]; //when the keyboard is dismissed... keyboardDidHide notification is triggered
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //this method prevents non-numeric characters from being entered into the score text fields
    
    if ([string length] > 0 && [self.game.phase isEqualToString:@"play"] ) {
        NSCharacterSet* numberCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        for (int i=0; i<[string length]; ++i) {
            unichar aCharacter = [string characterAtIndex:i];
            if (![numberCharSet characterIsMember:aCharacter]) {
                return NO;
            }
            
        }
    }
    
    return YES;
    
}

- (void)keyboardDidHide:(NSNotification*)aNotification{
    if ([self.game.phase isEqualToString:@"play"]) {
        [self scoreWasChanged];
    }
}

- (IBAction)pushMenu:(id)sender {
    
    if (!menuPressed) {
        
        tinySelectionFootball.layer.zPosition = zPosFront; //not part of the storyboard so maybe you have to keep managing the z-position?
        
        if (self.start.alpha == 1.0) {
            self.start.alpha = 0.0;
        }
        
        //pause the timer
        if (self.game.scoreboardTimer) {
            [self.game.scoreboardTimer invalidate];
            self.game.scoreboardTimer = nil;
            timerPaused = YES;
        }
        
        //disable updating the score
        if ([self.game.phase isEqualToString:@"play"]) {
            [self disableScoreButtons];
        }
        
        //assign options to buttons
        [UIView setAnimationsEnabled:NO]; //keeps weird fade in animation from happening when title changes
        self.triviaQuestion.text = @"--MENU--";
        [self.button1 setTitle:@"Trivia Squares" forState:UIControlStateNormal];
        [self.button1 layoutIfNeeded];
        [self.button2 setTitle:@"Classic Squares" forState:UIControlStateNormal];
        [self.button2 layoutIfNeeded];
        [self.button3 setTitle:@"Help" forState:UIControlStateNormal];
        [self.button3 layoutIfNeeded];
        [UIView setAnimationsEnabled:YES];
        
        self.backboard.alpha = 1; //luminate the backboard
        
        //luminate the buttons
        self.triviaQuestion.alpha = 1;
        self.button1.alpha = 1;
        self.button2.alpha = 1;
        self.button3.alpha = 1;
        
        tinySelectionFootball.alpha = 1; //luminate the checkmark football
        menuPressed = YES;

    } else {
        
        [self hideMenu];
        
//        if (allTokensOnField && [self.game.phase isEqualToString:@"setup"]) {
//            self.start.alpha = 1.0;
//        }
//        
//        self.backboard.alpha = 0; //dim the backboard
//        
//        //dim the buttons
//        self.triviaQuestion.alpha = 0;
//        self.button1.alpha = 0;
//        self.button2.alpha = 0;
//        self.button3.alpha = 0;
//        
//        tinySelectionFootball.alpha = 0; //dim the check marks
//        self.helpView.alpha = 0; //dim the help menu
//        
//        //restart the timer
//        if ([self.game.phase isEqualToString:@"play"]) {
//            if (timerPaused) {
//                self.game.scoreboardTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self.game selector:@selector(tickSecond) userInfo:nil repeats:YES];
//                timerPaused = NO;
//            }
//        }
//        
//        //unlock the tokens
//        if ([self.game.phase isEqualToString:@"setup"]) {
//            allTokensLocked = NO;
//        }
//        
//        //enable updating the score
//        if ([self.game.phase isEqualToString:@"play"]) {
//            [self enableScoreButtons];
//        }
//        
//        menuPressed = NO;

    }

}

- (void)hideMenu {
    
    if (allTokensOnField && [self.game.phase isEqualToString:@"setup"]) {
        self.start.alpha = 1.0;
    }
    
    self.backboard.alpha = 0; //dim the backboard
    
    //dim the buttons
    self.triviaQuestion.alpha = 0;
    self.button1.alpha = 0;
    self.button2.alpha = 0;
    self.button3.alpha = 0;
    
    tinySelectionFootball.alpha = 0; //dim the check marks
    self.helpView.alpha = 0; //dim the help menu
    
    //restart the timer
    if ([self.game.phase isEqualToString:@"play"]) {
        if (timerPaused) {
            self.game.scoreboardTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self.game selector:@selector(tickSecond) userInfo:nil repeats:YES];
            timerPaused = NO;
        }
    }
    
    //unlock the tokens
    if ([self.game.phase isEqualToString:@"setup"]) {
        allTokensLocked = NO;
    }
    
    //enable updating the score
    if ([self.game.phase isEqualToString:@"play"]) {
        [self enableScoreButtons];
    }
    
    menuPressed = NO;

    
}

- (IBAction)pushStart:(id)sender {
    
    self.start.alpha = 0.0; //hide the start button
    self.sideline.alpha = 1.0; //display the sideline
    self.pennants.alpha = 1.0; //display the pennants
    tinyWinningFootball.layer.zPosition = zPosFootball;
    //generate the random numbers for the field
    [viewControllerTimer invalidate];
    viewControllerTimer = [NSTimer scheduledTimerWithTimeInterval:0.50 target:self selector:@selector(updateSquareNumbers) userInfo:nil repeats:YES];
    firstSound= YES;
    allTokensLocked = YES; //lock tokens so no touches can be applied
    self.game.phase = @"play";

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) { // Ok button
        NSLog(@"eat pizza!!!");
//        // URL to be opened
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [self phoneNumber]]];
        
//        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
//        [[UIApplication sharedApplication] openURL:url];
    }
}


@end
