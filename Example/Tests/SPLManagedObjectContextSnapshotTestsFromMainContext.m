//
//  SPLTests.m
//  SPLManagedObjectContextSnapshot
//
//  Created by Oliver Letterer on 13.07.14.
//  Copyright (c) 2014 Oliver Letterer. All rights reserved.
//

#import "SPLDataStore.h"
#import "SPLEntity.h"

#import <SPLManagedObjectContextSnapshot.h>
#import <NSManagedObjectContext+SLRESTfulCoreData.h>

@interface SPLManagedObjectContextSnapshotTestsFromMainContext : XCTestCase
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) SPLManagedObjectContextSnapshot *snapshot;
@end



@implementation SPLManagedObjectContextSnapshotTestsFromMainContext

- (void)setUp
{
    [super setUp];

    [[SPLDataStore sharedInstance] wipeAllData];
    self.context = [SPLDataStore sharedInstance].mainThreadManagedObjectContext;
    self.context.propagatesDeletesAtEndOfEvent = NO;
    self.snapshot = [[SPLManagedObjectContextSnapshot alloc] initWithManagedObjectContext:self.context];
}

- (void)tearDown
{
    [super tearDown];

    [[SPLDataStore sharedInstance] wipeAllData];
    self.snapshot = nil;
}

- (void)testThatSnapshotTracksInsertionsWithoutUpdates
{
    SPLEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([SPLEntity class])
                                                      inManagedObjectContext:self.context];
    entity.stringValue = @"foo";
    entity.numberValue = @5;

    [self.context save:NULL];

    NSDictionary *initialAttributes = @{
                                        @"stringValue": entity.stringValue,
                                        @"numberValue": entity.numberValue,
                                        };

    expect(self.snapshot.insertions).to.haveCountOf(1);
    SPLManagedObjectChange *change = self.snapshot.insertions.firstObject;
    expect(change.type).to.equal(SPLManagedObjectChangeTypeInsertion);
    expect(change.initialAttributes).to.equal(initialAttributes);
    expect(change.entityName).to.equal(NSStringFromClass([SPLEntity class]));
}

- (void)testThatSnapshotDoesNotTrackDeletedInsertions
{
    SPLEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([SPLEntity class])
                                                      inManagedObjectContext:self.context];
    entity.stringValue = @"foo";
    entity.numberValue = @5;

    [self.context save:NULL];

    [self.context deleteObject:entity];
    [self.context save:NULL];

    expect(self.snapshot.insertions).to.haveCountOf(0);
    expect(self.snapshot.deletions).to.haveCountOf(0);
}

- (void)testThatSnapshotTracksUpdatesOfInsertedObjects
{
    SPLEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([SPLEntity class])
                                                      inManagedObjectContext:self.context];
    entity.stringValue = @"foo";
    entity.numberValue = @5;

    [self.context save:NULL];

    NSDictionary *initialAttributes = @{
                                        @"stringValue": entity.stringValue,
                                        @"numberValue": entity.numberValue,
                                        };

    self.snapshot = [[SPLManagedObjectContextSnapshot alloc] initWithManagedObjectContext:self.context];
    entity.stringValue = @"bar";
    entity.numberValue = @6;
    [self.context save:NULL];

    NSDictionary *changedAttributes = @{
                                        @"stringValue": entity.stringValue,
                                        @"numberValue": entity.numberValue,
                                        };

    expect(self.snapshot.insertions).to.haveCountOf(0);
    expect(self.snapshot.changes).to.haveCountOf(1);

    SPLManagedObjectChange *change = self.snapshot.changes.firstObject;
    expect(change.type).to.equal(SPLManagedObjectChangeTypeUpdate);
    expect(change.initialAttributes).to.equal(initialAttributes);
    expect(change.changedAttributes).to.equal(changedAttributes);
    expect(change.entityName).to.equal(NSStringFromClass([SPLEntity class]));
}

- (void)testThatSnapshotOnlyTracksRealUpdatesOfInsertedObjects
{
    SPLEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([SPLEntity class])
                                                      inManagedObjectContext:self.context];
    entity.stringValue = @"foo";
    entity.numberValue = @5;

    [self.context save:NULL];

    NSDictionary *initialAttributes = @{
                                        @"stringValue": entity.stringValue,
                                        @"numberValue": entity.numberValue,
                                        };

    self.snapshot = [[SPLManagedObjectContextSnapshot alloc] initWithManagedObjectContext:self.context];
    entity.stringValue = @"bar";
    entity.numberValue = @6;
    [self.context save:NULL];

    entity.numberValue = @5;
    [self.context save:NULL];

    NSDictionary *changedAttributes = @{
                                        @"stringValue": entity.stringValue,
                                        };

    expect(self.snapshot.insertions).to.haveCountOf(0);
    expect(self.snapshot.changes).to.haveCountOf(1);

    SPLManagedObjectChange *change = self.snapshot.changes.firstObject;
    expect(change.type).to.equal(SPLManagedObjectChangeTypeUpdate);
    expect(change.initialAttributes).to.equal(initialAttributes);
    expect(change.changedAttributes).to.equal(changedAttributes);
    expect(change.entityName).to.equal(NSStringFromClass([SPLEntity class]));
}

- (void)testThatSnapshotTracksDeletions
{
    SPLEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([SPLEntity class])
                                                      inManagedObjectContext:self.context];
    entity.stringValue = @"foo";
    entity.numberValue = @5;

    [self.context save:NULL];

    NSDictionary *initialAttributes = @{
                                        @"stringValue": entity.stringValue,
                                        @"numberValue": entity.numberValue,
                                        };

    self.snapshot = [[SPLManagedObjectContextSnapshot alloc] initWithManagedObjectContext:self.context];

    [self.context deleteObject:entity];
    [self.context save:NULL];

    expect(self.snapshot.insertions).to.haveCountOf(0);
    expect(self.snapshot.changes).to.haveCountOf(0);
    expect(self.snapshot.deletions).to.haveCountOf(1);

    SPLManagedObjectChange *change = self.snapshot.deletions.firstObject;
    expect(change.type).to.equal(SPLManagedObjectChangeTypeDeletion);
    expect(change.initialAttributes).to.equal(initialAttributes);
    expect(change.entityName).to.equal(NSStringFromClass([SPLEntity class]));
}

- (void)testThatSnapshotTracksDeletionsOfUpdatedObjects
{
    SPLEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([SPLEntity class])
                                                      inManagedObjectContext:self.context];
    entity.stringValue = @"foo";
    entity.numberValue = @5;

    [self.context save:NULL];

    NSDictionary *initialAttributes = @{
                                        @"stringValue": entity.stringValue,
                                        @"numberValue": entity.numberValue,
                                        };

    self.snapshot = [[SPLManagedObjectContextSnapshot alloc] initWithManagedObjectContext:self.context];
    entity.stringValue = @"bar";
    entity.numberValue = @6;
    [self.context save:NULL];

    expect(self.snapshot.changes).to.haveCountOf(1);

    [self.context deleteObject:entity];
    [self.context save:NULL];

    expect(self.snapshot.insertions).to.haveCountOf(0);
    expect(self.snapshot.changes).to.haveCountOf(0);
    expect(self.snapshot.deletions).to.haveCountOf(1);

    SPLManagedObjectChange *change = self.snapshot.deletions.firstObject;
    expect(change.type).to.equal(SPLManagedObjectChangeTypeDeletion);
    expect(change.initialAttributes).to.equal(initialAttributes);
    expect(change.entityName).to.equal(NSStringFromClass([SPLEntity class]));
}

@end
