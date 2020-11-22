//
//  UITableView+PathFinding.h
//  FlightBriefing
//
//  Created by Johan Nyman on 2013-12-09.
//  Copyright (c) 2013 JN Avionics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (PathFinding)

//Find the indexpath for the cell containing the subview (UIButton, textfield, ...) given as argument.
- (NSIndexPath *) indexPathForView: (UIView *) aView;

//Find the sum of all cells up to and including this indexPath
- (NSInteger) totalIndexForIndexPath:(NSIndexPath *) path;

@end
