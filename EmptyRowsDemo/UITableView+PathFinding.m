//
//  UITableView+PathFinding.m
//  FlightBriefing
//
//  Created by Johan Nyman on 2013-12-09.
//  Copyright (c) 2013 JN Avionics. All rights reserved.
//

#import "UITableView+PathFinding.h"

@implementation UITableView (PathFinding)

- (NSIndexPath *) indexPathForView: (UIView *) aView
{
    //Get the indexpath
    CGPoint viewPosition = [aView convertPoint:CGPointZero toView:self];
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:viewPosition];
    
    //Testing
    //NSLog(@"ViewPos: (%.f,%.f), indexpath: (%d,%d)", viewPosition.x, viewPosition.y, indexPath.section, indexPath.row);
    
    return indexPath;
}

- (NSInteger) totalIndexForIndexPath:(NSIndexPath *) path
{
    NSInteger sum = 0;
    //Take the number of cells for each previous section
    for (int i = 0; i < path.section; i++) {
        sum += [self.dataSource tableView:self numberOfRowsInSection:i];
    }
    //add the number up til this row in this section
    sum += path.row;
    
    return sum;
    
}


@end
