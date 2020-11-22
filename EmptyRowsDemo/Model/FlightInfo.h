#import "_FlightInfo.h"

typedef enum {
    kFlightStatusOnline = 0,
    kFlightStatusDownloaded = 1,
    kFlightStatusInProgress = 2,
    kFlightStatusPendingSubmission = 3,
    kFlightStatusSent = 4
} FlightStatus;


@interface FlightInfo : _FlightInfo {}
// Custom logic goes here.

- (BOOL) isNewerThan:(FlightInfo *) other;

@end
