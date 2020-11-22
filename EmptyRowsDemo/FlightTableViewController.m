//
//  FlightTableViewController.m
//  FlightBriefing
//
//  Created by Johan Nyman on 2016-11-15.
//  Copyright © 2016 JN Avionics. All rights reserved.
//

#import "FlightTableViewController.h"

#import "DataStore.h" //Just temporary for creating FRC without the current flight.


@interface FlightTableViewController()
{
}

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation FlightTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //Set automatically adjusted row height.
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.tableView.sectionFooterHeight = UITableViewAutomaticDimension;

    //Set estimates, change in subclasses
    self.tableView.estimatedRowHeight = 44;
    self.tableView.estimatedSectionHeaderHeight = 22;
    self.tableView.estimatedSectionFooterHeight = 22;
    
    //Remove empty rows at the bottom
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    //Set up the fetch Results Controller
    [self initializeFetchedResultsController];
    
    //Set up the search
    [self setupSearch];
   
    //Listen to changes to flight to update header, section titles and cells
     [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(endUpdate)
                                                  name:NOTIFICATIONFLIGHTWASUPDATED object:nil];

}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //Save the flight!
    [[NSNotificationCenter defaultCenter]
     postNotificationName:NOTIFICATIONMANAGEDOBJECTNEEDSSAVING
     object:self.flight];
}

#pragma mark - Search setup

- (void) setupSearch
{

    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil]; //init with nil to display results in same window
    
    // Use the current view controller to update the search results.
    self.searchController.searchResultsUpdater = self;
    self.searchController.obscuresBackgroundDuringPresentation = false;
    
    //This is the delegate
    self.searchController.delegate = self;
    
    //Always show the nav bar
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    //Overrideable features
    [self setupSearchBar:self.searchController.searchBar];
    [self installSearchController:self.searchController];
    
}

- (void) setupSearchBar:(UISearchBar *) searchBar
{
    searchBar.showsScopeBar = NO;
    [searchBar sizeToFit];
    
    //Set grayish so placeholder text is visible
    searchBar.searchTextField.backgroundColor = [UIColor secondarySystemBackgroundColor];

    
    NSString * placeHolderString = [self searchPlaceHolderString];
    
    searchBar.placeholder = placeHolderString;
    
    
    //Remove any suggestions
    UITextInputAssistantItem* item = searchBar.inputAssistantItem;
    item.leadingBarButtonGroups = [NSArray array];
    item.trailingBarButtonGroups = [NSArray array];
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;

}

- (NSString *) searchPlaceHolderString
{
    return @"Search...";
}


//May be overridden by subclasses
- (void) installSearchController:(UISearchController *) searchController
{
    
    // Install the search bar in the navigationitem
    self.navigationItem.searchController = searchController;
    self.definesPresentationContext = true; //So the searchbar does not remain on screen if we go to another screen

    self.navigationItem.hidesSearchBarWhenScrolling = true; //Always show
    //self.navigationItem.hidesSearchBarWhenScrolling = false; //Required in order to fix graphics bug in iOS 13...
    /*
     https://stackoverflow.com/questions/55561082/tableview-first-cell-hidden-under-search-bar-when-returning-to-view
     */

    searchController.modalInPresentation = YES;
    /* Correcting iOS 13 bug as described here:
    https://medium.com/@hacknicity/view-controller-presentation-changes-in-ios-13-ac8c901ebc4e
     */
    
    //Add a button for access!
    [self addSearchButton];
}

- (void) addSearchButton
{
    UIBarButtonItem * searchButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                      target:self
                                      action:@selector(showSearchBar)];
    
    self.navigationItem.rightBarButtonItem = searchButton;
    //(Could eventually use the array to add the search button with other items.)

}

- (IBAction) showSearchBar
{
    [self.searchController.searchBar becomeFirstResponder];
}

#pragma mark - Fetch setup

- (NSFetchRequest *) fetchRequestWithPredicate:(NSPredicate *) fetchPredicate
{
    NSLog(@"fetchRequestWithPredicate: must be implemented by %@", [self class]);
    return nil;
}
- (NSPredicate *) fetchPredicate
{
    NSLog(@"fetchPredicate must be implemented by %@", [self class]);
    return nil;
}

