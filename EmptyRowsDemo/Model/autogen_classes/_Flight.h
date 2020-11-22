// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Flight.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class FlightInfo;

@interface FlightID : NSManagedObjectID {}
@end

@interface _Flight : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) FlightID *objectID;

@property (nonatomic, strong, nullable) NSString* name;

@property (nonatomic, strong, nullable) FlightInfo *flightInfo;

@end

@interface _Flight (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSString*)primitiveName;
- (void)setPrimitiveName:(nullable NSString*)value;

- (FlightInfo*)primitiveFlightInfo;
- (void)setPrimitiveFlightInfo:(FlightInfo*)value;

@end

@interface FlightAttributes: NSObject 
+ (NSString *)name;
@end

@interface FlightRelationships: NSObject
+ (NSString *)flightInfo;
@end

NS_ASSUME_NONNULL_END
