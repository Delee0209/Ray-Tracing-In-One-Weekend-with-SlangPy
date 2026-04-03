import interval;
import utility;
import ray;
import hittable;
import material;

struct sphere : hittable
{
    float3 center;
    float radius;
    uint mat;

    bool hit(in ray r, interval ray_t, inout hit_record rec)
    {
        float3 oc = center - r.origin();
        var a = length_squared(r.direction());
        var h = dot(r.direction(), oc);
        var c = length_squared(oc) - radius * radius;

        var discriminant = h * h - a * c;
        if (discriminant < 0.f)
        {
            return false;
        }

        var sqrtd = sqrt(discriminant);

        // Find the nearest root that lies in the acceptance range.
        var root = (h - sqrtd) / a;
        if (!ray_t.surrounds(root))
        {
            root = (h + sqrtd) / a;
            if (!ray_t.surrounds(root))
            {
                return false;
            }
        }

        rec.t = root;
        rec.p = r.at(rec.t);
        float3 outward_normal = (rec.p - center) / radius;
        rec.set_face_normal(r, outward_normal);
        rec.mat = mat;

        return true;
    }
}