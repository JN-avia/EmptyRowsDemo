//
//  FlightTableViewController.h
//  FlightBriefing
//
//  Created by Johan Nyman on 2016-11-15.
//  Copyright © 2016 JN Avionics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Flight.h" //the whole model
#import "SelfContainedTableViewCell.h"
#import "SelfContainedTableViewHeaderFooterView.h"



@interface FlightTableViewController : UITableViewController <SelfContainedTableViewCellModelSource, SelfContainedTableViewHeaderFooterModelSource,
    NSFetchedResultsControllerDelegate,
    UISearchControllerDelegate,
    UISearchResultsUpdating>
{
    BOOL _changeIsUserDriven; //indicates whether it is the user that rearranges the table or not.
}

//The flight model
@property (strong) Flight * flight;

//The searchcontroller, for access from subclasses
@property (nonatomic, strong) UISearchController *searchController;


//Overrideable features
- (NSString *) searchPlaceHolderString;
- (void) installSearchController:(UISearchController *) searchController;

//For subclasses to trigger a new fetch if a change is deeper than the fetched entities but affects them. (e.g Waypoints)
- (void) performNewFetch;

//May be overridden by subclasses to replace the section title
- (NSString *)titleForHeaderWithSectionName:(NSString *) name;





//Called when the tableView is pulled down
- (IBAction) updateWasTriggered;

//Call to subclasses to perform the actual update
- (void) startUpdate;

//Called by subclasses when the update is complete
- (void) endUpdate;

- (IBAction) showSearchBar;

@end