-(NSPredicate *) searchPredicateForString:(NSString *) searchText
{
    NSLog(@"searchPredicateForString: must be implemented by %@", [self class]);
    return nil;
}
-(NSString *) sectionNameKeyPath
{
    //Must be same as first sort descriptor key path
    NSLog(@"sectionNameKeyPath must be implemented by %@", [self class]);
    return nil;
}


- (void)initializeFetchedResultsController
{
    NSFetchRequest *request = [self fetchRequestWithPredicate:[self fetchPredicate]];
    NSManagedObjectContext *moc = [DataStore managedObjectContext];

    [self setFetchedResultsController:[[NSFetchedResultsController alloc]
                                       initWithFetchRequest:request
                                       managedObjectContext:moc
                                       sectionNameKeyPath:[self sectionNameKeyPath]
                                       cacheName:nil]];
    [[self fetchedResultsController] setDelegate:self];

    [self performNewFetch];
    
}

- (void) performNewFetch
{
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }

}


#pragma mark - Table view data source and delegate

- (NSString *) headerNibName
{
    NSLog(@"headerNibName must be implemented by %@", [self class]);
    return nil;
}

- (NSString *) cellClassName
{
    NSLog(@"cellClassName must be implemented by %@", [self class]);
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id< NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
   
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [self titleForHeaderWithSectionName:sectionInfo.name];
    } else
        return nil;
}

//May be overridden by subclasses to replace the section title
- (NSString *)titleForHeaderWithSectionName:(NSString *) name
{
    return name;
}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSString * nibName = [self headerNibName];
    
    //No view provided
    if (!nibName) return nil;
    
    SelfContainedTableViewHeaderFooterView * header = [SelfContainedTableViewHeaderFooterView headerForTableView:tableView
                                                                                                         section:section
                                                                                                      inNibNamed:nibName
                                                                                                 withModelSource:self];
    
    return header;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSString * nibName = [self headerNibName];

    if (!nibName) return 44.0; //Standard if no view provided (or override by subclass)
    
    return [SelfContainedTableViewHeaderFooterView headerHeightInNibNamed:nibName];
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    NSString * nibName = [self headerNibName];
    
    if (!nibName) return 0.0; //Standard if no view provided (or override by subclass)
    
    return [SelfContainedTableViewHeaderFooterView footerHeightInNibNamed:nibName];
}


- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    NSString * nibName = [self headerNibName];
    
    //No view provided, remove the footer
    if (!nibName) return [[UIView alloc] initWithFrame:CGRectZero];
    
    SelfContainedTableViewHeaderFooterView * footer = [SelfContainedTableViewHeaderFooterView footerForTableView:tableView
                                                                                                         section:section
                                                                                                      inNibNamed:nibName
                                                                                                 withModelSource:self];
    return footer;
}


-(UITableViewCell*)tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath
{

    NSString * className = [self cellClassName];
    
    //For stability
    if (!className || [className isEqualToString:@"UITableViewCell"]) {
        NSLog(@"tableView:cellForRowAtIndexPath: must be implemented by %@", [self class]);
        return [[UITableViewCell alloc] init];
    }
    
    SelfContainedTableViewCell * cell = [NSClassFromString(className) cellForTableView:tableView
                                                                           atIndexPath:indexPath
                                                                       withModelSource:self
                                                                           andDelegate:self];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Cell selected: %@",indexPath);
}


#pragma mark - Delegate for cells and header

/* If headers and footers are used these must be overriden by subclasses */

- (id) modelForHeaderInSection:(NSInteger)section
{
    NSLog(@"modelForHeaderInSection: must be implemented by %@", [self class]);
    return nil;
}

- (id) modelForFooterInSection:(NSInteger)section
{
    NSLog(@"modelForFooterInSection: must be implemented by %@", [self class]);
    return nil;
}

/* Cell model is provided by the Fetched Results Controller */
-(id)modelForIndexPath:(NSIndexPath*) indexPath inTableView:(UITableView *)tableView
{
    //Get the object
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //Allow subclasses to transform or add objects
    return [self modelWithObject:object];
}

