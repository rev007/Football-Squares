//
//  Trivia.h
//  Sports Squares
//
//  Created by EAGLE on 12/30/15.
//  Copyright © 2015 GreenVine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Trivia : NSObject

@property(strong, nonatomic) NSString *question;
@property(strong, nonatomic) NSString *correctAnswer;
@property(strong, nonatomic) NSString *wrongAnswer1;
@property(strong, nonatomic) NSString *wrongAnswer2;

- (void)randomQuestion;

@end
