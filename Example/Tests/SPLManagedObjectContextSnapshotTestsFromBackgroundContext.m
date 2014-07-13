//
//  SPLManagedObjectContextSnapshotTestsFromBackgroundContext.m
//  SPLManagedObjectContextSnapshot
//
//  Created by Oliver Letterer on 13.07.14.
//  Copyright (c) 2014 Oliver Letterer. All rights reserved.
//

#import "SPLDataStore.h"
#import "SPLEntity.h"

#import <SPLManagedObjectContextSnapshot.h>
#import <NSManagedObjectContext+SLRESTfulCoreData.h>

@interface SPLManagedObjectContextSnapshotTestsFromBackgroundContext : XCTestCase
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) SPLManagedObjectContextSnapshot *snapshot;
@end



@implementation SPLManagedObjectContextSnapshotTestsFromBackgroundContext

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

- (void)testThatSnapshotDoesntTrackInsertions
{
    NSManagedObjectContext *backgroundContext = [SPLDataStore sharedInstance].backgroundThreadManagedObjectContext;

    [backgroundContext performBlock:^{
        SPLEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([SPLEntity class])
                                                          inManagedObjectContext:backgroundContext];
        entity.stringValue = @"foo";
        entity.numberValue = @5;

        [backgroundContext save:NULL];
    }];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([SPLEntity class])];
    fetchRequest.fetchLimit = 1;

    expect([self.context countForFetchRequest:fetchRequest error:NULL]).will.equal(1);
    expect(self.snapshot.insertions).to.haveCountOf(0);
}

- (void)testThatSnapshotDoesntTrackUpdates
{
    SPLEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([SPLEntity class])
                                                      inManagedObjectContext:self.context];
    entity.stringValue = @"foo";
    entity.numberValue = @5;

    [self.context save:NULL];

    NSManagedObjectContext *backgroundContext = [SPLDataStore sharedInstance].backgroundThreadManagedObjectContext;
    [backgroundContext performBlock:^(SPLEntity *entity) {
        entity.stringValue = @"bar";
        [backgroundContext save:NULL];
    } withObject:entity];

    expect(entity.stringValue).will.equal(@"bar");

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

- (void)testThatSnapshotDoesntTrackDeletions
{
    SPLEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([SPLEntity class])
                                                      inManagedObjectContext:self.context];
    entity.stringValue = @"foo";
    entity.numberValue = @5;

    [self.context save:NULL];

    NSManagedObjectContext *backgroundContext = [SPLDataStore sharedInstance].backgroundThreadManagedObjectContext;
    [backgroundContext performBlock:^(SPLEntity *entity) {
        [backgroundContext deleteObject:entity];
        [backgroundContext save:NULL];
    } withObject:entity];

    expect(entity.isDeleted).will.beTruthy();

    expect(self.snapshot.insertions).to.haveCountOf(0);
    expect(self.snapshot.deletions).to.haveCountOf(0);
}

- (void)testThatSnapshotDoesntTrackDeletionsForUpdatedObjects
{
    SPLEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([SPLEntity class])
                                                      inManagedObjectContext:self.context];
    entity.stringValue = @"foo";
    entity.numberValue = @5;

    [self.context save:NULL];

    self.snapshot = [[SPLManagedObjectContextSnapshot alloc] initWithManagedObjectContext:self.context];

    entity.stringValue = @"bar";
    [self.context save:NULL];

    expect(self.snapshot.changes).to.haveCountOf(1);

    NSManagedObjectContext *backgroundContext = [SPLDataStore sharedInstance].backgroundThreadManagedObjectContext;
    [backgroundContext performBlock:^(SPLEntity *entity) {
        [backgroundContext deleteObject:entity];
        [backgroundContext save:NULL];
    } withObject:entity];

    expect(entity.isDeleted).will.beTruthy();

    expect(self.snapshot.changes).to.haveCountOf(0);
    expect(self.snapshot.deletions).to.haveCountOf(0);
}

- (void)testThatSnapshotOverwritesChanges
{
    SPLEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([SPLEntity class])
                                                      inManagedObjectContext:self.context];
    entity.stringValue = @"foo";
    entity.numberValue = @5;

    [self.context save:NULL];

    self.snapshot = [[SPLManagedObjectContextSnapshot alloc] initWithManagedObjectContext:self.context];
    entity.stringValue = @"bar";
    entity.numberValue = @6;

    __block BOOL done = NO;
    NSManagedObjectContext *backgroundContext = [SPLDataStore sharedInstance].backgroundThreadManagedObjectContext;
    [backgroundContext performBlock:^(SPLEntity *entity) {
        entity.numberValue = @7;
        [backgroundContext save:NULL];
        dispatch_async(dispatch_get_main_queue(), ^{
            done = YES;
        });
    } withObject:entity];

    expect(done).will.equal(YES);

    NSDictionary *initialAttributes = @{
                                        @"stringValue": @"foo",
                                        @"numberValue": @7,
                                        };
    NSDictionary *changedAttributes = @{
                                        @"stringValue": @"bar",
                                        @"numberValue": @6,
                                        };

    expect(self.snapshot.changes).to.haveCountOf(1);

    SPLManagedObjectChange *change = self.snapshot.changes.firstObject;
    expect(change.type).to.equal(SPLManagedObjectChangeTypeUpdate);

    expect(change.entityName).to.equal(NSStringFromClass([SPLEntity class]));
    expect(change.initialAttributes).to.equal(initialAttributes);
    expect(change.changedAttributes).to.equal(changedAttributes);
}

@end
