//
//  SquaresAudio.m
//  Sports Squares
//
//  Created by EAGLE on 9/22/15.
//  Copyright © 2015 GreenVine. All rights reserved.
//

//what are your audio intentions?

//how do i make sure the sound goes through the speakers so nobody can cheat?

// how will your app recover from an interruption?
// to handle the interruption of an audio queue gracefully, set the appropriate category and register for AVAudioSessionInterruptionNotification and have your app respond accordingly.

// how will your app play sounds when the silent switch is enabled?
// how will your app play sounds when the screen is locked or the auto-lock period expires?
// to ensure that audio continues upon screen locking, configure your audio session to use a category that supports playback and set the audio flag in UIBackgroundModes.

// how can you allow other music from other apps play at the same time?
// To ensure that music is not interrupted, configure your audio session to allow mixing. Use the AVAudioSessionCategoryAmbient category, or modify the AVAudioSessionCategoryPlayback category to support mixing.

//how will you allow volume controls from within your app?
//Use the MPVolumeView class to present volume and routing control for your app. 


#import "SquaresAudio.h"

int measure = 1;

@interface SquaresAudio ()

@property(retain, nonatomic) NSDate *previousTime;

@end

@implementation SquaresAudio

// Override superclass implementation of init so that we can provide a properly
// initialized game model
- (id)init {
    self = [super init];
    
    if (self) {
        
        [self setUpAudioSession];
        
        // Init audio players
        NSURL *ringUpURL = [NSURL fileURLWithPath: [[NSBundle mainBundle]
                                                        pathForResource: @"ringUp"
                                                        ofType: @"aif"]];
        
        ringUp = [[AVAudioPlayer alloc] initWithContentsOfURL:ringUpURL
                                                             error:nil];
        
        NSURL *ringUpFollowURL = [NSURL fileURLWithPath: [[NSBundle mainBundle]
                                                         pathForResource: @"ringUpFollow"
                                                         ofType: @"aif"]];
        
        ringUpFollow = [[AVAudioPlayer alloc]
                        initWithContentsOfURL:ringUpFollowURL
                        error:nil];
        
        NSURL *lineShiftURL = [NSURL fileURLWithPath: [[NSBundle mainBundle]
                                                    pathForResource: @"lineShift"
                                                    ofType: @"aif"]];
        
        lineShift = [[AVAudioPlayer alloc] initWithContentsOfURL:lineShiftURL
                                                              error:nil];
        
        //loop indefinitely
        lineShift.numberOfLoops = -1;
        
        //set the volume
        lineShift.volume = 0.3;
        
        NSURL *tenthSecondBeepsURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                         pathForResource: @"tenthSecondBeeps"
                                                         ofType: @"aif"]];
        
        tenthSecondBeeps = [[AVAudioPlayer alloc] initWithContentsOfURL:tenthSecondBeepsURL
                                                           error:nil];
        
        //loop indefinitely
        tenthSecondBeeps.numberOfLoops = -1;
        
        NSURL *thirdSecondBeepsURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                             pathForResource: @"thirdSecondBeeps"
                                                             ofType: @"aif"]];
        
        thirdSecondBeeps = [[AVAudioPlayer alloc] initWithContentsOfURL:thirdSecondBeepsURL
                                                                  error:nil];
        
        //loop indefinitely
        thirdSecondBeeps.numberOfLoops = -1;

        NSURL *halfSecondBeepsURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                             pathForResource: @"halfSecondBeeps"
                                                             ofType: @"aif"]];
        
        halfSecondBeeps = [[AVAudioPlayer alloc] initWithContentsOfURL:halfSecondBeepsURL
                                                                  error:nil];
        
        //loop indefinitely
        halfSecondBeeps.numberOfLoops = -1;
        
        NSURL *whistleURL = [NSURL fileURLWithPath: [[NSBundle mainBundle]
                                                    pathForResource: @"whistle"
                                                    ofType: @"aif"]];
        
        whistle = [[AVAudioPlayer alloc] initWithContentsOfURL:whistleURL
                                                        error:nil];
        
        NSURL *bellURL = [NSURL fileURLWithPath: [[NSBundle mainBundle]
                                                     pathForResource: @"bell"
                                                     ofType: @"aif"]];
        
        bell = [[AVAudioPlayer alloc] initWithContentsOfURL:bellURL
                                                         error:nil];
        
        //set the volume
        bell.volume = 0.5;
        
        NSURL *scoreChangeURL = [NSURL fileURLWithPath: [[NSBundle mainBundle]
                                                     pathForResource: @"scoreChange"
                                                     ofType: @"aif"]];
        
        scoreChange = [[AVAudioPlayer alloc] initWithContentsOfURL:scoreChangeURL
                                                         error:nil];
        
        // Prepare to play sounds
        [ringUp prepareToPlay];
        [ringUpFollow prepareToPlay];
        [lineShift prepareToPlay];
        [tenthSecondBeeps prepareToPlay];
        [thirdSecondBeeps prepareToPlay];
        [halfSecondBeeps prepareToPlay];
        [whistle prepareToPlay];
        [bell prepareToPlay];
        [scoreChange prepareToPlay];
        
        //set the time
        self.previousTime = [NSDate date];
        
    }
    
    return self;
}

