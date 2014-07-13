/**
 SPLManagedObjectContextSnapshot
 Copyright (c) 2014 Oliver Letterer <oliver.letterer@gmail.com>, Sparrow-Labs

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "SPLManagedObjectContextSnapshot.h"

@interface SPLManagedObjectChange ()

@property (nonatomic, strong) NSManagedObject *managedObject;

@property (nonatomic, strong) NSString *entityName;
@property (nonatomic, assign) SPLManagedObjectChangeType type;

@property (nonatomic, strong) NSDictionary *initialAttributes;
@property (nonatomic, strong) NSDictionary *changedAttributes;

@end

@implementation SPLManagedObjectChange

- (NSDictionary *)initialAttributes
{
    if (self.type == SPLManagedObjectChangeTypeInsertion) {
        [self captureInitialState];
    }

    return _initialAttributes;
}

- (void)setManagedObject:(NSManagedObject *)managedObject
{
    if (managedObject != _managedObject) {
        _managedObject = managedObject;

        if (_managedObject) {
            _entityName = _managedObject.entity.name;
        }
    }
}

- (void)captureInitialState
{
    NSParameterAssert(self.managedObject);

    NSArray *allAttributes = self.managedObject.entity.attributesByName.allKeys;
    _initialAttributes = [self.managedObject committedValuesForKeys:allAttributes];
}

- (void)captureCurrentState
{
    NSParameterAssert(self.managedObject);

    NSDictionary *attributesByName = self.managedObject.entity.attributesByName;
    NSMutableDictionary *changedAttributes = [NSMutableDictionary dictionaryWithDictionary:self.changedAttributes];

    for (NSString *key in self.managedObject.changedValuesForCurrentEvent) {
        if (!attributesByName[key]) {
            continue;
        }

        id currentValue = [self.managedObject valueForKey:key];
        id initialValue = self.initialAttributes[key];

        if (initialValue != currentValue && ![initialValue isEqual:currentValue]) {
            [changedAttributes setValue:currentValue forKey:key];
        } else {
            [changedAttributes removeObjectForKey:key];
        }
    }
    _changedAttributes = changedAttributes;
}

- (instancetype)initWithType:(SPLManagedObjectChangeType)type
{
    if (self = [super init]) {
        _type = type;

        _initialAttributes = @{};
        _changedAttributes = @{};
    }
    return self;
}

- (NSString *)description
{
    NSString *type = @"";
    switch (self.type) {
        case SPLManagedObjectChangeTypeInsertion:
            type = @"Inserted";
            break;
        case SPLManagedObjectChangeTypeUpdate:
            type = @"Updated";
            break;
        case SPLManagedObjectChangeTypeDeletion:
            type = @"Deleted";
            break;
    }

    NSMutableString *description = [NSMutableString stringWithFormat:@"%@: %@[%@]", super.description, type, self.entityName];
    [description appendFormat:@"initialAttributes = %@", self.initialAttributes];

    if (self.type == SPLManagedObjectChangeTypeUpdate) {
        [description appendFormat:@", changedAttributes = %@", self.changedAttributes];
    }

    return [description copy];
}

@end



@interface SPLManagedObjectContextSnapshot ()

@property (nonatomic, strong) NSArray *insertions;
@property (nonatomic, strong) NSArray *changes;
@property (nonatomic, strong) NSArray *deletions;

@property (nonatomic, readonly) NSMutableArray *mutableInsertions;
@property (nonatomic, readonly) NSMutableArray *mutableChanges;
@property (nonatomic, readonly) NSMutableArray *mutableDeletions;

@end

@implementation SPLManagedObjectContextSnapshot

#pragma mark - setters and getters

- (NSMutableArray *)mutableInsertions
{
    return [self mutableArrayValueForKey:NSStringFromSelector(@selector(insertions))];
}

- (NSMutableArray *)mutableChanges
{
    return [self mutableArrayValueForKey:NSStringFromSelector(@selector(changes))];
}

- (NSMutableArray *)mutableDeletions
{
    return [self mutableArrayValueForKey:NSStringFromSelector(@selector(deletions))];
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"%@: %lu insertions, %lu changes, %lu deletions\n", super.description, (unsigned long)self.insertions.count, (unsigned long)self.changes.count, (unsigned long)self.deletions.count];

    [description appendFormat:@"insertions: {\n"];
    for (SPLManagedObjectChange *change in self.insertions) {
        [description appendFormat:@"\t%@\n", change];
    }
    [description appendFormat:@"},\n"];

    [description appendFormat:@"updates: {\n"];
    for (SPLManagedObjectChange *change in self.changes) {
        [description appendFormat:@"\t%@\n", change];
    }
    [description appendFormat:@"},\n"];

    [description appendFormat:@"deletions: {\n"];
    for (SPLManagedObjectChange *change in self.deletions) {
        [description appendFormat:@"\t%@\n", change];
    }
    [description appendFormat:@"}"];

    return description;
}

#pragma mark - Initialization

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSParameterAssert(managedObjectContext);

    if (self = [super init]) {
        _insertions = [NSArray array];
        _changes = [NSArray array];
        _deletions = [NSArray array];
        
        _managedObjectContext = managedObjectContext;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_managedObjectContextDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:_managedObjectContext];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private category implementation ()

- (void)_managedObjectContextDidChange:(NSNotification *)notification
{
    for (NSManagedObject *insertedObject in notification.userInfo[NSInsertedObjectsKey]) {
        SPLManagedObjectChange *change = [[SPLManagedObjectChange alloc] initWithType:SPLManagedObjectChangeTypeInsertion];
        change.managedObject = insertedObject;

        [self.mutableInsertions addObject:change];
    }

    NSArray *observingInsertedObjects = [self.insertions valueForKeyPath:@"managedObject"];
    NSArray *currentlyChangedObjects = [self.changes valueForKey:@"managedObject"];

    // updated objects
    {
        for (NSManagedObject *updatedObject in notification.userInfo[NSUpdatedObjectsKey]) {
            if ([observingInsertedObjects containsObject:updatedObject]) {
                continue;
            }

            if ([currentlyChangedObjects containsObject:updatedObject]) {
                NSInteger index = [currentlyChangedObjects indexOfObject:updatedObject];
                SPLManagedObjectChange *change = self.changes[index];
                [change captureCurrentState];
                continue;
            }

            SPLManagedObjectChange *change = [[SPLManagedObjectChange alloc] initWithType:SPLManagedObjectChangeTypeUpdate];
            change.managedObject = updatedObject;
            [change captureInitialState];
            [change captureCurrentState];
            [self.mutableChanges addObject:change];
        }
    }

    // deleted objects
    {
        NSMutableIndexSet *insertionsToBeDeleted = [NSMutableIndexSet indexSet];
        NSMutableIndexSet *changesToBeDeleted = [NSMutableIndexSet indexSet];

        for (NSManagedObject *deletedObject in notification.userInfo[NSDeletedObjectsKey]) {
            if ([observingInsertedObjects containsObject:deletedObject]) {
                [insertionsToBeDeleted addIndex:[observingInsertedObjects indexOfObject:deletedObject]];
                continue;
            }

            if ([currentlyChangedObjects containsObject:deletedObject]) {
                NSInteger index = [currentlyChangedObjects indexOfObject:deletedObject];
                SPLManagedObjectChange *updateChange = self.changes[index];

                SPLManagedObjectChange *newChange = [[SPLManagedObjectChange alloc] initWithType:SPLManagedObjectChangeTypeDeletion];
                newChange.initialAttributes = updateChange.initialAttributes;
                [self.mutableDeletions addObject:newChange];

                [changesToBeDeleted addIndex:index];
                continue;
            }

            SPLManagedObjectChange *change = [[SPLManagedObjectChange alloc] initWithType:SPLManagedObjectChangeTypeDeletion];
            change.managedObject = deletedObject;
            [change captureInitialState];
            change.managedObject = nil;
            [self.mutableDeletions addObject:change];
        }

        [self.mutableInsertions removeObjectsAtIndexes:insertionsToBeDeleted];
        [self.mutableChanges removeObjectsAtIndexes:changesToBeDeleted];
    }
}

@end
