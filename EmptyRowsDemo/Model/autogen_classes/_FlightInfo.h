// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FlightInfo.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class Flight;

@interface FlightInfoID : NSManagedObjectID {}
@end

@interface _FlightInfo : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) FlightInfoID *objectID;

@property (nonatomic, strong, nullable) NSString* flightNbr;

@property (nonatomic, strong, nullable) NSNumber* isOnline;

@property (atomic) BOOL isOnlineValue;
- (BOOL)isOnlineValue;
- (void)setIsOnlineValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSDate* lastEdit;

@property (nonatomic, strong, nullable) NSNumber* status;

@property (atomic) int16_t statusValue;
- (int16_t)statusValue;
- (void)setStatusValue:(int16_t)value_;

@property (nonatomic, strong) NSString* uniqueID;

@property (nonatomic, strong, nullable) Flight *flight;

@end

@interface _FlightInfo (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSString*)primitiveFlightNbr;
- (void)setPrimitiveFlightNbr:(nullable NSString*)value;

- (nullable NSNumber*)primitiveIsOnline;
- (void)setPrimitiveIsOnline:(nullable NSNumber*)value;

- (BOOL)primitiveIsOnlineValue;
- (void)setPrimitiveIsOnlineValue:(BOOL)value_;

- (nullable NSDate*)primitiveLastEdit;
- (void)setPrimitiveLastEdit:(nullable NSDate*)value;

- (nullable NSNumber*)primitiveStatus;
- (void)setPrimitiveStatus:(nullable NSNumber*)value;

- (int16_t)primitiveStatusValue;
- (void)setPrimitiveStatusValue:(int16_t)value_;

- (NSString*)primitiveUniqueID;
- (void)setPrimitiveUniqueID:(NSString*)value;

- (Flight*)primitiveFlight;
- (void)setPrimitiveFlight:(Flight*)value;

@end

@interface FlightInfoAttributes: NSObject 
+ (NSString *)flightNbr;
+ (NSString *)isOnline;
+ (NSString *)lastEdit;
+ (NSString *)status;
+ (NSString *)uniqueID;
@end

@interface FlightInfoRelationships: NSObject
+ (NSString *)flight;
@end

NS_ASSUME_NONNULL_END
