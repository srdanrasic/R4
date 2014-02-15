
R4: A SpriteKit in 3D
---------------------

R4 /rɑː/ is a 3D graphics rendering and animation library based on Apple's SpriteKit Framework. Goal of the library is to ease creation of 3D games and applications by providing an infrastructure whose interface resembles interface of the SpriteKit. Someone who is familiar with SpriteKit shouldn't have any problems working with this library. Concepts that apply to SpriteKit also apply to R4, just with additional space dimension.

The library is in an early phase of the development and lacks some of the SpriteKit's counterparts, most notably physical subsystem, but it's usable for the creation of a simple 3D scenes. It provides scene graph infrastructure with drawable nodes like entities and particle emitters, non-drawable nodes like cameras and lights, and scene managers to organize and improve rendering process. Scene nodes are responder objects and can handle touch events defined by the UIResponder class, just like SKNodes.

R4's rendering system is designed to allow easy extension. Main renderer handles basic viewport configuration, frame buffer management and does scene traversal with a help from the scene manager, but forwards actual drawing responsibility to more extendable and configurable components - materials, techniques and passes. A material encapsulates all information on how to render an object, including all possible ways to do it. A technique describes a way to render an object. It does that by specifying one or more passes that perform rendering. Individual passes do actual rendering using shaders and OpenGL framework.

To learn more about R4 continue reading classes' reference pages listed below. If you're new to the game development consider reading Apple's [Sprite Kit Programming Guide](https://developer.apple.com/library/mac/documentation/GraphicsAnimation/Conceptual/SpriteKit_PG/Introduction/Introduction.html). It provides great starting point and most of the concepts described there apply to R4.


Features
--------

* SpriteKit based design.
* **A node tree** based representation of the scene content. See R4Node and R4Scene for more info.
* The nodes are **responder objects** - they can receive touch events. See R4Node for more info.
* Support for **action** based animations and logic. See R4Action for more info.
* **Particle emitters** compatible with Xcode particle editor. See R4EmitterNode for more info.
* **OBJ mesh file loader** for files that contain one polygon group and one texture. See R4Mesh for more info.
* **User-extendable rendering system** for custom effects. See R4Material, R4Technique and R4Pass for more info.

Planned or in progress
======================

* Full NSCopying and NSCoding compliance.
* Support for more 3D file formats and extended OBJ file loader.
* Extended collection of R4Action classes.
* Scene and camera transition support based on SKTransition class.
* More out-of-box materials and shaders.
* Basic physical subsystem.
* Skeletal animation.


Getting started
---------------

TODO


Contribute
----------

R4 needs your help to make it better. If you find it useful, consider forking it on [GitHub](https://github.com/srdanrasic/R4) and doing improvements. I'll be happy to accept contributions - were they either extensions or improvements of the current codebase. If you do find yourself contributing, please follow these few guidelines:

* When working on existing file use same code style that's already used in that file. Although I'd prefer, I don't mind different styles in different files. Per file consistency is more important.
* Be sure to update the documentation accordingly to changes you've made. Especially if something has been changed. Build the Documentation target to recompile it with [appledoc](http://gentlebytes.com/appledoc/).
* Name headers that are used only internally like *Private.h to hide them from users and exclude from the documentation.
* Use properties to define public interfaces. Use ivars for performance critical code.
