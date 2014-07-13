//
//  SPLDataStore.h
//  SPLManagedObjectContextSnapshot
//
//  Created by Oliver Letterer on 13.07.14.
//  Copyright 2014 Oliver Letterer. All rights reserved.
//

#import <SLCoreDataStack.h>



/**
 @abstract  <#abstract comment#>
 */
@interface SPLDataStore : SLCoreDataStack

- (void)wipeAllData;

@end
