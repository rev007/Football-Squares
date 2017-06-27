//
//  Trivia.m
//  Sports Squares
//
//  Created by EAGLE on 12/30/15.
//  Copyright © 2015 GreenVine. All rights reserved.
//

#import "Trivia.h"

#define RAND_FROM_TO(min, max) (min + arc4random_uniform(max - min + 1))

@interface Trivia ()
@property (copy, nonatomic) NSArray *triviaQuestions;
@property (copy, nonatomic) NSArray *triviaCorrectAnswers;
@property (copy, nonatomic) NSArray *triviaWrongAnswers1;
@property (copy, nonatomic) NSArray *triviaWrongAnswers2;
@property (strong, nonatomic) NSMutableArray *questionsAsked;
@end

@implementation Trivia

- (id)init {
    
    self = [super init];
    
    if (self) {
        self.triviaQuestions = @[@"Who invented American football?",
                                 @"What is another name for a football field?",
                                 @"Which war was Pat Patriot in?",
                                 @"What long-ago player was nicknamed the Galloping Ghost?",
                                 @"Which NFL team achieved a perfect season?",
                                 @"How did the Green Bay Packers get their nickname?",
                                 @"Which NFL team's original name was The New York Titans?",
                                 @"What year did the NFL go to a 16-game regular season?",
                                 @"Which wild-card team was the first to win a Super Bowl?",
                                 @"Why was the forward pass legalized?",
                                 @"Which team owner moved the Colts out of Baltimore?",
                                 @"What live college mascot is named Ralphie?",
                                 @"What year did the World Football League play its first season?",
                                 @"What famous vintage toy inspired the name for the Super Bowl?",
                                 @"Where did Joe Namath guarantee a Jets win in Super Bowl III?",
                                 @"Which college football coach won a game by 220 points?",
                                 @"Who coined the phrase \"win one for The Gipper?\"",
                                 @"What year did team sizes reduce from 15 to 11 men on the field?",
                                 @"What teams played in the first American football game in 1869?",
                                 @"What type of play is the clipping rule meant to penalize?",
                                 @"Who is the greatest quarterback of all time?",
                                 @"Which college team did The Four Horsemen play for?"];
        
//        @"Greys Sports Almanac has stats for baseball, boxing, horseracing, and...?"]; Football, Curling, Beer Pong

        self.triviaCorrectAnswers = @[@"Walter Camp", @"Gridiron", @"The American Revolution", @"Red Grange", @"Dolphins", @"Meatpacking plant", @"New York Jets", @"1978", @"Oakland Raiders", @"To decrease injuries", @"Robert Irsay", @"Colorado buffalo", @"1974", @"Wham-O's Super Ball", @"The Miami Touchdown Club",
                                      @"John Heisman", @"Ronald Reagan", @"1880", @"Rutgers vs Princeton", @"Low block from behind", @"Tom Brady", @"Notre Dame"];
        self.triviaWrongAnswers1 = @[@"Chevy Chase", @"Poop deck", @"World War II", @"Redd Foxx", @"Bears", @"Luggage company", @"New York Giants", @"1961",
                                     @"Dallas Cowboys", @"To add excitement!", @"Al Davis", @"Georgia bulldog", @"2001", @"Baldwin's King-Pin Jr.", @"Broadway",
                                     @"Curly Lambeau", @"Knute Rockne", @"1941", @"Army vs Navy", @"A block in the back", @"Jack Trudeau", @"Boise State"];
        self.triviaWrongAnswers2 = @[@"Doug Flutie", @"Flutie Field", @"Warcraft III", @"Rex Harrison", @"Patriots", @"Hewlett-Packard", @"Tennessee Titans", @"1935",
                                     @"Pittsburgh Steelers", @"To confuse the refs", @"Chuck Taylor", @"West Virginia mountaineer", @"It never played a game",
                                     @"Nintendo's Super Mario", @"Disneyland Park", @"Morris Buttermaker", @"Moe Howard", @"1955", @"Floozies vs Isotopes",
                                     @"On-field wedgies", @"Dan Patorini", @"Neigh U"];
        
        self.questionsAsked = [NSMutableArray array];
        
    }
    
    return self;
    
}

- (void)randomQuestion {
    
    NSUInteger questionNumber;
    NSUInteger totalQuestionsAsked;
    NSNumber *foo;
    BOOL alreadyAsked;
    
    do {
        alreadyAsked = NO;
        questionNumber = RAND_FROM_TO(0, (int)self.triviaQuestions.count - 1);
        for (foo in self.questionsAsked) {
            if ([foo intValue] == questionNumber) {
                alreadyAsked = YES;
            }
        }
        
        if (!alreadyAsked) {
            foo = [NSNumber numberWithInteger:questionNumber]; // Wrap the non-object into an NSNumber object
            [self.questionsAsked addObject:foo];
            self.question = [self.triviaQuestions objectAtIndex:questionNumber];
            self.correctAnswer = [self.triviaCorrectAnswers objectAtIndex:questionNumber];
            self.wrongAnswer1 = [self.triviaWrongAnswers1 objectAtIndex:questionNumber];
            self.wrongAnswer2 = [self.triviaWrongAnswers2 objectAtIndex:questionNumber];

        }
    } while (alreadyAsked);
    
    totalQuestionsAsked = self.questionsAsked.count;
    if (totalQuestionsAsked == self.triviaQuestions.count) {
        //make all questions available again
        [self.questionsAsked removeAllObjects];
    }

}

@end
