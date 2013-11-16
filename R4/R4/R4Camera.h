//
//  R4Camera.h
//  R4
//
//  Created by Srđan Rašić on 16/11/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Node.h"

@interface R4Camera : R4Node
+ (instancetype)cameraAtPosition:(GLKVector3)position lookingAt:(GLKVector3)lookingAt;
@property (strong, nonatomic) R4Node *targetNode;
@end
