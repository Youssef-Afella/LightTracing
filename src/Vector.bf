namespace LightTracing;

using System;

public struct Vec2
{
	public float x, y;

	public this(float x, float y)
	{
	    this.x = x;
		this.y = y;
	}

	public this(float a)
	{
	    this.x = a;
		this.y = a;
	}

	public static Vec2 operator+(Vec2 lhs, Vec2 rhs)
	{
	    return .(lhs.x + rhs.x, lhs.y + rhs.y);
	}

	public static Vec2 operator-(Vec2 lhs, Vec2 rhs)
	{
	    return .(lhs.x - rhs.x, lhs.y - rhs.y);
	}

	public static Vec2 operator*(Vec2 lhs, Vec2 rhs)
	{
	    return .(lhs.x * rhs.x, lhs.y * rhs.y);
	}

	public static Vec2 operator*(Vec2 lhs, float t)
	{
	    return .(lhs.x * t, lhs.y * t);
	}

	public static Vec2 operator-(Vec2 val)
	{
	    return .(-val.x, -val.y);
	}

	public void operator+=(Vec2 rhs) mut
	{
	    x += rhs.x;
		y += rhs.y;
	}

	public void operator-=(Vec2 rhs) mut
	{
	    x -= rhs.x;
		y -= rhs.y;
	}

	public void operator*=(Vec2 rhs) mut
	{
	    x *= rhs.x;
		y *= rhs.y;
	}

	public float Length(){
		return Math.Sqrt(x * x + y * y);
	}

	public float Dot(Vec2 b){
		return x * b.x + y * b.y;
	}

	public float Cross(Vec2 b){
		return x * b.y - y * b.x;
	}

	public Vec2 Normalize()
	{
		float length = Length();
		return Vec2(x / length, y / length);
	}

	public Vec2 Reflect(Vec2 n)
	{
	    float dot = Dot(n);
	    return this - (n * (2.0f * dot));
	}

	public Vec2 Refract(Vec2 n, float eta)
	{
	    float dot = Dot(n);
	    float k = 1.0f - eta * eta * (1.0f - dot * dot);
	    float s = eta * dot + Math.Sqrt(k);
	    return Vec2(eta * x - s * n.x, eta * y - s * n.y);
	}

	public Vec2 Step(Vec2 t)
	{
		return Vec2(t.x >= x ? 1.0f : 0.0f, t.y >= y ? 1.0f : 0.0f);
	}

	public Vec2 Sign(){
		return Vec2(x >= 0 ? 1 : -1, y >= 0 ? 1 : -1);
	}
}

public struct Vec3
{
	public float x, y, z;

	public this(float x, float y, float z)
	{
	    this.x = x;
		this.y = y;
		this.z = z;
	}

	public this(float a){
		x = a;
		y = a;
		z = a;
	}

	public static Vec3 operator+(Vec3 lhs, Vec3 rhs)
	{
	    return .(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z);
	}

	public static Vec3 operator*(Vec3 lhs, Vec3 rhs)
	{
	    return .(lhs.x * rhs.x, lhs.y * rhs.y, lhs.z * rhs.z);
	}

	public static Vec3 operator/(Vec3 lhs, Vec3 rhs)
	{
	    return .(lhs.x / rhs.x, lhs.y / rhs.y, lhs.z / rhs.z);
	}

	public static Vec3 operator+(Vec3 lhs, float t)
	{
	    return .(lhs.x + t, lhs.y + t, lhs.z + t);
	}

	public static Vec3 operator*(Vec3 lhs, float t)
	{
	    return .(lhs.x * t, lhs.y * t, lhs.z * t);
	}

	public static Vec3 operator-(Vec3 val)
	{
	    return .(-val.x, -val.y, -val.z);
	}

	public void operator+=(Vec3 rhs) mut
	{
	    x += rhs.x;
		y += rhs.y;
	    z += rhs.z;
	}

	public void operator*=(Vec3 rhs) mut
	{
	    x *= rhs.x;
		y *= rhs.y;
	    z *= rhs.z;
	}
}