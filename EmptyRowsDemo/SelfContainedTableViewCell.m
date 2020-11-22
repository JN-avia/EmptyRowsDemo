//
//  SelfContainedTableViewCell.m
//  FlightBriefing
//
//  Created by Johan Nyman on 2014-10-29.
//  Copyright (c) 2014 JN Avionics. All rights reserved.
//

/******************************************************************
 This is how it works: http://eppz.eu/blog/custom-uitableviewcell/
 ******************************************************************/

#import "SelfContainedTableViewCell.h"

@implementation SelfContainedTableViewComponentsOwner
+(id)ownerWithNibName:(NSString*) nibName
{
    SelfContainedTableViewComponentsOwner *instance = [SelfContainedTableViewComponentsOwner new];
    [[NSBundle mainBundle] loadNibNamed:nibName owner:instance options:nil];
    return instance;
}
@end

@implementation SelfContainedTableViewCell

+(NSString*)reuseIdentifier { return NSStringFromClass(self.class); }
-(NSString*)reuseIdentifier { return NSStringFromClass(self.class); }

+(SelfContainedTableViewCell*)cellForTableView:(UITableView*) tableView
                                   atIndexPath:(NSIndexPath*) indexPath
                               withModelSource:(id<SelfContainedTableViewCellModelSource>) modelSource
                                   andDelegate:(id<NSObject>) delegate

{
    SelfContainedTableViewCell *cell;
    
    //Get a cell instance (either dequeue from tableView or allocate a new one).
    cell = [tableView dequeueReusableCellWithIdentifier:[self reuseIdentifier]];
    if (cell == nil)
    {
        SelfContainedTableViewComponentsOwner *owner = [SelfContainedTableViewComponentsOwner ownerWithNibName:NSStringFromClass(self)];
        cell = owner.cell;
    }
    
    //set delegate
    cell.delegate = delegate;

    //Configure cell.
    if (modelSource != nil)
    {
        id model = [modelSource modelForIndexPath:indexPath inTableView:tableView];
        [cell configureWithModel:model];
    }
    

    return cell;
}

/* Should be subclassed if used. Only necessary for variable cell heights! */
+(CGFloat) cellHeightForTableView:(UITableView*) tableView atIndexPath:(NSIndexPath*) indexPath
{
    return [self cellForTableView:tableView atIndexPath:indexPath withModelSource:nil andDelegate:nil].bounds.size.height;
    //Takes forever with many cells!!!
}


//Called by self during setup
-(void) configureWithModel:(id) model
{ /* Subclass template. */
    NSLog(@"configureWithModel: not implemented by %@", [self reuseIdentifier] );
}


#pragma Delegation

/* IMPORTANT: This method only works with object arguments.
 * For other arguments perform the selector directly on the delegate 
 */
- (void) callDelegateWithSelector:(SEL) theSelector andObjects:(NSArray *) args
{
    if ([self.delegate respondsToSelector:theSelector]) {
        //Make an NSInvokation object for the selector
        NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:[(NSObject *)self.delegate methodSignatureForSelector:theSelector]];
        //Configure it for this specific call
        invocation.target = self.delegate;
        invocation.selector = theSelector;
        for (int i=0; i<args.count; i++) {
            id objArg = [args objectAtIndex:i];
            [invocation setArgument:&objArg atIndex:i+2]; //index 0 is for target(self) and 1 for selector(_cmd)
            
        }
        
        
        //Send it off
        [invocation invoke];
        
        //@TODO Get the return value (if any)
        /* id value;
        NSLog(@"inv: %@",invocation);
        
        //[invocation getReturnValue:&value];
        
        //and return it
        //return value;
         */
    }

    //return  nil;
}

@end
