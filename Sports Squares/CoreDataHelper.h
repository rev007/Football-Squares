//
//  CoreDataHelper.h
//  Sports Squares
//
//  Created by EAGLE on 8/29/16.
//  Copyright © 2016 GreenVine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataHelper : NSObject

@property(nonatomic, readonly) NSManagedObjectContext *context;
@property(nonatomic, readonly) NSManagedObjectModel *model;
@property(nonatomic, readonly) NSPersistentStoreCoordinator *coordinator;
@property(nonatomic, readonly) NSPersistentStore *store;

- (void)setupCoreData;
- (void)saveContext; //can be called whenever you like but pg. 51 says DON'T DO IT until a background saver is added later

@end
