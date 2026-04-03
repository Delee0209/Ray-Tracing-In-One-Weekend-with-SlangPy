import slangpy as spy
import math
from utility import *
from camera import camera
from hittable_list import hittable_list
from hittable import *
from material import *

world = hittable_list()

ground_material = world.add_material(lambertian(spy.float3(0.5, 0.5, 0.5)))
world.add_hittable(sphere(spy.float3(0, -1000, 0), 1000, ground_material))

for a in range(-11, 11):
    for b in range(-11, 11):
        choose_mat = random_float()
        center = spy.float3(a + 0.9 * random_float(), 0.2, b + 0.9 * random_float())

        if spy.math.length(center - spy.float3(4, 0.2, 0)) > 0.9:
            
            if choose_mat < 0.8:
                # diffuse
                albedo = random_float3() * random_float3()
                sphere_material = world.add_material(lambertian(albedo))
                world.add_hittable(sphere(center, 0.2, sphere_material))
            elif choose_mat < 0.95:
                # metal
                albedo = random_float3(0.5, 1.0)
                fuzz = random_float(0.0, 0.5)
                sphere_material = world.add_material(metal(albedo, fuzz))
                world.add_hittable(sphere(center, 0.2, sphere_material))
            else:
                sphere_material = world.add_material(dielectric(1.5))
                world.add_hittable(sphere(center, 0.2, sphere_material))

material1 = world.add_material(dielectric(1.5))
world.add_hittable(sphere(spy.float3(0, 1, 0), 1.0, material1))

material2 = world.add_material(lambertian(spy.float3(0.4, 0.2, 0.1)))
world.add_hittable(sphere(spy.float3(-4, 1, 0), 1.0, material2))

material3 = world.add_material(metal(spy.float3(0.7, 0.6, 0.5), 0.0))
world.add_hittable(sphere(spy.float3(4, 1, 0), 1.0, material3))

cam = camera()

cam.aspect_ratio = 16.0 / 9.0
cam.image_width = 1200
cam.max_depth = 50

cam.vfov = 20
cam.lookfrom    = spy.float3(13, 2, 3)
cam.lookat      = spy.float3(0, 0, 0)
cam.vup         = spy.float3(0, 1, 0)

cam.defocus_angle = 0.6
cam.focus_dist = 10.0

cam.render(world)
