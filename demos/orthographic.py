from raysect.optical import World, translate, rotate, Point3D, d65_white, InterpolatedSF
from raysect.optical.observer import OrthographicCamera
from raysect.optical.material.emitter import UniformSurfaceEmitter, Checkerboard
from raysect.optical.material.dielectric import Dielectric, Sellmeier
from raysect.optical.library import schott
from raysect.primitive import Sphere, Box, Cylinder, Union, Intersect, Subtract
from matplotlib.pyplot import *
from numpy import array

red_glass = Dielectric(index=Sellmeier(1.03961212, 0.231792344, 1.01046945, 6.00069867e-3, 2.00179144e-2, 1.03560653e2),
                       transmission=InterpolatedSF([300, 490, 510, 590, 610, 800], array([0.0, 0.0, 0.0, 0.0, 1.0, 1.0])*0.7))

green_glass = Dielectric(index=Sellmeier(1.03961212, 0.231792344, 1.01046945, 6.00069867e-3, 2.00179144e-2, 1.03560653e2),
                         transmission=InterpolatedSF([300, 490, 510, 590, 610, 800], array([0.0, 0.0, 1.0, 1.0, 0.0, 0.0])*0.7))

blue_glass = Dielectric(index=Sellmeier(1.03961212, 0.231792344, 1.01046945, 6.00069867e-3, 2.00179144e-2, 1.03560653e2),
                        transmission=InterpolatedSF([300, 490, 510, 590, 610, 800], array([1.0, 1.0, 0.0, 0.0, 0.0, 0.0])*0.7))

world = World()

cyl_x = Cylinder(1, 4.2, transform=rotate(90, 0, 0)*translate(0, 0, -2.1))
cyl_y = Cylinder(1, 4.2, transform=rotate(0, 90, 0)*translate(0, 0, -2.1))
cyl_z = Cylinder(1, 4.2, transform=rotate(0, 0, 0)*translate(0, 0, -2.1))
cube = Box(Point3D(-1.5, -1.5, -1.5), Point3D(1.5, 1.5, 1.5))
sphere = Sphere(2.0)

Intersect(sphere, Subtract(cube, Union(Union(cyl_x, cyl_y), cyl_z)), world, translate(-2.1,2.1,2.5)*rotate(30, -20, 0), schott("N-LAK9"))
Intersect(sphere, Subtract(cube, Union(Union(cyl_x, cyl_y), cyl_z)), world, translate(2.1,2.1,2.5)*rotate(-30, -20, 0), schott("SF6"))
Intersect(sphere, Subtract(cube, Union(Union(cyl_x, cyl_y), cyl_z)), world, translate(2.1,-2.1,2.5)*rotate(-30, 20, 0), schott("LF5G19"))
Intersect(sphere, Subtract(cube, Union(Union(cyl_x, cyl_y), cyl_z)), world, translate(-2.1,-2.1,2.5)*rotate(30, 20, 0), schott("N-BK7"))

s1 = Sphere(1.0, transform=translate(0, 0, 1.0-0.01))
s2 = Sphere(0.5, transform=translate(0, 0, -0.5+0.01))
Intersect(s1, s2, world, translate(0,0,-3.6)*rotate(50,50,0), schott("N-BK7"))

Box(Point3D(-50, -50, 50), Point3D(50, 50, 50.1), world, material=Checkerboard(4, d65_white, d65_white, 0.4, 0.8))
Box(Point3D(-100, -100, -100), Point3D(100, 100, 100), world, material=UniformSurfaceEmitter(d65_white, 0.1))

ion()
camera = OrthographicCamera(width=10.0, parent=world, transform=translate(0, 0, -4) * rotate(0, 0, 0))
camera.ray_min_depth = 3
camera.ray_max_depth = 200
camera.ray_extinction_prob = 0.01
camera.pixel_samples = 50
camera.spectral_samples = 15
camera.display_progress = True
camera.display_update_time = 10
# camera.process_count = 1
camera.observe()

ioff()
# camera.save("render.png")
camera.display()
show()

