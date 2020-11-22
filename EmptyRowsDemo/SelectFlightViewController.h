//
//  SelectFlightViewController.h
//  FlightBriefing
//
//  Created by Johan Nyman on 2013-11-14.
//  Copyright (c) 2013 JN Avionics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlightTableViewController.h"

typedef enum : NSUInteger {
    FlightInfoCellButtonTypeDownload,
    FlightInfoCellButtonTypeAlreadyDownloaded,
    FlightInfoCellButtonTypeUpdate,
    FlightInfoCellButtonTypeShow,
}     FlightInfoCellButtonType;

@protocol SelectFlightDelegate <NSObject>

- (void) flightWasSelected: (Flight *) flight;
- (void) flightWasDeleted: (Flight *) flight;
- (void) flightSelectionWasCancelled;

@end

@class FlightPlanningSystemProxy;

@interface SelectFlightViewController : FlightTableViewController

@property (strong) FlightPlanningSystemProxy * flightPlanningSystem;
@property (assign) id <SelectFlightDelegate> delegate;

/* Actions */
- (IBAction)cancelSelection:(id)sender;

/* Buttons in the tableViewCells */
- (IBAction)downloadFlight:(id)sender;
- (IBAction)updateFlight:(id)sender;
- (IBAction)showFlight:(id)sender;
//Cell can ask upon creation which type of button to show
- (FlightInfoCellButtonType) buttonTypeForFlightInfo:(FlightInfo *) flightInfo;

/* Callback methods for server connection */

//Called by proxy when connection is established, to update view
- (void) connectionEstablished;


//Called by proxy when connection is established, and flight info are being downloaded, to update the view
- (void) connectionEstablishedWithFlightInfoItem:(FlightInfo *) info number:(NSUInteger) nbr of:(NSUInteger) total;


//Called by proxy when connection is established, and flights available, to update the view
- (void) connectionEstablishedWithFlightInfoItems:(NSArray *) items;


/* Called by proxy when all is done and a new flight is available for display */
- (void) downloadCompletedOfModel:(Flight *) flight;

/* Called by proxy when connection is lost, to update view
   If alertUser is YES, a message will be shown */
- (void) connectionLost:(BOOL) alertUser;



@end
