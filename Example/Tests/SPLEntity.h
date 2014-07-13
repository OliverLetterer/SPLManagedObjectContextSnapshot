//
//  SPLEntity.h
//  SPLManagedObjectContextSnapshot
//
//  Created by Oliver Letterer on 13.07.14.
//  Copyright (c) 2014 Oliver Letterer. All rights reserved.
//



@interface SPLEntity : NSManagedObject

@property (nonatomic, strong) NSString *stringValue;
@property (nonatomic, strong) NSNumber *numberValue;

@end
