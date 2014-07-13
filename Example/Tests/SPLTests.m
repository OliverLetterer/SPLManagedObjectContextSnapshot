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


@interface SPLTests : XCTestCase

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) SPLManagedObjectContextSnapshot *snapshot;

@end

@implementation SPLTests

- (void)setUp
{
    [super setUp];

    [[SPLDataStore sharedInstance] wipeAllData];
    self.context = [SPLDataStore sharedInstance].mainThreadManagedObjectContext;
    self.snapshot = [[SPLManagedObjectContextSnapshot alloc] initWithManagedObjectContext:self.context];
}

- (void)tearDown
{
    [super tearDown];

    [[SPLDataStore sharedInstance] wipeAllData];
    self.snapshot = nil;
}

- (void)testThatSnapshotTracksInsertions
{
    SPLEntity *entity = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([SPLEntity class])
                                                      inManagedObjectContext:self.context];
    entity.stringValue = @"foo";
    entity.numberValue = @5;

    [self.context save:NULL];

    expect(self.snapshot.insertions).to.haveCountOf(1);
}

@end
