//
//  SelectFlightViewController.m
//  FlightBriefing
//
//  Created by Johan Nyman on 2013-11-14.
//  Copyright (c) 2013 JN Avionics. All rights reserved.
//



#import "SelectFlightViewController.h"

#import "UITableView+PathFinding.h"

#import "FlightPlanningSystemProxy.h"

#import "UIViewController+Alerts.h"

#import "Flight.h"

#import "DataStore.h"





static NSString * VIEWBASENAME = @"FlightInfoCell";
static NSString * FPSPROXYBASENAME = @"FlightPlanningSystemProxy";
static NSString * ONLINE_SECTION_TITLE = @"Online Flights:";
static NSString * OFFLINE_SECTION_TITLE = @"Downloaded Flights:";


@interface SelectFlightViewController() <NSFetchedResultsControllerDelegate>

@end

@implementation SelectFlightViewController

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 85;
    
    //Create a connection proxy
    self.flightPlanningSystem = [[FlightPlanningSystemProxy alloc] init];
    self.flightPlanningSystem.controller = self;
    
}

- (void) viewWillAppear:(BOOL)animated
{
    
      
    //update the header
    [self refreshTableHeaderView];
    
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    
#if COREDEBUG
    // Checking the database...
    NSArray * allFlights = [DataStore fetchAll:[Flight entityName]];
    NSArray * allInfo = [DataStore fetchAll:[FlightInfo entityName]];
    
    NSMutableString * message = [NSMutableString stringWithFormat:@"Database contains %zd flights:\n", allFlights.count];
    for (Flight * flight in allFlights) {
        [message appendFormat:@"    %@ - %@\n", flight.departure.icao, flight.destination.icao];
    }
    
    [message appendFormat:@"\n\nDatabase contains %zd infos:\n", allInfo.count];
    for (FlightInfo * info in allInfo) {
        [message appendFormat:@"    %@\n", info.flightLogID];
    }
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"DEBUG INFO"
                                                                    message:message
                                                             preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
#endif
    
    [super viewDidAppear:animated];
}

#pragma mark - Initialization and setup

-(NSString *) searchPlaceHolderString
{
    return @"Why does this end up way down the table after refresh?";
}


-(NSString *) sectionNameKeyPath
{
    return @"isOnline";
}

- (NSString *) headerNibName
{
    return nil;
}

- (NSString *) cellClassName
{
    return VIEWBASENAME;
}


- (NSFetchRequest *) fetchRequestWithPredicate:(NSPredicate *) fetchPredicate
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"FlightInfo"];
    
    NSSortDescriptor * onlineSorter = [NSSortDescriptor sortDescriptorWithKey:@"isOnline" ascending:NO];
    
    //Sort on  last edit date of the flight information, newest first
    NSSortDescriptor * editSorter = [NSSortDescriptor sortDescriptorWithKey:@"lastEdit" ascending:NO];
    
    [request setSortDescriptors:@[onlineSorter, editSorter]];
    
    [request setPredicate:fetchPredicate];
    
    return request;
}

- (NSPredicate *) fetchPredicate
{
    //Return all flights
    return nil;
}


-(NSPredicate *) searchPredicateForString:(NSString *) searchText
{
    
    
    //Flight Nbr
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF.flightNbr contains[c] %@",searchText];
    return searchPredicate;
}

- (void) addSearchButton
{
    //Nope, don't!
}





#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = [super tableView:tableView numberOfRowsInSection:section];
    NSLog(@"FRC has %ld rows in section %ld",(long)rows,(long)section);
    return rows;

}


- (NSString *)titleForHeaderWithSectionName:(NSString *) name
{
    NSString * title = @"Undefined";
    
    //The provided name is the value of the "isOnline" attribute in that section
    if ([name isEqualToString:@"0"]) {
        title = OFFLINE_SECTION_TITLE;
    } else if ([name isEqualToString:@"1"]) {
        title = ONLINE_SECTION_TITLE;
    }
    
    return title;
}

- (BOOL) isOnlineSection:(NSInteger) section
{
    NSString * title = [self tableView:self.tableView
               titleForHeaderInSection:section];
    return [title isEqualToString:ONLINE_SECTION_TITLE];
}
- (BOOL) isOfflineSection:(NSInteger) section
{
    NSString * title = [self tableView:self.tableView
               titleForHeaderInSection:section];
    return [title isEqualToString:OFFLINE_SECTION_TITLE];
}

