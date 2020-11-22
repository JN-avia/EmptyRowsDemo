//
//  MainMenuViewController.h
//  FlightBriefing
//
//  Created by Johan Nyman on 2013-11-14.
//  Copyright (c) 2013 JN Avionics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectFlightViewController.h" //For the protocol declaration

@class Flight;


@interface MainMenuViewController : UIViewController <SelectFlightDelegate>

@property(strong, nonatomic) Flight * flight;


//Hang on to this to avoid recreation every time.
@property (strong, nonatomic) UINavigationController *selectController;

//Devinfo
@property (strong, nonatomic) IBOutlet UIButton * infoButton;
@property (strong, nonatomic) IBOutlet UIButton * crashButton;


- (IBAction) selectFlight;

- (void) saveContextInBackground;
- (void) saveManagedObject:(NSManagedObject*) object;

@end
