//
//  TGLOUpdatePersonDelegate.h
//  TheGreensLeadOrganizerApp
//
//  Created by andre on 21/04/2014.
//  Copyright (c) 2014 andre trosky. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TGLOUpdatePersonDelegate <NSObject>
@optional
-(void) didUpdatePerson:(TGLOPerson *)updatedPerson;
@end
