from raysect.optical import World, translate, rotate, Point3D, d65_white, ConstantSF
from raysect.primitive import Sphere, Box, Cylinder
from raysect.optical.observer import PinholeCamera
from raysect.optical.material import Gold, Silver, Copper, Titanium, Aluminium, Lambert, UniformSurfaceEmitter
from matplotlib.pyplot import *

world = World()

Sphere(0.5, world, transform=translate(1.2, 0.5001, 0.6), material=Gold())
Sphere(0.5, world, transform=translate(0.6, 0.5001, -0.6), material=Silver())
Sphere(0.5, world, transform=translate(0, 0.5001, 0.6), material=Copper())
Sphere(0.5, world, transform=translate(-0.6, 0.5001, -0.6), material=Titanium())
Sphere(0.5, world, transform=translate(-1.2, 0.5001, 0.6), material=Aluminium())

Box(Point3D(-100, -0.1, -100), Point3D(100, 0, 100), world, material=Lambert(ConstantSF(1.0)))
Cylinder(3.0, 8.0, world, transform=translate(4, 8, 0) * rotate(90, 0, 0), material=UniformSurfaceEmitter(d65_white, 1.0))

camera = PinholeCamera(parent=world, transform=translate(0, 4, -3.5) * rotate(0, -48, 0))
camera.fov = 45
camera.ray_min_depth = 3
camera.ray_max_depth = 500
camera.ray_extinction_prob = 0.01
camera.rays = 1
camera.spectral_samples = 15
camera.pixels = (512, 512)
camera.pixel_samples = 100
camera.display_progress = True
camera.display_update_time = 10
camera.accumulate = True

# start ray tracing
ion()
for p in range(1, 1000):
    print("Rendering pass {} ({} samples/pixel)...".format(p, camera.accumulated_samples + camera.pixel_samples * camera.rays))
    camera.observe()
    camera.save("demo_metal_{}_samples.png".format(camera.accumulated_samples))
    print()

# display final result
ioff()
camera.display()
show()
