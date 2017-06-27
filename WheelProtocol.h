//
//  HubProtocol.h
//  Sports Squares
//
//  Created by EAGLE on 6/7/15.
//  Copyright (c) 2015 GreenVine. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WheelProtocol <NSObject>
//- (void)wheelChanged;
- (void)hubTouched;
- (void)wheelRotated;
@end
