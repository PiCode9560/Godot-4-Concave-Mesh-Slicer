# Godot 4 concave mesh slicer

Slicing Concave Mesh Into Half.

Demo video: https://www.youtube.com/watch?v=_yqTljJ0mW0&t=166s

![alt text](https://github.com/PiCode9560/Godot-4-Concave-Mesh-Slicer/blob/main/images/Godot%20Mesh%20slicer.png)


# Feature

- Slice convex, concave, and meshes with holes.
- Rigidbody slicing example scene
# Installing
Download the files from here or the [asset library](https://godotengine.org/asset-library/asset/1812) and put the addons folder into your project.

# Using
In your script that you want to slice meshes, create the MeshSlicer node and add it to the scene tree.

``` gdscript
var meshSlicer = MeshSlicer.new()
func _ready():
  add_child(meshSlicer)
```

To slice a mesh, use the slice_mesh function.

``` gdscript
# Slice a mesh in half using Transform3D as the local position and direction. 
# Return an array of the sliced meshes. 
var meshes = meshSlicer.slice_mesh(slice_transform:Transform3D,mesh:Mesh,cross_section_material:Material)
```
