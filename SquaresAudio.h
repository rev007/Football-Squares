//
//  SquaresAudio.h
//  Sports Squares
//
//  Created by EAGLE on 9/22/15.
//  Copyright © 2015 GreenVine. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;

@interface SquaresAudio : NSObject {
    
    AVAudioPlayer *ringUp;
    AVAudioPlayer *ringUpFollow;
    AVAudioPlayer *lineShift;
    AVAudioPlayer *tenthSecondBeeps;
    AVAudioPlayer *thirdSecondBeeps;
    AVAudioPlayer *halfSecondBeeps;
    AVAudioPlayer *whistle;
    AVAudioPlayer *bell;
    AVAudioPlayer *scoreChange;
}

- (void)ringUp;
- (void)lineShift;
- (void)tenthSecondBeeps;
- (void)thirdSecondBeeps;
- (void)halfSecondBeeps;
- (void)singleBeep;
- (void)whistle;
- (void)bell;
- (void)scoreChange;

@end
