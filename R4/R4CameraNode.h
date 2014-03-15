//
//  R4Camera.h
//  R4
//
//  Created by Srđan Rašić on 16/11/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Node.h"

/*!
 Camera represent a direction and a view point the scene is looked from.
 */
@interface R4CameraNode : R4Node

/*!
 If set, camera will always look at this node, regardless of camera's or node's position.
 */
@property (strong, nonatomic) R4Node *targetNode;

@property (assign, nonatomic) GLKVector3 upVector;

@property (assign, nonatomic) GLKVector3 lookAt;

/*!
 Creates a new camera with position and look at direction.
 
 @param position Camera position. Corresponds to position property.
 @param lookingAt Look at direction vector.
 */
+ (instancetype)cameraAtPosition:(GLKVector3)position lookingAt:(GLKVector3)lookingAt;

@end
