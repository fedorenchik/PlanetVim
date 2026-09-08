bl_info = {"name": "Planet Example", "author": "Your name", "version": (1, 0, 0), "blender": (4, 0, 0), "category": "Object"}
import bpy

class PLANET_OT_hello(bpy.types.Operator):
    bl_idname = "planet.hello"
    bl_label = "Planet Hello"

    def execute(self, context):
        self.report({'INFO'}, "Hello from PlanetVim")
        return {'FINISHED'}

def register():
    bpy.utils.register_class(PLANET_OT_hello)

def unregister():
    bpy.utils.unregister_class(PLANET_OT_hello)

if __name__ == "__main__":
    register()
