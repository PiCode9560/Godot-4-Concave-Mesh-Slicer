# Godot 4 concave mesh slicer

Slicing Concave Mesh Into Half.

![alt text](https://github.com/PiCode9560/Godot-4-Concave-Mesh-Slicer/blob/main/images/Godot%20Mesh%20slicer.png)

# Installing
Download the files and put the ConcaveMeshSlicer.gd into your project.

# Using
In your script that you want to slice meshes, create the MeshSlicer node.

``` gdscript
var meshSlicer = MeshSlicer.new()
```

To slice a mesh, use the slice_mesh function.

``` gdscript
#Slice a mesh in half using Transform3D as the local position and direction. Return an array of the sliced meshes.
#The cross-section material is positioned and rotated base on the Transform3D
meshSlicer.slice_mesh(slice_transform:Transform3D,mesh:Mesh,cross_section_material:Material)
```
