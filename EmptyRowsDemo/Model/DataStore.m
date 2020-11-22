//
//  DataStore.m
//  FlightBriefing
//
//  Created by Johan Nyman on 2020-07-13.
//  Copyright © 2020 JN Avionics. All rights reserved.
//
// Based on Apples documentation for Core Data
// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/InitializingtheCoreDataStack.html#//apple_ref/doc/uid/TP40001075-CH4-SW1

// And this documentation for dual stores
// https://stackoverflow.com/questions/14004055/how-to-use-core-data-models-without-saving-them?rq=1

// And this idea of requirements of a DataStore
// https://github.com/justeat/JustPersist



#import "DataStore.h"

#import "FlightInfo.h" //For the clearing of inMemoryStore


@interface DataStore ()

@property NSManagedObjectContext * managedObjectContext;
@property NSPersistentStore * diskStore;
@property NSPersistentStore * memoryStore;
@property BOOL stackIsInitialized;

//Return a singleton
+ (DataStore *) sharedStore;

@end

@implementation DataStore

+ (DataStore *) sharedStore
{
    static DataStore *sharedStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] init];
        sharedStore.stackIsInitialized = FALSE;
    });
    return sharedStore;
}


/****************
 Setup the Core Data Stack on initialization
 *********************/

//Returns NO if any failure occurs
+ (BOOL) setupAutoMigratingCoreDataStackAndWait
{
    //Make sure this is only executed once per run:
    if ([[DataStore sharedStore] stackIsInitialized]) return NO;
    
    /********MODEL **********/
    //This resource is the same name as your xcdatamodeld contained in your project
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FlightBriefing" withExtension:@"momd"];
    NSAssert(modelURL, @"Failed to locate momd bundle in application");
    
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSAssert(mom, @"Failed to initialize mom from URL: %@", modelURL);
    
    /************ COORDINATOR ************/
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    
    /***************** CONTEXT **********************/
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:coordinator];
    [[DataStore sharedStore] setManagedObjectContext:moc];
    
    /*************** PERSISTENT STORE *****************
     A few situations can cause this call to block the calling thread (for example, integration with iCloud and Migrations). Therefore, this may block the user interface queue.
     */
    
    NSPersistentStoreCoordinator *psc = [[DataStore sharedStore].managedObjectContext persistentStoreCoordinator];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    // The directory the application uses to store the Core Data store file. This code uses a file named "FlightBriefing.sqlite" in a directory with the apps name in the application's support directory.
    //NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleNameKey];
    //NSURL *storeURL = [appSupportURL URLByAppendingPathComponent:applicationName];
    //storeURL = [storeURL URLByAppendingPathComponent:@"FlightBriefing.sqlite"];
    NSURL *storeURL = [appSupportURL URLByAppendingPathComponent:@"FlightBriefing.sqlite"];
    
    NSError *error = nil;
    [DataStore sharedStore].diskStore = [psc
                                         addPersistentStoreWithType:NSSQLiteStoreType
                                         configuration:nil
                                         URL:storeURL
                                         options:[DataStore autoMigrationOptions]
                                         error:&error];
    if (![DataStore sharedStore].diskStore) {
        NSLog(@"Failed to initalize persistent store: %@\n%@", [error localizedDescription], [error userInfo]);
        [DataStore sharedStore].stackIsInitialized = FALSE;
        return NO;
        //A more user facing error message may be appropriate here rather than just a console log and an abort
    }
    
    // Add in memory Store
    [DataStore sharedStore].memoryStore = [psc
                                           addPersistentStoreWithType:NSInMemoryStoreType
                                           configuration:nil
                                           URL:nil
                                           options:nil
                                           error:&error];
    if (![DataStore sharedStore].memoryStore) {
        NSLog(@"Failed to initalize in memory store: %@\n%@", [error localizedDescription], [error userInfo]);
        [DataStore sharedStore].stackIsInitialized = FALSE;
        return NO;
        //A more user facing error message may be appropriate here rather than just a console log and an abort
    }
    
    [DataStore sharedStore].stackIsInitialized = TRUE;
    
    return YES;
    
}

