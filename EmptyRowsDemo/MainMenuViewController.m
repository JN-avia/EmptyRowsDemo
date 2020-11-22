//
//  MainMenuViewController.m
//  FlightBriefing
//
//  Created by Johan Nyman on 2013-11-14.
//  Copyright (c) 2013 JN Avionics. All rights reserved.
//



#import "DataStore.h"

/* ViewControllers */
#import "UIViewController+Alerts.h"
#import "MainMenuViewController.h"

#import "Flight.h" //including all model



@interface MainMenuViewController ()

@end

@implementation MainMenuViewController


//Tell this view controller to load new data
- (void) setFlight:(Flight *) flight
{
    //Start by saving the old pilotinputs (if exists)
    if (self.flight !=nil) [self saveContextInBackground];
    
    //set the flight:
    _flight = flight;
    
    //Flight could possibly be nil
    if (flight == nil) {
        //Adjust the title
        self.title = @"No flight selected";
    } else {
        
    
   
    //Set title
    self.title = [NSString stringWithFormat:@"%@",
                  self.flight.flightInfo.flightNbr];


}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Register for flight change notifications, and save the flight if it changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveContextInBackground)
                                                 name:NOTIFICATIONNEWFLIGHT object:nil];
    
    //Register for model change notifications, and save the object and flight if it changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveManagedObject:)
                                                 name:NOTIFICATIONMANAGEDOBJECTNEEDSSAVING object:nil];
        
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //Correct the title if the flight has been removed
    if (self.flight == nil) self.title = @"No flight selected";
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Start by selecting flight if not set
    //(This must not be made in viewDidLoad since the view is not yet presented at that time)
    //"Unbalanced calls to begin/end appearance transitions for ..." is fixed by presenting
    //the SelectFlightViewController in viewDidAppear.
    if (self.flight == nil) {
        [self selectFlight];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Buttons

- (void) selectFlight
{
    //present the flight selector
    [self presentViewController:self.selectController animated:YES completion:nil];
}

- (IBAction)resetMemoryContext {
    //@TODO: This is where the problem starts...
    
}



#pragma mark - ViewControllers

- (UINavigationController *) selectController
{
    if (!_selectController) {
        _selectController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectFlightViewController"];
        
        //Set delegate of the SelectFlightViewController
        SelectFlightViewController * svc = [_selectController.viewControllers objectAtIndex:0];
        svc.delegate = self;
        
        //Do not discard by swiping down. (iOS13)
        svc.modalInPresentation = YES;
    }
    
    return _selectController;
}


#pragma mark - Select Flight Delegate

- (void) flightWasSelected: (Flight *) flight
{
    //Set as current flight
    self.flight = flight;
    
    //Dismiss the view (unless all flights removed)
    if (flight != nil)
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) flightWasDeleted:(Flight *)flight
{
    //If it was the current flight, set to nil
    if ([flight.flightInfo.flightNbr isEqualToString:self.flight.flightInfo.flightNbr]) {
        self.flight = nil;
    }
}

- (void) flightSelectionWasCancelled
{
    
    //Don't dismiss if no flight is selected!
    if (self.flight == nil) {
        [[UIViewController currentViewController] showAlertWithTitle:@"You must select a flight." message:nil buttonTitle:@"OK"];
    } else {
        //Just dismiss the view, current selection shall not change.
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}



#pragma mark - Core Data Stuff


- (void) saveManagedObject:(NSNotification *) notification
{
    NSManagedObject * object = notification.object;
    
    NSLog(@"Object context: %@", object.managedObjectContext);
    
    //Save the object immediately
    //[object.managedObjectContext MR_saveOnlySelfAndWait];
    
    //Then save the whole flight
    [self saveContextInBackground];
    
}

- (void) saveContextInBackground
{
    NSLog(@"Flight context: %@", self.flight.managedObjectContext);
    
    
    [DataStore saveContextAsyncWithCompletion:^(BOOL success, NSError *error) {
        //When done saving
        if (error) {
            NSString * logStr = [NSString stringWithFormat:@"Error saving context: %@", error.localizedDescription];
            NSLog(@"%@",logStr);
            

#if DEBUG
            [[UIViewController currentViewController] showAlertWithTitle:@"DEBUG INFO" message:@"Could not save changes to flight" buttonTitle:@"OK"];
#endif
        } else if (!success){
            //saveWithBlock returns NO if there is nothing to save...
            NSLog(@"No changes in context to save");

#if COREDEBUG
            [[UIViewController currentViewController] showAlertWithTitle:@"DEBUG INFO" message:@"No changes in context to save" buttonTitle:@"OK"];
#endif

        } else {
            NSLog(@"Context saved");
            
            //Post a notification that flight have new values
            [[NSNotificationCenter defaultCenter]
             postNotificationName:NOTIFICATIONFLIGHTWASUPDATED
             object:self.flight];

#if COREDEBUG
            [[UIViewController currentViewController] showAlertWithTitle:@"DEBUG INFO" message:@"Context saved" buttonTitle:@"OK"];
#endif
        }
        NSLog(@"Flight context: %@", self.flight.managedObjectContext);
        
        
    }];
    
 }





@end
