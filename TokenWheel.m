//
//  TokenWheel.m
//  Sports Squares
//
//  Created by EAGLE on 6/4/15.
//  Copyright (c) 2015 GreenVine. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TokenWheel.h"

@interface TokenWheel ()
@property (strong, nonatomic) NSMutableArray *circlePoints; // The initial middle edge point of each petal that lies on the circumference of the wheel.
@property (strong, nonatomic) CALayer *hub;
@property (strong, nonatomic) NSArray *colorsRGB;
@property (strong, nonatomic) NSArray *colorNames;

-(void)drawWheel;
-(void)drawHub;
-(void)closestPoint; // Finds the closest initial circle point (in the array) to the first petal.
-(void)restWheel;
-(void)petalChoice; // Finds the petal that belongs to the closest point.
@end

static float deltaAngle;
BOOL hubTouched;
BOOL wheelRotated;

@implementation TokenWheel {
    CGFloat petalPoint; // Wherever the first petal lies on the circle as it is moved about.
    CGFloat circlePoint; // Notice this isn't an object so it can't be stored in an NSArray.
    CGFloat closestPoint; // The closest (stationary) circle point to the first (moving) petal.
    CGFloat smallestAngle; // The angle between the closest circle point and the first petal.
    int direction; // The direction the wheel needs to move for the first petal to be on the closest circle point.
    BOOL stopRotating; // Stop moving the wheel if the user's finger goes out of bounds.
}

@synthesize delegate, containerView, hubColor, startTransform, numberOfPetals, lengthOfPetal, widthOfPetal, petalNumber, hubRadius;
@synthesize hub, colorsRGB, colorNames;

- (NSMutableArray *) circlePoints
{
    if (!_circlePoints) _circlePoints = [[NSMutableArray alloc] init];
    return _circlePoints;
}

- (NSArray *) colorsRGB
{
    if (!colorsRGB) colorsRGB = @[[UIColor colorWithRed: 218/255.0 green: 60/255.0 blue: 48/255.0 alpha:1.0],
                                  [UIColor colorWithRed: 81/255.0 green: 178/255.0 blue: 154/255.0 alpha:1.0],
                                  [UIColor colorWithRed: 215/255.0 green: 62/255.0 blue: 137/255.0 alpha: 1.0],
                                  [UIColor colorWithRed: 212/255.0 green: 206/255.0 blue: 172/255.0 alpha: 1.0],
                                  [UIColor colorWithRed: 139/255.0 green: 15/255.0 blue: 13/255.0 alpha: 1.0],
                                  [UIColor colorWithRed: 239/255.0 green: 155/255.0 blue: 110/255.0 alpha: 1.0],
                                  [UIColor colorWithRed: 229/255.0 green: 202/255.0 blue: 72/255.0 alpha:1.0],
                                  [UIColor colorWithRed: 169/255.0 green: 144/255.0 blue: 184/255.0 alpha: 1.0],
                                  [UIColor colorWithRed: 48/255.0 green: 178/255.0 blue: 213/255.0 alpha: 1.0],
                                  [UIColor colorWithRed: 163/255.0 green: 213/255.0 blue: 67/255.0 alpha: 1.0]];
    
    return colorsRGB;
    
}

- (NSArray *)colorNames {
    
    if (!colorNames) colorNames = @[@"bathing suit", @"chevy", @"jazz", @"canoga park cream", @"lucky",
                                    @"camera", @"family bar", @"canoga park purple", @"cat", @"design"];
    
    return colorNames;
    
}

- (id)initWithFrame:(CGRect)frame andDelegate:(id)del withPetals:(int)petalsNumber withLength:(int)petalLength withWidth:(int)petalWidth withRadius:(int)centerRadius {
    // 1 - Call super init.
    if (self = [super initWithFrame:frame]) {
        // 2 - Set properties.
        self.delegate = del;
        self.numberOfPetals = petalsNumber;
        self.lengthOfPetal = petalLength;
        self.widthOfPetal = petalWidth;
        self.hubRadius = centerRadius;
        // 3 - Draw the wheel.
        [self drawWheel];
        [self drawHub];
    }
    
    return self;
}

