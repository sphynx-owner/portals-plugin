A remaster of an old project.

Contains a seamless portal experience supporting third person movement to a degree.

Still limited in a few places, but I have plans to improve upon those limitations in the future. Stay tuned!

update 7_9_24:

I was able to add custom clip plane support for the portals, so to not show geometry that would be between the through-portal-view and 
the actual portal, unintuitively occluding the view through the portal.

The main issues implementing it is that each portal has its own global custom clip plane that needs to be applied for all meshes that may occlude 
the view through those portals. This means that I needed a way to discard meshes based on a clip plane that was different between the different portals,
meaning the same exact mesh needed to look entirely differently depending on which portal camera is rendering it.


One way would be to duplicate all the meshes in the world and split them between the different portal views, but that is impractical.

The other way would be to render the mesh differently depending on the view its being rendered to.

In order to do so, I had to somehow figure out which view this mesh is being viewed through within the surface material shader of that mesh. 
Godot does not provide you with a way to get the view index, so I had to figure another way. The way I came up with, which would impose the least amount of complication,
is to encode the view's portal index into the far plane of the projection matrix, which I can easily set using the far plane variable on each of the view's cameras.
That way I could then store a buffer of all clip plane origins and normals, and based on the portal index that is now encoded into the PROJECTION_MATRIX, extract the correct clip plane value for the current view
from said shared buffer. This seemed to work rather well. The only limitation is that I had to set the near and far plane values on all the portal cameras to tamer values, so theres less floating point errors inversing the 
far plane value.

demo video: https://youtu.be/RX22EqwuPos
