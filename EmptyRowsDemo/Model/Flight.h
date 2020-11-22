#import "_Flight.h"

//Rest of the model
#import "FlightInfo.h"



//Notification names
static NSString *  NOTIFICATIONNEWFLIGHT = @"Flight was replaced"; //includes the flight as object
static NSString *  NOTIFICATIONFLIGHTWASUPDATED = @"Flight Was Updated"; //includes the flight as object
static NSString *  NOTIFICATIONMANAGEDOBJECTNEEDSSAVING = @"Save Object and flight"; //Include the object in question
static NSString *  NOTIFICATIONWEATHERWASUPDATED = @"Weather Changed";



@interface Flight : _Flight {}

@end
