namespace LightTracing;

using System;

static class RayMath
{
	public static float RayCircle(Vec2 ro, Vec2 rd, Vec2 c, float r)
	{
	    Vec2 oc = ro - c;

	    float b = oc.Dot(rd);
	    float c0 = oc.Dot(oc) - r * r;
	    float h = b * b - c0;

	    if (h < 0.0f) return -1.0f;

	    h = Math.Sqrt(h);

	    float t = -b - h;
	    if (t < 0.0f) t = -b + h;
	    if (t < 0.0f) return -1.0f;

	    return t;
	}

	public static Vec3 RayAABB(Vec2 ro, Vec2 rd, Vec2 bmin, Vec2 bmax)
	{
	    Vec2 ird = Vec2(1.0f / rd.x, 1.0f / rd.y);
	    Vec2 tMin = (bmin - ro) * ird;
	    Vec2 tMax = (bmax - ro) * ird;

	    Vec2 t1 = Vec2(Math.Min(tMin.x, tMax.x), Math.Min(tMin.y, tMax.y));
	    Vec2 t2 = Vec2(Math.Max(tMin.x, tMax.x), Math.Max(tMin.y, tMax.y));

	    float tNear = Math.Max(t1.x, t1.y);
	    float tFar = Math.Min(t2.x, t2.y);

	    if (tFar < 0.0 || tNear > tFar) return Vec3(0.0f, 0.0f, 0.0f);

		Vec2 n1 = Vec2(tNear).Step(t1) * (-rd.Sign());
		Vec2 n2 = t2.Step(Vec2(tFar)) * (-rd.Sign());

	    return (tNear > 0.0) ? Vec3(tNear, n1.x, n1.y)
	                         : Vec3(-tFar, n2.x, n2.y);
	}

	public static Vec3 RayTriangle(Vec2 ro, Vec2 rd, Vec2 p0, Vec2 p1, Vec2 p2, out bool isInside)
	{
	    Vec2[] vertices = scope Vec2[](p0, p1, p2);

		float hitDistance = float.MaxValue;
		Vec2 hitNormal = Vec2(0.0f, 0.0f);

		float d1 = (ro - p0).Cross(p1 - p0);
		float d2 = (ro - p1).Cross(p2 - p1);
		float d3 = (ro - p2).Cross(p0 - p2);
		bool hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0);
		bool hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0);

		isInside = !(hasNeg && hasPos);

	    for (int i = 0; i < 3; i++)
	    {
	        Vec2 a = vertices[i];
	        Vec2 b = vertices[(i + 1) % 3];

	        Vec2 v1 = ro - a;
	        Vec2 v2 = b - a;
	        Vec2 v3 = Vec2(-rd.y, rd.x);

	        float dot = v2.Dot(v3);

	        if (Math.Abs(dot) < 0.000001f)
	            continue;

	        float t1 = v2.Cross(v1) / dot;
	        float t2 = v1.Dot(v3) / dot;

	        if (t1 >= 0 && t2 >= 0 && t2 <= 1)
	        {
	            if (t1 < hitDistance)
	            {
	                hitDistance = t1;
	                
	                Vec2 edge = b - a;
	                Vec2 normal = Vec2(-edge.y, edge.x).Normalize();

	                if (normal.Dot(rd) > 0)
	                {
	                    normal = Vec2(edge.y, -edge.x).Normalize();
	                }

	                hitNormal = normal;
	            }
	        }
	    }

	    return Vec3(hitDistance, hitNormal.x, hitNormal.y);
	}
}