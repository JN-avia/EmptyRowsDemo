//
//  FlightInfoCell.m
//  FlightBriefing
//
//  Created by Johan Nyman on 2014-11-21.
//  Copyright (c) 2014 JN Avionics. All rights reserved.
//

#import "FlightInfoCell.h"
#import "FlightInfo.h"

typedef enum {
    ONLINE_SECTION = 0,
    OFFLINE_SECTION
} tableSection;

@interface FlightInfoCell ()

/* Help for date formatting */
@property (readonly) NSDateFormatter * dateFormatter;

@end

@implementation FlightInfoCell

static NSDateFormatter * df;

- (NSDateFormatter *) dateFormatter
{
    if (df == nil) {
        df = [[NSDateFormatter alloc] init];
        [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [df setDateFormat:@"ddHHmm"];
    }
    
    return df;
}

/* Model consists of the following
 * 1: FlightInfo
 * 2: Button
 */
-(void)configureWithModel:(id) model
{
    //Model is an array with objects
    //Cast model
    NSArray * modelArray = (NSArray *) model;
    
    //Get properties from modelarray
    //First object is Flight Info
    FlightInfo * info = (FlightInfo *) [modelArray objectAtIndex:0];
    //Then we have the button itself
    UIButton * button = (UIButton *) [modelArray objectAtIndex:1];
    
    
    //failsafe...
    if (info == nil) return;
    
    //Set up the cell
    self.labelFlightNbr.text = info.flightNbr;
    self.labelLogID.text = info.uniqueID;
    

    self.labelCalcTime.text = [self.dateFormatter stringFromDate:info.lastEdit];
    
    self.labelStatus.text = [self titleForStatus:info.statusValue];
    self.viewStatus.image = [self imageForStatus:info.statusValue];
    
    //Setup the button
    
    //Remove previous actions and targets
    [self.buttonFlight removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
    
    //Copy the properties from the provided model button
    
    [self.buttonFlight setTitle:button.currentTitle forState:UIControlStateNormal];
    [self.buttonFlight setTitleColor:button.currentTitleColor forState:UIControlStateNormal];
    
    //Find the selector and target (should only be one of each...)
    id target = [button.allTargets anyObject]; //Just one set
    NSString * selectorName = [[button actionsForTarget:target
                             forControlEvent:UIControlEventTouchUpInside] firstObject];
    SEL selector = NSSelectorFromString(selectorName);
    
    //Add the selector and target
    [self.buttonFlight addTarget:target
                          action:selector
                forControlEvents:UIControlEventTouchUpInside];
    
}

- (NSString *) titleForStatus:(FlightStatus) status
{
    NSString * title;
    
    switch (status) {
            
        case kFlightStatusOnline:
            title = @"Online";
            break;
            
        case kFlightStatusDownloaded:
            title = @"Downloaded";
            break;
            
        case kFlightStatusInProgress:
            title = @"In Progress";
            break;
            
        case kFlightStatusPendingSubmission:
            title = @"Pending Submission";
            break;
            
        case kFlightStatusSent:
            title = @"Sent";
            break;
            
        default:
            NSLog(@"Error, code must not come here! (%@)", [self class]);
            title = @"";
            break;
    }
    
    return title;
}

- (UIImage *) imageForStatus:(FlightStatus) status
{
    UIImage * statusImage;
    
    switch (status) {
            
        case kFlightStatusOnline:
            statusImage = [UIImage imageNamed:@"Online"];
            break;
            
        case kFlightStatusDownloaded:
            statusImage = [UIImage imageNamed:@"Downloaded"];
            break;
            
        case kFlightStatusInProgress:
            statusImage = [UIImage imageNamed:@"InProgress"];
            break;
            
        case kFlightStatusPendingSubmission:
            statusImage = [UIImage imageNamed:@"PendingSubmission"];
            break;
            
        case kFlightStatusSent:
            statusImage = [UIImage imageNamed:@"Sent"];
            break;
            
        default:
            NSLog(@"Error, code must not come here! (%@)", [self class]);
            statusImage = [UIImage imageNamed:@"Cross"];
            break;
    }
    
    return statusImage;
    
}


#pragma mark - Button handling
//Action and target set by model supplier


@end
