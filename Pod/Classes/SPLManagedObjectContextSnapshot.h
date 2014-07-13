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

@import CoreData;



typedef NS_ENUM(NSInteger, SPLManagedObjectChangeType) {
    SPLManagedObjectChangeTypeInsertion,
    SPLManagedObjectChangeTypeUpdate,
    SPLManagedObjectChangeTypeDeletion
};

@interface SPLManagedObjectChange : NSObject

@property (nonatomic, readonly) NSDate *timestamp;

@property (nonatomic, readonly) NSString *entityName;
@property (nonatomic, readonly) SPLManagedObjectChangeType type;

@property (nonatomic, readonly) NSDictionary *initialAttributes;
@property (nonatomic, readonly) NSDictionary *changedAttributes;

@end



/**
 @abstract  <#abstract comment#>
 */
@interface SPLManagedObjectContextSnapshot : NSObject

@property (nonatomic, readonly) NSArray *insertions;
@property (nonatomic, readonly) NSArray *changes;
@property (nonatomic, readonly) NSArray *deletions;

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
