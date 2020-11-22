//
//  DecoupledView.h
//  FlightBriefing
//
//  Created by Johan Nyman on 2014-10-31.
//  Copyright (c) 2014 JN Avionics. All rights reserved.
//

#import <UIKit/UIKit.h>




@protocol DecoupledViewModelSource <NSObject>
/* The model returned might be an array with several objects. The subclass must deal with this. */
- (id) modelForViewWithTag:(NSUInteger) tag;
@end


@interface DecoupledView : UIView

@property (nonatomic, weak) id <NSObject> delegate;
@property (nonatomic, weak) id <DecoupledViewModelSource> modelSource;


+ (DecoupledView *) viewFromNibNamed:(NSString *) nibName
                             withTag:(NSUInteger) tag
                         modelSource:(id<DecoupledViewModelSource>) modelSource
                            delegate:(id<NSObject>) delegate;

/* For refreshing the view */
- (void) updateViewWithModel:(id) model;

/* For delegation */
- (void) callDelegateWithSelector:(SEL) theSelector andObjects:(NSArray *) args;


@end

