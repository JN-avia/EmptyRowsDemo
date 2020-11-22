//
//  DecoupledView.m
//  FlightBriefing
//
//  Created by Johan Nyman on 2014-10-31.
//  Copyright (c) 2014 JN Avionics. All rights reserved.
//

#import "DecoupledView.h"


/* Not used for the moment. Might be necessary later.
 * No view connected in IB, they are located with tags instead, 
 * in order to have several in the same xib.
 */
@interface DecoupledViewOwner : NSObject
//+(id)ownerWithNibName:(NSString*) nibName
//           forViewTag:(NSUInteger) tag;
@end

@implementation DecoupledViewOwner
@end

@interface DecoupledView ()
@end

@implementation DecoupledView

+ (DecoupledView *) viewFromNibNamed:(NSString *) nibName
                             withTag:(NSUInteger) tag
                         modelSource:(id<DecoupledViewModelSource>) modelSource
                            delegate:(id<NSObject>)delegate
{
    // Instantiating encapsulated here.
    DecoupledViewOwner *owner = [DecoupledViewOwner new];
    UINib * nib = [UINib nibWithNibName:nibName bundle:nil];
    NSArray * viewsInNib = [nib instantiateWithOwner:owner options:nil];

    //Now we'll try to find the requested view from the nib.
    DecoupledView * view = [viewsInNib objectAtIndex:0]; //We set it to the first view if no tags are present.
    for (UIView *currentView in viewsInNib) {
        if (currentView.tag == tag) view = (DecoupledView *) currentView;
    }
    
    //set delegate
    view.delegate = delegate;
    
    //configure view
    if (modelSource != nil)
    {
        view.modelSource = modelSource;
        id model = [modelSource modelForViewWithTag:tag];
        [view configureWithModel:model];
    }
    
    //and return the view for presentation
    return view;
}



//Called by self during setup
-(void)configureWithModel:(id) model
{ /* Subclass template. */
    NSLog(@"configureWithModel: not implemented by %@", NSStringFromClass([self class]) );
}

- (void) updateViewWithModel:(id) model
{
    [self configureWithModel:model];
}


#pragma Delegation

/* IMPORTANT: This method only works with object arguments.
 * For other arguments perform the selector directly on the delegate from the subclass
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

