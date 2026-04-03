import utility;
import interval;
import ray;
import hittable;
import material;
import hittable_list;


struct camera
{
    uint image_height;
    uint image_width;
    uint max_depth;
    uint frame_number;
    float3 center;
    float3 pixel00_loc;
    float3 pixel_delta_u;
    float3 pixel_delta_v;
    float3 defocus_disk_u;
    float3 defocus_disk_v;
    float defocus_angle;

    float3 sample_square(inout RNG rng)
    {
        return float3(random_float(rng) - 0.5, random_float(rng) - 0.5, 0.f);
    }

    float3 defocus_disk_sample(inout RNG rng)
    {
        // Return a random point in the camera defocus disk.
        var p = random_in_unit_disk(rng);
        return center + (p.x * defocus_disk_u) + (p.y * defocus_disk_v);
    }

    ray get_ray(uint i, uint j, inout RNG rng)
    {
        // Construct a camera ray originating from the defocus disk and directed at randomly sampled point around the pixel location i, j.
        var offset = sample_square(rng);
        var pixel_sample = pixel00_loc + ((i + offset.x) * pixel_delta_u) + ((j + offset.y) * pixel_delta_v);

        var ray_origin = (defocus_angle <= 0.f)? center : defocus_disk_sample(rng);
        var ray_direction = pixel_sample - ray_origin;

        return ray(ray_origin, ray_direction);
    }

    // Note that most shader / GPU programming does not support recursion!
    // Therefore, we have to alter the original ray_color function to for loop.
    float3 ray_color(ray r, in hittable_list world, inout RNG rng)
    {
        float3 pixel_color = float3(1.f);
        for (int i = 0; i < max_depth; i++)
        {
            hit_record rec;
            if (world.hit(r, interval(0.001, infinity), rec))
            {
                ray scattered;
                float3 attenuation;
                material mat = world.get_material(rec.mat);
                if (mat.scatter(r, rec, attenuation, scattered, rng))
                {
                    pixel_color *= attenuation;
                    r = scattered;
                }
                else return float3(0.f);
            }
            else
            {
                float3 unit_direction = normalize(r.direction());
                var a = 0.5 * (unit_direction.y + 1.f);
                return pixel_color * ((1.f - a) * float3(1.f, 1.f, 1.f) + a * float3(0.5f, 0.7f, 1.f));
            }
        }
        return float3(0.f);
    }
}

// Main kernel for rendering
[shader("compute")]
[numthreads(16, 16, 1)]
void render(
    uint3 thread_id: SV_DispatchThreadID,
    uniform camera cam,
    uniform hittable_list world,
    RWTexture2D<float4> image)
{
    uint i = thread_id.x, j = thread_id.y;
    // Shader housekeeping... make sure we are not exceeding the dispatch dimension.
    if (any(uint2(i, j) >= uint2(cam.image_width, cam.image_height)))
    {
        return;
    }
    // Initialize random number generator.
    RNG rng = RNG(uint2(i, j), cam.frame_number);

    ray r = cam.get_ray(i, j, rng);

    float3 pixel_color = cam.ray_color(r, world, rng);
    pixel_color = linear_to_gamma(pixel_color);

    interval intensity = interval(0.f, 1.f);
    pixel_color = intensity.clamp(pixel_color);

    // Streaming average - equals to sum / frame_number.
    image[uint2(i, j)] = float4(image[uint2(i, j)].xyz + (pixel_color - image[uint2(i, j)].xyz) / (cam.frame_number + 1), 1.0);
}