+ (void) setupAutoMigratingCoreDataStackWithCompletionBlock: (nullable void (^)(void)) callback
{
    //Make sure this is only executed once per run:
    if ([[DataStore sharedStore] stackIsInitialized]) return;
    
    /********MODEL **********/
    //This resource is the same name as your xcdatamodeld contained in your project
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FlightBriefing" withExtension:@"momd"];
    NSAssert(modelURL, @"Failed to locate momd bundle in application");
    
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSAssert(mom, @"Failed to initialize mom from URL: %@", modelURL);
    
    /************ COORDINATOR ************/
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    
    /***************** CONTEXT **********************/
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:coordinator];
    [[DataStore sharedStore] setManagedObjectContext:moc];
    
    /*************** PERSISTENT STORE *****************
     The call to add the NSPersistentStore to the NSPersistentStoreCoordinator is performed asynchronously. A few situations can cause this call to block the calling thread (for example, integration with iCloud and Migrations). Therefore, it is better to execute this call asynchronously to avoid blocking the user interface queue.
     */
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSPersistentStoreCoordinator *psc = [[DataStore sharedStore].managedObjectContext persistentStoreCoordinator];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
        // The directory the application uses to store the Core Data store file. This code uses a file named "FlightBriefing.sqlite" in a directory with the apps name in the application's support directory.
        //NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleNameKey];
        //NSURL *storeURL = [appSupportURL URLByAppendingPathComponent:applicationName];
        //storeURL = [storeURL URLByAppendingPathComponent:@"FlightBriefing.sqlite"];
        NSURL *storeURL = [appSupportURL URLByAppendingPathComponent:@"FlightBriefing.sqlite"];
        
        NSError *error = nil;
        [DataStore sharedStore].diskStore = [psc
                                             addPersistentStoreWithType:NSSQLiteStoreType
                                             configuration:nil
                                             URL:storeURL
                                             options:[DataStore autoMigrationOptions]
                                             error:&error];
        if (![DataStore sharedStore].diskStore) {
            NSLog(@"Failed to initalize persistent store: %@\n%@", [error localizedDescription], [error userInfo]);
            [DataStore sharedStore].stackIsInitialized = FALSE;
            abort();
            //A more user facing error message may be appropriate here rather than just a console log and an abort
        }
        
        // Add in memory Store
        [DataStore sharedStore].memoryStore = [psc
                                               addPersistentStoreWithType:NSInMemoryStoreType
                                               configuration:nil
                                               URL:nil
                                               options:nil
                                               error:&error];
        if (![DataStore sharedStore].memoryStore) {
            NSLog(@"Failed to initalize in memory store: %@\n%@", [error localizedDescription], [error userInfo]);
            [DataStore sharedStore].stackIsInitialized = FALSE;
            abort();
            //A more user facing error message may be appropriate here rather than just a console log and an abort
        }
        
        
        if (!callback) {
            //If there is no callback block we can safely return
            return;
        }
        //The callback block is expected to complete the User Interface and therefore should be presented back on the main queue so that the user interface does not need to be concerned with which queue this call is coming from.
        dispatch_async(dispatch_get_main_queue(), ^{
            callback();
        });
    });
    [DataStore sharedStore].stackIsInitialized = TRUE;
}


//These options are selected based on Magical Records
// setupCoreDataStackWithAutoMigratingSqliteStoreNamed:

+ (NSDictionary *) autoMigrationOptions
{
    // Adding the journalling mode recommended by apple
    NSMutableDictionary *sqliteOptions = [NSMutableDictionary dictionary];
    [sqliteOptions setObject:@"WAL" forKey:@"journal_mode"];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             sqliteOptions, NSSQLitePragmasOption,
                             nil];
    return options;
}

+ (NSManagedObjectContext *) managedObjectContext
{
    return [DataStore sharedStore].managedObjectContext;
}



//Returns YES if successfully saved or NO if nothing to save.
//The error object will tell the error or nil if nothing was saved.
+ (BOOL)saveContextWithError:(NSError * _Nullable __autoreleasing *)error
{
    if (![DataStore sharedStore].managedObjectContext.hasChanges) return NO; //Nothing to save
    
    if ([[DataStore sharedStore].managedObjectContext save:error] == NO) {
        NSAssert(NO, @"Error saving context: %@\n%@", [*error localizedDescription], [*error userInfo]);
        
        //Notify Crashlytics
        //[[FIRCrashlytics crashlytics] recordError:*error];
    }
    
    return YES;
}