- (void)setUpAudioSession {
    
    BOOL success;
    
    //obtain a reference to the AVAudioSession object
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    // Set category of audio session
    // See handy chart on pg. 46 of the Audio Session Programming Guide for what the categories mean
    // Not absolutely required in this example, but good to get into the habit of doing
    // See pg. 10 of Audio Session Programming Guide for "Why a Default Session Usually Isn't What You Want"
    
    //set the audio session category
    NSError *setCategoryError = nil;
    //inspect otherAudioPlaying property
    if ([audioSession isOtherAudioPlaying]) {
        NSLog(@"other music is playing!");
        success = [audioSession setCategory:AVAudioSessionCategoryPlayback //Playback always plays audio
                                withOptions:AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionDuckOthers
                                      error:&setCategoryError];
    } else {
        NSLog(@"no other audio is currently playing");
        success = [audioSession setCategory:AVAudioSessionCategoryPlayback //Playback always plays audio
                                withOptions:AVAudioSessionCategoryOptionMixWithOthers //mixWithOthers allows mixing with other apps
                                      error:&setCategoryError];
    }
    
    if (!success) {
        /* handle the error is setCategoryError */
    }
}

- (void)ringUp {
    
    NSDate *currentTime = [NSDate date];
    NSTimeInterval timeDifference =  [currentTime timeIntervalSinceDate:self.previousTime];
//    NSLog(@"time difference = %f", timeDifference);
    
//    if (timeDifference > 1) {
//        if (measure == 2) {
//            if (!ringUp.playing) {
//                [ringUpFollow play];
//                measure = 1;
//            }
//        } else {
//            if (!ringUpFollow.playing) {
//                [ringUp play];
//                measure++;
//            }
//        }
//        self.previousTime = [NSDate date];
//
//    }
    
    if (timeDifference > 1) {
        if (measure == 1) {
            if (!ringUpFollow.playing) {
                [ringUp play];
                measure++;
            }
        } else {
            if (!ringUp.playing) {
                [ringUpFollow play];
                measure = 1;
            }
        }
        self.previousTime = [NSDate date];
        
    }


    
//        if (measure == 2) {
//            
//            if (ringUp.playing) {
//                [ringUp stop];
//            }
//            
//                [ringUpFollow play];
//                measure = 1;
//    
//        } else {
//            if (ringUpFollow.playing) {
//                [ringUpFollow stop];
//            }
//                [ringUp play];
//                measure++;
//            }
//
//        self.previousTime = [NSDate date];



}

- (void)lineShift {
    
    if (!lineShift.playing) {
        [lineShift play];
    } else {
        [lineShift pause];
        lineShift.currentTime = 0;
    }
}

- (void)tenthSecondBeeps {
    
    if (!tenthSecondBeeps.playing) {
        [tenthSecondBeeps play];
    } else {
        [tenthSecondBeeps stop];
    }
}

- (void)thirdSecondBeeps {
    
    if (!thirdSecondBeeps.playing) {
        [thirdSecondBeeps play];
    } else {
        [thirdSecondBeeps stop];
        thirdSecondBeeps.currentTime = 0;
    }
}

- (void)halfSecondBeeps {
    
    if (!halfSecondBeeps.playing) {
        [halfSecondBeeps play];
    } else {
        [halfSecondBeeps stop];
        halfSecondBeeps.currentTime = 0;
    }
}

- (void)singleBeep {
    if (!halfSecondBeeps.playing) {
        [halfSecondBeeps play];
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(singleBeep) userInfo:nil repeats:NO];
    } else {
        [halfSecondBeeps stop];
        halfSecondBeeps.currentTime = 0;
    }
}

- (void)whistle {
    [whistle play];
}

- (void)bell {
    [bell play];
}

- (void)scoreChange {
    [scoreChange play];
}

@end

