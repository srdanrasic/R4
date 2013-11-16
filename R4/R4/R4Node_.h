//
//  R4Node_.h
//  R4
//
//  Created by Srđan Rašić on 9/29/13.
//  Copyright (c) 2013 Srđan Rašić. All rights reserved.
//

#import "R4Node.h"

@interface R4Node () {
  NSMutableArray *_children;
  NSMutableArray *_actions;
  
  CGRect _accumulatedFrame;
  BOOL _dirty;
  BOOL _visited;
}

@property (nonatomic, readwrite) R4Scene *scene;
@property (nonatomic, readwrite) R4Node *parent;

@property (nonatomic) GLKMatrix4 modelViewMatrix;

- (void)willTraverse;
- (void)prepareEffect:(GLKBaseEffect *)effect;
- (void)draw;
- (void)didTraverse;

- (void)updateActionsAtTime:(NSTimeInterval)time;

@end
