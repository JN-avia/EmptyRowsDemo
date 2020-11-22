//
//  FlightInfoCell.h
//  FlightBriefing
//
//  Created by Johan Nyman on 2014-11-21.
//  Copyright (c) 2014 JN Avionics. All rights reserved.
//

#import "SelfContainedTableViewCell.h"

@interface FlightInfoCell : SelfContainedTableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelFlightNbr;
@property (strong, nonatomic) IBOutlet UILabel *labelLogID;
@property (strong, nonatomic) IBOutlet UILabel *labelCalcTime;
@property (strong, nonatomic) IBOutlet UILabel *labelStatus;
@property (strong, nonatomic) IBOutlet UIImageView *viewStatus;

@property (strong, nonatomic) IBOutlet UIButton *buttonFlight;

@end
