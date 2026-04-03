struct ray
{
    float3 orig, dir;
    __init(in float3 origin, in float3 direction)
    {
        orig = origin;
        dir = direction;
    }

    float3 origin()
    {
        return orig;
    }
    float3 direction()
    {
        return dir;
    }
    float3 at(float t)
    {
        return orig + t * dir;
    }
}