//May be overridden by subclasses if more objects need to be returned.
- (id) modelWithObject:(NSObject *) modelPart
{
    return modelPart;
}

#pragma mark - Fetched Results controller delegate
/*
 For changes in the underlying model that is NOT already done by the user, such as giving new sortIndexes...
 
 Assume self has a property 'tableView' -- as is the case for an instance of a UITableViewController
 subclass -- and a method configureCell:atIndexPath: which updates the contents of a given cell
 with information from a managed object at the given index path in the fetched results controller.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (_changeIsUserDriven) return; //Do nothing if the user is rearranging the table
    
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    if (_changeIsUserDriven) return; //Do nothing if the user is rearranging the table
        
    switch(type) {
        case NSFetchedResultsChangeInsert:
            
            //And add the new section in the table
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            
            //And remove the section from the table
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeMove:
            NSLog(@"Section move detected, implement function.");
            break;
            
        case NSFetchedResultsChangeUpdate:
            NSLog(@"Section update detected, implement function.");
            break;

        default:
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (_changeIsUserDriven) return; //Do nothing if the user is rearranging the table
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView cellForRowAtIndexPath:indexPath]; //also configures the cell...
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (_changeIsUserDriven) {
        _changeIsUserDriven = NO;
        return; //Do nothing if the user is rearranging the table
    } else {
        [self.tableView endUpdates];
    }
    
}


#pragma mark - UISearchControllerDelegate

// Called after the search controller's search bar has agreed to begin editing or when
// 'active' is set to YES.
// If you choose not to present the controller yourself or do not implement this method,
// a default presentation is performed on your behalf.
//
// Implement this method if the default presentation is not adequate for your purposes.
//

- (void)presentSearchController:(UISearchController *)searchController {
    NSLog(@"Presenting search...");
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    NSLog(@"willPresentSearchController");
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    NSLog(@"didPresentSearchController");
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    NSLog(@"willDismissSearchController");
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    NSLog(@"Automatically dismissed search...");
}


#pragma mark - UISearchResultsUpdating


- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // update the filtered array based on the search text
    NSString *searchText = self.searchController.searchBar.text;
    
    // strip out all the leading and trailing spaces
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //If we have nothing we're not searching...
    if ([searchText isEqualToString:@""]) {
        
        //Reset the fetch request
        self.fetchedResultsController.fetchRequest.predicate = [self fetchPredicate];
        
    } else {
        
        NSLog(@"Searching for '%@'", searchText);
        
        //Make a predicate for the search
        NSPredicate * searchPredicate = [self searchPredicateForString:searchText];
        NSArray * predicates = [NSArray arrayWithObjects:searchPredicate, [self fetchPredicate], nil];
        NSCompoundPredicate * predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        self.fetchedResultsController.fetchRequest.predicate = predicate;
        
    }
    
    //Perform the actual search (or reset):
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }

    [self.tableView reloadData];
}


#pragma mark - Updating

- (IBAction) updateWasTriggered
{
    
        
        //We have a connection
        
        
        // Fire off an asynchronous task, giving UIKit the opportunity to redraw
        // with the HUD added to the view hierarchy.
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{

              //Actual work performed in subclass
                  [self startUpdate];

        });
        
    }
    

//internet available, perform update
- (void) startUpdate
{
    NSLog(@"startUpdate must be implemented in %@", [self class]);
    
    //It should end with a call on main thread to endUpdate.
    // IMPORTANT - Dispatch back to the main thread. Always access UI
    // classes (including MBProgressHUD) on the main thread.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self endUpdate];
    });
}

- (void) endUpdate
{
   
    
    //Remove Refresh symbol
    [self.refreshControl endRefreshing];
    
    //Refresh table View
    [self.tableView reloadData];
    
    /**
     @Apple Engineer:
     Here I want to redraw the view, otherwise it looks ugly after a "pull-down-to-refresh", rows disappearing or covered, search field in the middle of the screen, etc.
     This behaviour was introduced with iOS 13...
     */
}



@end
