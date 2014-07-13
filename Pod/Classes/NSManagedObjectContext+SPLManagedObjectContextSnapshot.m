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

#import "NSManagedObjectContext+SPLManagedObjectContextSnapshot.h"
#import <objc/runtime.h>

static void class_swizzleSelector(Class class, SEL originalSelector, SEL newSelector)
{
    Method origMethod = class_getInstanceMethod(class, originalSelector);
    Method newMethod = class_getInstanceMethod(class, newSelector);
    if(class_addMethod(class, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(class, newSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}



@implementation NSManagedObjectContext (SPLManagedObjectContextSnapshot)

+ (void)load
{
    class_swizzleSelector(self, @selector(mergeChangesFromContextDidSaveNotification:), @selector(__SPLManagedObjectContextSnapshotMergeChangesFromContextDidSaveNotification:));
}

- (BOOL)spl_isMergingChanges
{
    return [objc_getAssociatedObject(self, @selector(spl_isMergingChanges)) boolValue];
}

- (void)setSpl_isMergingChanges:(BOOL)spl_isMergingChanges
{
    objc_setAssociatedObject(self, @selector(spl_isMergingChanges), @(spl_isMergingChanges), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)__SPLManagedObjectContextSnapshotMergeChangesFromContextDidSaveNotification:(NSNotification *)notification
{
    self.spl_isMergingChanges = YES;
    [self __SPLManagedObjectContextSnapshotMergeChangesFromContextDidSaveNotification:notification];
    self.spl_isMergingChanges = NO;
}

@end