- (UIView *) viewWithText:(NSString *) text
{
    
    CGFloat height = self.tableView.estimatedRowHeight;
    CGRect frame = CGRectMake(0, 0, 1, height);
    UILabel * textLabel = [[UILabel alloc] initWithFrame:frame];
    //Configure view (set text)
    textLabel.text = text;
    textLabel.numberOfLines = 0;
    textLabel.textAlignment = NSTextAlignmentCenter;
    
    /*
     //Make the label expand in its superview
     textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
     
     //Create a content view to fit the label
     UIView * headerContentView = [[UIView alloc] initWithFrame:frame];
     
     [headerContentView addSubview:textLabel];
     
     textLabel.backgroundColor = [UIColor greenColor];
     
     for (NSLayoutConstraint * constraint in textLabel.constraints) {
     NSLog(@"%@",constraint);
     constraint.priority = 500;
     }
     
     // Constrain to left margin using Layout Anchors
     UILayoutGuide *margin = headerContentView.layoutMarginsGuide;
     [textLabel.leadingAnchor constraintEqualToAnchor:margin.leadingAnchor constant:56.0].active = YES;
     
     return headerContentView;
     */
    return textLabel;
}

- (UIView *) offlineCell
{
    return [self viewWithText:@"Connect to internet to view online flights."];
}

- (UIView *) refreshCell
{
    return [self viewWithText:@"Pull down to view online flights."];
}

- (UIView *) noOnlineFlightsCell
{
    return [self viewWithText:@"No flights found online. Pull down to try again."];
}

- (UIView *) demoCell
{
    return [self viewWithText:@"Online flights not available in demo mode. Tap settings in the upper right corner and enter your company name."];
}

-(UITableViewCell*)tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath
{
    //Normal cell
    NSString * className = VIEWBASENAME;
    
    SelfContainedTableViewCell * cell = [NSClassFromString(className) cellForTableView:tableView
                                                                           atIndexPath:indexPath
                                                                       withModelSource:self
                                                                           andDelegate:self];
    
    return cell;
}


-(void) refreshTableHeaderView
{
    
    //Wait until the tableview have reloaded everything for correctness...
    
    [UIView animateWithDuration:0.0
                          delay:0.2
                        options:UIViewAnimationOptionAllowUserInteraction |
     UIViewAnimationOptionBeginFromCurrentState |
     UIViewAnimationOptionTransitionNone
                    animations:^{
        UIView * tableHeader = nil;
        
        NSUInteger numberOfSections = [self.tableView numberOfSections];
        
        BOOL firstSectionIsOnline = [self isOnlineSection:0];
        
        NSUInteger onlineFlights = 0;
        
        if (firstSectionIsOnline) onlineFlights = [self.tableView numberOfRowsInSection:0];
        
        
        if (numberOfSections == 2) {
            //We have two sections, online and offline
            tableHeader = nil; //Remove the header
        } else if (firstSectionIsOnline &&  (onlineFlights > 0)){
            //Showing downloaded flights, remove header
            tableHeader = nil;
        } else {
            //No flights were found
            tableHeader = [self noOnlineFlightsCell];
            
            //(Does not work if search in progress)
            if ([self.searchController isActive]) tableHeader = nil;
            
        }
        
        self.tableView.tableHeaderView = tableHeader;

    } completion:nil];
}


