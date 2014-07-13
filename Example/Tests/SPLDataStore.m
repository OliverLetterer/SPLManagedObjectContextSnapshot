//
//  SPLDataStore.m
//  SPLManagedObjectContextSnapshot
//
//  Created by Oliver Letterer on 13.07.14.
//  Copyright 2014 Oliver Letterer. All rights reserved.
//

#import "SPLDataStore.h"

@implementation SPLDataStore

- (NSString *)managedObjectModelName
{
    return @"DataStore";
}

- (void)wipeAllData
{
    NSParameterAssert([NSThread currentThread].isMainThread);
    NSManagedObjectContext *context = self.mainThreadManagedObjectContext;

    for (NSString *entityName in self.managedObjectModel.entitiesByName) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];

        NSError *error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        NSAssert(error == nil, @"error fetching data: %@", error);

        for (NSManagedObject *object in fetchedObjects) {
            [context deleteObject:object];
        }
    }

    NSError *saveError = nil;
    [context save:&saveError];
    NSAssert(saveError == nil, @"error saving NSManagedObjectContext: %@", saveError);
}

@end
