//
//  AppDelegate.h
//  Sports Squares
//
//  Created by EAGLE on 6/3/15.
//  Copyright (c) 2015 GreenVine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) CoreDataHelper *coreDataHelper;

@end