/**** Deletion of rows, only for saved items ******/

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Only offline section can be edited
    return [self isOfflineSection:indexPath.section];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Only deletion
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Get the flight and delete it
    FlightInfo * info = (FlightInfo *) [[self modelForIndexPath:indexPath inTableView:tableView] firstObject];
    Flight * flight = info.flight;
    
    //Unless the flight is pending submission!
    if (info.statusValue == kFlightStatusPendingSubmission) {
        [self showAlertWithTitle:@"Cannot delete flight while status is Pending Submission" message:@"" buttonTitle:@"OK"];
    } else {
        //Continue
        
        //Let the main menu take action if it's the current flight.
        [self.delegate flightWasDeleted:info.flight];
        
        //Delete the entity
        [DataStore deleteObject:flight];
        
        //Log for bug finding purposes
        NSString * logMessage = [NSString stringWithFormat:@"Trying to delete flight %@", info.flightNbr];
        
        NSLog(@"%@",logMessage);
        
        //Save context synchronously
        NSError * error;
        [DataStore saveContextWithError:&error];
        if (error) {
            NSString * message = @"Could not save deletion of flight";
            NSLog(@"%@",message);
            NSLog(@"%@",error.localizedDescription);
        }
        
        //View update done by FRC delegate
        
        //But we also need to refresh the online flights if it exists and the deleted flight exists there.
        if ([self.tableView numberOfSections] > 0 && [self isOnlineSection:0]) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

#pragma mark - Model suppliers for cell content

//Model supplier for cells
- (id) modelWithObject:(NSObject *) modelPart
{
    //The modelPart is a FlightInfo
    FlightInfo * info = (FlightInfo *) modelPart;
    
    //Use it to get the correct buttonType and form a button
    FlightInfoCellButtonType type = [self buttonTypeForFlightInfo:info];
    UIButton * cellButton = [self buttonForType:type];
    
    //Put in together in array
    NSArray * modelArray = [NSArray arrayWithObjects:modelPart, cellButton, nil];
    
    return modelArray;
}


#pragma mark - Core Data Saving

- (void)saveContextInBackground {
    
    //This has to be the default context since the flight is not saved there before.
    [DataStore saveContextAsyncWithCompletion:^(BOOL success, NSError *error) {
        NSString * logString = @"SelectFlightViewController: Background save...";
        if (success) {
            logString = @"The downloaded flight was successfully saved in the context.";
        } else if (error) {
            logString = [NSString stringWithFormat:@"Error saving downloaded flight in context: %@", error.description];
        } else {
            logString = @"Nothing to save. This is strange, we just downloaded a new flight!";
        }
        //append to log
        NSLog(@"%@",logString);
    }];
    
}



#pragma mark -  Search bar delegate

//Override to also update the header view when the search is dismissed
- (void)didDismissSearchController:(UISearchController *)searchController {
    [self refreshTableHeaderView];
    [super didDismissSearchController:searchController];

}

#pragma mark - Buttons

- (IBAction)cancelSelection:(id)sender {
    
    //Call the delegate which should dismiss this view controller
    if ((self.delegate != nil) && [self.delegate respondsToSelector:@selector(flightSelectionWasCancelled)]) {
        [self.delegate flightSelectionWasCancelled];
    } else {
        NSLog(@"No delegate set for %@", [self class]);
        //try to hide the view
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void) startUpdate
{
    //We have a connection
    
    
    //Create connection

        [self.flightPlanningSystem connectToFPS];
        
        //Remove all the current online flights
        [DataStore clearMemoryContext];

    
    //Wait for service return and handle in connectionEstablished
}

//override to update table header
- (void) endUpdate
{
    [super endUpdate];
    [self refreshTableHeaderView];
}



#pragma mark - Proxy Callbacks
- (void) connectionEstablished
{
     
    //Continue in connectionEstablishedWithFlightInfoItem: number: of:
    // or connectionEstablishedWithFlightInfoItems:(NSArray *)items
    
    //This one is also called when reachability detects a connection, so change the header
    [self refreshTableHeaderView];
    
}

- (void) connectionLost:(BOOL) alertUser
{
    if (alertUser) {
        //Show message
      [self showAlertWithTitle:@"Lost connection to server" message:@"" buttonTitle:@"OK"];
    }
    
    //remove all online flights
    [DataStore clearMemoryContext];
    
    /**
     @Apple Engineer:
     Here I want to reload the tableView online section. (It should be done by the FRC delegate, but this does not seem to happen after a time-out, especially not when the view is not in the window hierarchy.
     If this is executed while the view is not visible, extra empty rows will be displayed when returning to this view.
     */

    
    
    [self endUpdate];
    
}



- (void) connectionEstablishedWithFlightInfoItems:(NSArray *)items
{
    
    //Reload table, Remove HUD etc...
    [self endUpdate];
    
    //Message if there was no online flight
    if (items.count == 0) {
        [self showAlertWithTitle:@"No flights found online" message:@"" buttonTitle:@"OK"];
    }
    
    
}




- (void) downloadCompletedOfModel:(Flight *)flight
{
    //Add log info
    NSString * logstr = [NSString stringWithFormat:@"Flight %@ downloaded.", flight.flightInfo.flightNbr];
    NSLog(@"%@",logstr);
    
    //Set status
    flight.flightInfo.statusValue = kFlightStatusDownloaded;
    
    //Check if an older flight exists and can be replaced
    FlightInfo * oldFlight = [self olderFlightFor:flight.flightInfo];
    if (oldFlight) {
        
            [self replaceFlight:oldFlight.flight withNewerFlight:flight];
    }
    
    [self downloadCompletion];
        
}
    
    

- (void) downloadCompletion
{
    //Save the MOC synchronously
    NSError * error;
    [DataStore saveContextWithError:&error];
    if (error) {
        NSString * message = @"Could not save downloaded flight";
       
        NSLog(@"%@",message);
        NSLog(@"%@",error.localizedDescription);
    }
    
    //Insertion in offline section made by FRC
    
    //Update the online info
    [self.tableView beginUpdates];
    //Find out what the index path will be:
    
    //For now, just reload the online section
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView endUpdates];
    

}







#pragma mark - Actions in table view cells

- (UIButton *) buttonForType:(FlightInfoCellButtonType) type
{
    UIButton * button = [[UIButton alloc] init];
    
    SEL selector;
    
    //Configure the button (Download or show flight)
    switch (type) {
            
        case FlightInfoCellButtonTypeDownload:
            [button setTitle: @"Download" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
            selector = NSSelectorFromString(@"downloadFlight:");
            break;
            
        case FlightInfoCellButtonTypeAlreadyDownloaded:
            [button setTitle: @"Download" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor systemPinkColor] forState:UIControlStateNormal];
            selector = NSSelectorFromString(@"downloadFlight:");
            break;
            
        case FlightInfoCellButtonTypeUpdate:
            [button setTitle: @"Update" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
            selector = NSSelectorFromString(@"updateFlight:");
            break;
            
        case FlightInfoCellButtonTypeShow:
            [button setTitle: @"Show Flight" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor systemGreenColor] forState:UIControlStateNormal];
            selector = NSSelectorFromString(@"showFlight:");
            break;
            
        default:
            NSLog(@"Error, code should not get here!");
            selector = nil;
            [button setTitle: @"Error" forState:UIControlStateNormal];
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            break;
    }
    //Add the selector and target
    [button addTarget:self
               action:selector
     forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (IBAction)downloadFlight:(id)sender {
    
    //Get flight info
    FlightInfo * selectedFlight = [self flightInfoForButton:(UIButton *) sender];
    NSString * selectedID = selectedFlight.uniqueID;
    
    //See if it already exists
    if ([self checkIfExist:selectedID]) {
        
        //The flight exists
        //Tell the user
        NSString * title = @"Flight already downloaded";
        NSString * info = [NSString stringWithFormat:@"id: %@", selectedID];
        NSLog(@"%@, %@", title, info);
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:title
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        
        /* Start Download flight
         *
         * Important! The downloading has to be on a background thread,
         * With callbacks to downloadProgress:message on the main thread.
         * Otherwise the UI (HUD) won't be updated...
         */
        [self.flightPlanningSystem downloadFlightForInfo:selectedFlight];
        
        //Wait for callback in downloadCompletedOfModel
    }
}

//sender is the show flight button, possibly nil to REMOVE the active flight.
- (IBAction)showFlight:(id)sender {
    
    //Get flight info
    FlightInfo * selectedFlight = nil;
    if (sender != nil) selectedFlight = [self flightInfoForButton:(UIButton *) sender];
    
    //Call the delegate which should set this flight in the main menu
    if ((self.delegate != nil) && [self.delegate respondsToSelector:@selector(flightWasSelected:)]) {
        [self.delegate flightWasSelected:selectedFlight.flight];
        
    } else {
        NSLog(@"No delegate set for %@", [self class]);
    }
    
}

- (IBAction)updateFlight:(id)sender
{
    /* Same as download flight,
     * but when the flight is completely downloaded,
     * we will check if an older version exists, and if that is the case,
     * replace Flight data, but keep pilot input.
     */
    [self downloadFlight:sender];
}
- (void) replaceFlight:(Flight*) oldFlight withNewerFlight:(Flight *) newFlight
{
   
    //Now, remove the old flight and just keep the new one.
    [DataStore deleteObject:oldFlight];
    
    //logging
    NSString * logMessage = [NSString stringWithFormat:@"Updated flight %@ from %@ to %@",newFlight.flightInfo.flightNbr, oldFlight.flightInfo.uniqueID, newFlight.flightInfo.uniqueID];
    NSLog(@"%@", logMessage);
    
    //The FRC takes care of the rest
    
}


//Convenience factoring for button actions
- (FlightInfo *) flightInfoForButton:(UIButton *)button
{
    
    NSIndexPath * indexPath = [self.tableView indexPathForView:button];
    
    //Get flight info
    FlightInfo * selectedFlight = [[self modelForIndexPath:indexPath inTableView:self.tableView] firstObject];
    
    return selectedFlight;
    
}

- (FlightInfoCellButtonType) buttonTypeForFlightInfo:(FlightInfo *) flightInfo
{
    FlightInfoCellButtonType type = FlightInfoCellButtonTypeShow; //Already downloaded per default
    
    //Is online?
    if (flightInfo.isOnlineValue == YES) {
        type = FlightInfoCellButtonTypeDownload;
        
        //Older version downloaded?
        if ([self olderFlightFor:flightInfo] != nil) {
            type = FlightInfoCellButtonTypeUpdate;
        }
        
        //Same version downloaded
        if ([self checkIfExist:flightInfo.uniqueID]) {
            type = FlightInfoCellButtonTypeAlreadyDownloaded;
        }
        
    }
    
    return type;
}

//Returns the older flight if it exists, otherwise nil
- (FlightInfo *) olderFlightFor:(FlightInfo *) flightInfo
{
    //Filter on uniqueID and see if there's a hit
    NSPredicate * selfPredicate = [NSPredicate predicateWithFormat:@"%K like %@", @"uniqueID", flightInfo.uniqueID]; //This will have been downloaded by now, so avoid to have it returned.
    selfPredicate = [NSCompoundPredicate notPredicateWithSubpredicate:selfPredicate];
    NSPredicate * downloadedPredicate = [NSPredicate predicateWithFormat:@"%K == %@", @"isOnline",@NO];
    NSPredicate * existPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[downloadedPredicate,selfPredicate]];
    
    //Filter downloaded flights
    
    //Temporary solution
    NSArray * allFlights = [DataStore fetchAll:[FlightInfo entityName]];
    NSArray * testArray = [allFlights filteredArrayUsingPredicate:existPredicate];
    FlightInfo * otherFlight = [testArray firstObject];
    
#if debug
    //DO NOT USE IN PRODUCTION

    //For some strange reason this does not work
    NSArray * filteredFlights = [DataStore fetchAll:[FlightInfo entityName]
                                      withPredicate:existPredicate
                                           sortedBy:nil];
    
    FlightInfo * otherFlight2 = [filteredFlights firstObject];
    
    NSLog(@"Other 1: %@, other 2: %@", otherFlight.uniqueID, otherFlight2.uniqueID);

#endif


    //Try the other flightInfo to see if it's older (See if this one is newer)
    FlightInfo * retval = nil;
    if ([flightInfo isNewerThan:otherFlight]) retval = otherFlight;
    return retval;
    
}

- (BOOL) checkIfExist:(NSString *) uniqueID
{
    //Create predicate
    NSPredicate * idPredicate = [NSPredicate predicateWithFormat:@"%K like %@", @"uniqueID", uniqueID];
    NSPredicate * downloadedPredicate = [NSPredicate predicateWithFormat:@"%K == %@", @"isOnline",@NO];
    NSPredicate * existPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[downloadedPredicate,idPredicate]];
    
    //Filter downloaded flights
    NSArray * filteredFlights = [DataStore fetchAll:[FlightInfo entityName]
                                      withPredicate:existPredicate
                                           sortedBy:nil];
    
    return filteredFlights.count > 0;
}




@end
