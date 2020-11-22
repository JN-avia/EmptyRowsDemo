#import "FlightInfo.h"

@interface FlightInfo ()

// Private interface goes here.

@end

static NSDateFormatter * df;

@implementation FlightInfo

// Custom logic goes here.


/* Tells whether this flight is newer than the other. */
- (BOOL) isNewerThan:(FlightInfo *) other
{
    NSTimeInterval timeDiff = [self.lastEdit timeIntervalSinceDate:other.lastEdit];
    
    return (timeDiff > 0);
}


@end