+ (void) saveContextAsyncWithCompletion:(void (^ _Nullable )(BOOL success, NSError* error)) completionBlock;
{
    //Run saveContext on background thread
    [[DataStore sharedStore].managedObjectContext performBlock:^{
        NSError * error;
        BOOL saved = [DataStore saveContextWithError:&error];
        if (completionBlock) completionBlock(saved,error);
    }];
}

- (NSManagedObject *) createEntity:(NSString *) entityName
                           inStore:(NSPersistentStore *) store
{
    
    NSManagedObject * object = [NSEntityDescription
                                insertNewObjectForEntityForName:entityName
                                inManagedObjectContext:[DataStore sharedStore].managedObjectContext];
    
    [[DataStore sharedStore].managedObjectContext assignObject:object toPersistentStore:store];
    
    return object;
}

+ (id) createEntity:(NSString *) entityName
{
    return [[DataStore sharedStore] createEntity:(NSString *) entityName
                                         inStore:[DataStore sharedStore].diskStore];
}

+ (id) createEntityInMemoryStore:(NSString *) entityName
{
    return [[DataStore sharedStore] createEntity: entityName
                                         inStore:[DataStore sharedStore].memoryStore];
}

+ (void) deleteObject:(NSManagedObject *) object
{
    if (object == nil) {
        NSLog(@"Trying to delete nil object");
    } else {
        [[DataStore sharedStore].managedObjectContext deleteObject:object];
    }
}

/** Do NOT execute a batch delete on the objects of the inmemory persistent store, due to the following problems:
 https://www.avanderlee.com/swift/nsbatchdeleterequest-core-data/
 Mainly, the relationships will not be deleted... */
+ (void) clearMemoryContext
{
    
    //Fetch all FlightInfos where isOnline = TRUE
    NSPredicate * onlinePredicate = [NSPredicate predicateWithFormat:@"%K == %@", @"isOnline",@YES];
    NSArray * infos = [DataStore fetchAll:[FlightInfo entityName]
                            withPredicate:onlinePredicate
                                 sortedBy:nil];
    
    //Delete'em one by one
    for (FlightInfo *info in infos) {
        [DataStore deleteObject:info];
    }
    
    //Save the context
    
    NSError * error;
    [DataStore saveContextWithError:&error];
    if (error) {
        NSLog(@"Could not clear memory store");
    }
    /** This is probably not the most efficient way of doing it, but Batch Delete does not work due to reasons stated above, and destroying the inMemoryPersistent store and then adding a new one causes crashes.
     */
}


+ (NSArray *) fetchAll:(NSString *) entityName
{
    return [DataStore fetchAll:entityName withPredicate:nil sortedBy:nil];
}

+ (NSArray *) fetchAll:(NSString *) entityName
         withPredicate:(nullable NSPredicate *) predicate
              sortedBy:(nullable NSArray <NSSortDescriptor *> * )sortDescriptors
{
    
    NSManagedObjectContext *moc = [DataStore sharedStore].managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.predicate = predicate;
    request.sortDescriptors = sortDescriptors;
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:request error:&error];
    if (!results) {
        NSLog(@"Error fetching %@ objects: %@\n%@", entityName, [error localizedDescription], [error userInfo]);
        abort();
    }
    
    return results;
}


+ (NSUInteger) countAll:(NSString *) entityName
{
    return [DataStore countAll:entityName withPredicate:nil];
}

+ (NSUInteger) countAll:(NSString *) entityName
          withPredicate:(nullable NSPredicate *) predicate
{
    
    NSManagedObjectContext *moc = [DataStore sharedStore].managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.predicate = predicate;
    
    NSError *error = nil;
    NSUInteger result = [moc countForFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Error fetching %@ objects: %@\n%@", entityName, [error localizedDescription], [error userInfo]);
        abort();
    }
    
    return result;
}


@end