#pragma mark Create Wheel

-(void)drawWheel {
    containerView = [[UIView alloc] initWithFrame:self.frame];
    CGFloat angleSize = 2 * M_PI / numberOfPetals;
    for (int index = 0; index < numberOfPetals; index++) {

        UILabel *petal = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, lengthOfPetal, widthOfPetal)]; // Each petal is an instance.
        
        petal.backgroundColor = [UIColor redColor];
        petal.text = [NSString stringWithFormat:@"%i", index];
        petal.layer.anchorPoint = CGPointMake(1.0f, 0.5f);
        // 5
        petal.layer.position = CGPointMake(containerView.bounds.size.width / 2.0, containerView.bounds.size.height / 2.0);
        petal.transform = CGAffineTransformMakeRotation(angleSize * index);
        
        circlePoint = [[petal valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
        NSNumber *aNumber = [NSNumber numberWithFloat:circlePoint]; // Wrap the non-object into an NSNumber object
        [self.circlePoints addObject:aNumber]; // Now you can store the object in the NSMutableArray
        petal.tag = index;
        // 6
        [containerView addSubview:petal];
        
    }
    
    UIImageView *wheelImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wheel.png"]];
    wheelImageView.layer.position = CGPointMake(containerView.bounds.size.width / 2.0, containerView.bounds.size.height / 2.0);
    wheelImageView.alpha = 1.0;
//    [wheelImageView setTransform:CGAffineTransformMakeRotation (-(M_PI_4)/1.25)];
    [containerView addSubview:wheelImageView];

    
    
    petalPoint = 0.0; // Starting position of the first petal.
    containerView.userInteractionEnabled = NO;
    [self addSubview:containerView];
}

-(void)drawHub {
    hub = [CALayer layer];
    hub.frame = CGRectMake(0.0f, 0.0f, hubRadius*2, hubRadius*2);
    hub.cornerRadius = hubRadius;
    hub.borderColor = [UIColor blackColor].CGColor;
    hub.borderWidth =1;
    self.colorIndex = 0; // Set the initial color of the hub.
    [self newColor];
    UIImage *hubImage = [UIImage imageNamed:@"lightning.png"];
    hub.contents = (__bridge id)([hubImage CGImage]);
    hub.position = CGPointMake(containerView.bounds.size.width / 2.0, containerView.bounds.size.height / 2.0);
    [containerView.layer addSublayer:hub];
}

