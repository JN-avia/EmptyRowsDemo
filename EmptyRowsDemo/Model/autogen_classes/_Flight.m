// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Flight.m instead.

#import "_Flight.h"

@implementation FlightID
@end

@implementation _Flight

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Flight" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Flight";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Flight" inManagedObjectContext:moc_];
}

- (FlightID*)objectID {
	return (FlightID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic name;

@dynamic flightInfo;

@end

@implementation FlightAttributes 
+ (NSString *)name {
	return @"name";
}
@end

@implementation FlightRelationships 
+ (NSString *)flightInfo {
	return @"flightInfo";
}
@end

