//
//  DataStore.h
//  FlightBriefing
//
//  Created by Johan Nyman on 2020-07-13.
//  Copyright © 2020 JN Avionics. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataStore : NSObject

//Return the one and only context
+ (NSManagedObjectContext *) managedObjectContext;

//Setup the Core Data Stack
//Returns NO if any failure occurs, YES if the stack is set up correctly
+ (BOOL) setupAutoMigratingCoreDataStackAndWait;


//Setup the Core Data Stack asynchronously
+ (void) setupAutoMigratingCoreDataStackWithCompletionBlock: (nullable void (^)(void)) callback;

//Save context and return when done
+ (BOOL)saveContextWithError:(NSError * _Nullable *) error;

//Save context asynchronously and then perform the completion block
+ (void) saveContextAsyncWithCompletion:(void (^ _Nullable )(BOOL success, NSError* error)) completionBlock;

+ (id) createEntity:(NSString *) entityName;
+ (id) createEntityInMemoryStore:(NSString *) entityName;

+ (void) deleteObject:(NSManagedObject *) object;
+ (void) clearMemoryContext;

+ (NSArray *) fetchAll:(NSString *) entityName;
+ (NSArray *) fetchAll:(NSString *) entityName
         withPredicate:(nullable NSPredicate *) predicate
              sortedBy:(nullable NSArray <NSSortDescriptor *> * )sortDescriptors;

+ (NSUInteger) countAll:(NSString *) entityName;
+ (NSUInteger) countAll:(NSString *) entityName
            withPredicate:(nullable NSPredicate *) predicate;


@end


NS_ASSUME_NONNULL_END
