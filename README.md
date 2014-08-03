# SPLManagedObjectContextSnapshot

[![CI Status](http://img.shields.io/travis/OliverLetterer/SPLManagedObjectContextSnapshot.svg?style=flat)](https://travis-ci.org/OliverLetterer/SPLManagedObjectContextSnapshot)
[![Version](https://img.shields.io/cocoapods/v/SPLManagedObjectContextSnapshot.svg?style=flat)](http://cocoadocs.org/docsets/SPLManagedObjectContextSnapshot)
[![License](https://img.shields.io/cocoapods/l/SPLManagedObjectContextSnapshot.svg?style=flat)](http://cocoadocs.org/docsets/SPLManagedObjectContextSnapshot)
[![Platform](https://img.shields.io/cocoapods/p/SPLManagedObjectContextSnapshot.svg?style=flat)](http://cocoadocs.org/docsets/SPLManagedObjectContextSnapshot)

`SPLManagedObjectContextSnapshot` tracks changes made in a single `NSManagedObjectContext` in form of `SPLManagedObjectChange` instances:

```objc
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
```

__Changes made on a different context and merged into the tracking context are ignored and counted against `SPLManagedObjectChange.initialAttributes`.__

## Usage

* Allocate a new instance of `SPLManagedObjectContextSnapshot`

```objc
SPLManagedObjectContextSnapshot *snapshot = [[SPLManagedObjectContextSnapshot alloc] initWithManagedObjectContext:context];
```

* When You are done tracking, process changes through

```objc
@interface SPLManagedObjectContextSnapshot : NSObject

@property (nonatomic, readonly) NSArray *insertions;
@property (nonatomic, readonly) NSArray *changes;
@property (nonatomic, readonly) NSArray *deletions;

@end
```

## Installation

SPLManagedObjectContextSnapshot is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "SPLManagedObjectContextSnapshot"

## Author

Oliver Letterer, oliver.letterer@gmail.com

## License

SPLManagedObjectContextSnapshot is available under the MIT license. See the LICENSE file for more info.
