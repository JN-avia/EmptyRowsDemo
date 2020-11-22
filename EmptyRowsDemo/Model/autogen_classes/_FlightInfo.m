// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FlightInfo.m instead.

#import "_FlightInfo.h"

@implementation FlightInfoID
@end

@implementation _FlightInfo

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"FlightInfo" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"FlightInfo";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"FlightInfo" inManagedObjectContext:moc_];
}

- (FlightInfoID*)objectID {
	return (FlightInfoID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"isOnlineValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isOnline"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"statusValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"status"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic flightNbr;

@dynamic isOnline;

- (BOOL)isOnlineValue {
	NSNumber *result = [self isOnline];
	return [result boolValue];
}

- (void)setIsOnlineValue:(BOOL)value_ {
	[self setIsOnline:@(value_)];
}

- (BOOL)primitiveIsOnlineValue {
	NSNumber *result = [self primitiveIsOnline];
	return [result boolValue];
}

- (void)setPrimitiveIsOnlineValue:(BOOL)value_ {
	[self setPrimitiveIsOnline:@(value_)];
}

@dynamic lastEdit;

@dynamic status;

- (int16_t)statusValue {
	NSNumber *result = [self status];
	return [result shortValue];
}

- (void)setStatusValue:(int16_t)value_ {
	[self setStatus:@(value_)];
}

- (int16_t)primitiveStatusValue {
	NSNumber *result = [self primitiveStatus];
	return [result shortValue];
}

- (void)setPrimitiveStatusValue:(int16_t)value_ {
	[self setPrimitiveStatus:@(value_)];
}

@dynamic uniqueID;

@dynamic flight;

@end

@implementation FlightInfoAttributes 
+ (NSString *)flightNbr {
	return @"flightNbr";
}
+ (NSString *)isOnline {
	return @"isOnline";
}
+ (NSString *)lastEdit {
	return @"lastEdit";
}
+ (NSString *)status {
	return @"status";
}
+ (NSString *)uniqueID {
	return @"uniqueID";
}
@end

@implementation FlightInfoRelationships 
+ (NSString *)flight {
	return @"flight";
}
@end

