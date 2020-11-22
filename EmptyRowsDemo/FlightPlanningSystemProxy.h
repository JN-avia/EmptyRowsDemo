//
//  FlightPlanningSystemProxy.h
//  FlightBriefing
//
//  Created by Johan Nyman on 2014-11-11.
//  Copyright (c) 2014 JN Avionics. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FlightInfo;
@class Flight;
@class SelectFlightViewController;


@interface FlightPlanningSystemProxy : NSObject
{

}

/* The view controller presenting data from the FPS.
 * The viewcontroller should be updated when a connection is established
 * or lost.
 */
@property (strong) SelectFlightViewController * controller;



/* Called by controller to establish connection.
 * Callback to controller method connectionEstablished.
 */
- (void) connectToFPS;

/* Called by controller to download the given flight.
 * Download must take place in a background thread, with
 * callbacks on the main thread.
 * Callbacks are given to the controller by calling
 * downloadProgress:message:
 */
- (void) downloadFlightForInfo:(FlightInfo *) info;




/* Reset the timeout timer that resets connection and online flights
 after a certain time. Call this when connection is used to reset the timer.*/
- (void) resetTimer;


@end
