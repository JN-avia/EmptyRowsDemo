//
//  UIView+Logging.h
//  FlightBriefing
//
//  Created by Johan Nyman on 2017-01-13.
//  Copyright © 2017 JN Avionics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Logging)

- (void) logFrameWithTitle: (NSString *) title;

- (void) logBoundsWithTitle: (NSString *) title;

@end
