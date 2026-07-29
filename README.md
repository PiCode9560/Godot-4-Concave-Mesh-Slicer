# Godot 4 concave mesh slicer (v2.0-stable)

Slice a concave mesh Into half.

Based on godot CSG system.

Demo video (The tutorial is outdated): https://www.youtube.com/watch?v=_yqTljJ0mW0&t=166s

![alt text](https://github.com/PiCode9560/Godot-4-Concave-Mesh-Slicer/blob/main/images/Godot%20Mesh%20slicer.png)


# Feature

- Slice convex, concave, and meshes with holes.
- Rigidbody slicing example scene
# Installing
Download the files from here or the [asset library](https://godotengine.org/asset-library/asset/1812) and put the addons folder into your project.

# Usage
To slice a mesh, call the `slice_mesh()` function from the `MeshSlicer` class, and it returns an array containing the 2 half of the sliced mesh.
``` gdscript
var meshes := MeshSlicer.slice_mesh(slice_transform:Transform3D, mesh:Mesh, cross_section_material:Material)
```
`slice_transform` is the transform of a the slicing plane relative to the mesh, with the plane normal facing z axis.

`mesh` is the mesh that is going to be sliced.

`cross_section_material` is an optional parameter to set the material for the cross-section of the sliced meshes.
