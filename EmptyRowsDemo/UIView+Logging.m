//
//  UIView+Logging.m
//  FlightBriefing
//
//  Created by Johan Nyman on 2017-01-13.
//  Copyright © 2017 JN Avionics. All rights reserved.
//

#import "UIView+Logging.h"

@implementation UIView (Logging)

#define DEBUGFRAMES 0

- (void) logFrameWithTitle: (NSString *) title
{
#if DEBUGFRAMES
    NSLog(@"%@: origin(%0.f,%0.f), size(%0.f,%0.f)", title, self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
#endif
}

- (void) logBoundsWithTitle: (NSString *) title
{
#if DEBUGFRAMES
    NSLog(@"%@: origin(%0.f,%0.f), size(%0.f,%0.f)", title, self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
#endif
}


@end
