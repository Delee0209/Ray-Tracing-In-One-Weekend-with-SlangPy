import interval;
import hittable;
import material;
import sphere;
import ray;

struct object // struct for packing hittable data from CPU
{
    float3 center;
    float radius;
    uint mat;
}

struct appearance // struct for packing material data from CPU
{
    uint type;
    float3 albedo;
    float parameter;
}

struct hittable_list
{
    uint object_count;
    StructuredBuffer<object> objects;
    StructuredBuffer<appearance> appearances;

    hittable get_hittable(int id)
    {
        return sphere(objects[id].center, objects[id].radius, objects[id].mat);
    }

    material get_material(int id)
    {
        switch (appearances[id].type)
        {
            case 0:
                return lambertian(appearances[id].albedo);
            case 1:
                return metal(appearances[id].albedo, appearances[id].parameter);
            case 2:
                return dielectric(appearances[id].parameter);
            default:
                return lambertian(appearances[id].albedo);
        }
    }

    bool hit(in ray r, interval ray_t, inout hit_record rec)
    {
        hit_record temp_rec;
        bool hit_anything = false;
        var closest_so_far = ray_t.max;

        for (int id = 0; id < object_count; id++)
        {
            hittable object = get_hittable(id);
            if (object.hit(r, interval(ray_t.min, closest_so_far), temp_rec))
            {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec = temp_rec;
            }
        }

        return hit_anything;
    }
}