#pragma mark Touches

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    // 1 - Get touch position.
    CGPoint touchPoint = [touch locationInView:self];
    // 2 - Calculate distance from center.
    float dx = touchPoint.x - containerView.center.x;
    float dy = touchPoint.y -containerView.center.y;
    float distance = sqrt(dx*dx + dy*dy); // Pythagoras' theorem.
    petalPoint = [(NSNumber *)[containerView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    // 3 - Filter out touches too close to the hub.
    if (distance < hubRadius) {
        // The change color hub was touched.
        [self centerWasTouched];
        hubTouched = YES; //using this to prevent extra call of wheelChanged since it didn't rotate
        return NO;
    } else if (distance > lengthOfPetal) {
        // The touch was beyond the ferrule of the carousel.
        return NO;
    }
    // 4 - Calculate arctangent value.
    deltaAngle = atan2(dy, dx);
    // 5 - Save current transform.
    startTransform = containerView.transform;
    
    return YES;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pt = [touch locationInView:self];
    float dx = pt.x - containerView.center.x;
    float dy = pt.y - containerView.center.y;
    float distance = sqrt(dx*dx + dy*dy);
    
    // Finger in bounds.
    if (distance > hubRadius && distance < lengthOfPetal) {
        if (stopRotating) {
            stopRotating = false;
            // Reset beginning touch point.
            [self beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event];
        }
        float ang = atan2(dy, dx);
        float angleDifference = deltaAngle - ang;
        containerView.transform = CGAffineTransformRotate(startTransform, -angleDifference);
        petalPoint = [(NSNumber *)[containerView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
        [self closestPoint];
    } else {
        // Finger went out of bounds.
        if (!stopRotating) {
            [self restWheel]; // You only want to call this once.
        }
        stopRotating = true;
    }
    return YES;
}

-(void)centerWasTouched {
    [self newColor];
    [self.delegate hubTouched]; // Notify that the wheel was changed.
    
}

- (void)touchesEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!hubTouched) {
        [self restWheel];
    }
    hubTouched = NO;
    
}

#pragma mark Wheel Updates

-(void)closestPoint {
    
    smallestAngle = 2 * M_PI; // Start with the largest possible angle.
    CGFloat closePoint = 0;
    direction = 0;
    BOOL adjusted = NO;
    
    for (NSNumber *point in self.circlePoints) {
        CGFloat aPoint = [point floatValue]; // Turn the object back into a float so you can do math with it.
        CGFloat angle = fabs(petalPoint - aPoint); // Get the angle between the two points.
        // Always use the smaller angle between the two points.
        if (angle > M_PI) {
            angle = 2 * M_PI - angle;
            adjusted = YES;
        }
        if (fabs(angle) < fabs(smallestAngle)) {
            smallestAngle = angle;
            closePoint = aPoint;
            if (petalPoint > closePoint) {
                direction = -1;
            } else {
                direction = 1;
            }
        }
        adjusted = NO;
    }
    if (!(closestPoint == closePoint)) {
        closestPoint = closePoint;
        [self petalChoice];
    }
    adjusted = NO;

}

-(void)petalChoice {
    CGFloat angleSize = 2 * M_PI / numberOfPetals;
    angleSize = angleSize * (180 / M_PI); // Convert to degrees.
    CGFloat closestDegrees = closestPoint * (180 / M_PI); // Convert to degrees.
    
    if (closestDegrees < 0) {
        closestDegrees = 360 - fabs(closestDegrees);
    }
    
    closestDegrees = lround(closestDegrees);
    int x = closestDegrees / angleSize; // Store to int to prevent sneaky decimal errors.
    petalNumber = numberOfPetals - x;
    
    if (closestDegrees == 0) {
        petalNumber = 0;
    }
    
    [self.delegate wheelRotated]; // Notify that the wheel was rotated.
    
}

-(void)newColor {
    self.hubColor = self.colorsRGB[self.colorIndex]; // Not sure how to change the hub color...
    NSLog(@"colorIndex = %i", self.colorIndex);
    hub.backgroundColor = self.hubColor.CGColor; // without using these two steps (there has to be a better way).
    self.colorName = self.colorNames[self.colorIndex]; //these are the 1950s color names
    self.colorIndex++;
    if (self.colorIndex == self.colorsRGB.count) {
        self.colorIndex = 0;
    }
    
}

-(void)restWheel {
    
    NSLog(@"resting wheel");
    [self closestPoint];
    // Make the wheel come to a rest using a basic animation.
    CABasicAnimation* restWheel = [CABasicAnimation animationWithKeyPath:@"transform.rotation"]; // animationWithKeyPath means it is an explicit animation.
    restWheel.duration = 0.2;
    restWheel.fromValue = [NSNumber numberWithFloat:petalPoint];
    restWheel.byValue = [NSNumber numberWithFloat:smallestAngle * direction];
    [containerView.layer addAnimation:restWheel forKey:nil]; // Adds the animation object to the layer's render tree.
    
    // Set the final position of the wheel after the animation is done.
    CGAffineTransform transform = CGAffineTransformMakeRotation(closestPoint);
    containerView.transform = transform;
    petalPoint = closestPoint;
    [self petalChoice];
    
}

@end
