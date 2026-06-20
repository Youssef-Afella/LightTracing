namespace LightTracing;

using System;

class LightTracing : Renderer
{
	//Constants ------------------------------------------
	const int RAYS_PER_FRAME = 128;
	const int RAYS_MAX_BOUNCES = 10;
	const int SPECTRUM_SAMPLES = 7;

	const float LIGHT_INTENSITY = 500.0f;
	const float DISPERSION = 0.2f;

	//Global Variables -----------------------------------
	private Randomf mRand = new Randomf() ~ delete _;
	private Vec2  mLightPos;
	private float mLightRange = 2.0f;
	private float mLightDir = 0.0f;
	private float mLightContribution;

	private int selectedScene = 0;
	private bool bounceEnabled = false;

	public this()
	{
		mLightPos = Vec2(mWidth * 0.2f, mHeight * 0.5f);
		mLightContribution = LIGHT_INTENSITY / (RAYS_PER_FRAME * SPECTRUM_SAMPLES);
		
		Console.WriteLine("Press Keyboard Key to switch demo scene :");
		Console.WriteLine("");
		Console.WriteLine("[A]: Scene 1 (Disks)");
		Console.WriteLine("[S]: Scene 2 (Prism)");
		Console.WriteLine("");
		Console.WriteLine("[Q]: Point Light");
		Console.WriteLine("[W]: Directional Light (Set Direction: Right Click)");
		Console.WriteLine("");
		Console.WriteLine("[D]: Enable/Disable Bounced Light");
	}


	private float GetReflectance(Vec2 i, Vec2 t, Vec2 nor, float iora, float iorb)
	{
	    float cosi = i.Dot(nor);
	    float cost = t.Dot(nor);
	    float rs = (iora * cosi - iorb * cost) / (iora * cosi + iorb * cost);
	    float rp = (iorb * cosi - iora * cost) / (iorb * cosi + iora * cost);
	    return (rs * rs + rp * rp) * 0.5f;
	}

	//Fake Dispersion
	//TODO: Correct Physical Dispersion
	private Vec3 GetDispersionColor(float t)
	{
		float r = Math.Sin(t * Math.PI_f * 2.0f);
		float g = Math.Sin((t - 0.25f) * Math.PI_f * 2.0f);
		float b = Math.Sin((t - 0.5f) * Math.PI_f * 2.0f);
		return Vec3(Math.Clamp(r, 0.0f, 1.0f), Math.Clamp(g, 0.0f, 1.0f), Math.Clamp(b, 0.0f, 1.0f));
	}

	private HitData Intersect(Vec2 ro, Vec2 rd)
	{
	    HitData hit = HitData();
	    hit.distance = 100000.0f;

		Scenes.SceneElement[] elements = Scenes.scenes[selectedScene].elements;
	    
	    for(int i = 0; i < elements.Count; i++)
	    {
	        Vec2 pos = elements[i].position;

			switch(elements[i].type){

			case 0:
				float t = RayMath.RayCircle(ro, rd, pos, elements[i].size);

				if(t < hit.distance && t > 0.0f)
				{
				    hit.distance = t;
				    
				    bool isEntering = (ro - pos).Length() >= elements[i].size;
				    Vec2 p = ro + (rd * t);

				    hit.normal = (p - pos).Normalize() * (isEntering ? 1.0f : -1.0f);
				    hit.ior = isEntering ? elements[i].ior : 1.0f;
					hit.isDispersive = isEntering;
				}

				break;

			case 1:
				Vec3 t = RayMath.RayAABB(ro, rd, pos - Vec2(elements[i].size), pos + Vec2(elements[i].size));

				if(Math.Abs(t.x) < hit.distance && t.x != 0.0f)
				{
				    hit.distance = Math.Abs(t.x);
				    hit.normal = Vec2(t.y, t.z);
					hit.isDispersive = t.x > 0;
				    hit.ior = t.x > 0 ? elements[i].ior : 1.0f;
				}
				break;

			case 2:

				bool isInside;
				Vec3 t = RayMath.RayTriangle(ro, rd,
					pos + Vec2(-0.86f, 0.5f) * elements[i].size,
					pos + Vec2(0.0f, -1.0f) * elements[i].size,
					pos + Vec2(0.86f, 0.5f) * elements[i].size, out isInside);
	
				if(t.x < hit.distance && t.x != float.MaxValue)
				{
					hit.distance = t.x;
					hit.normal = Vec2(t.y, t.z);
					hit.isDispersive = !isInside;
					hit.ior = isInside ? 1.0f : elements[i].ior;
				}
				break;
			}
		
		}
	    
	    return hit;
	}

	private void DrawRay(Vec2 a, Vec2 b, Vec2 rd, Vec3 color)
	{
		//Overcoming Rasterization Bias : https://benedikt-bitterli.me/tantalum/
		float biasCorrection = 1.0f / Math.Max(Math.Abs(rd.x), Math.Abs(rd.y));
		DrawLineDDA(a.x, a.y, b.x, b.y, color * biasCorrection);
	}

	private void Trace(Vec2 rayOrigin, Vec2 rayDir, float iorVariation)
	{
		Vec2 ro = rayOrigin;
		Vec2 rd = rayDir;
		float lastIOR = 1.0f;

		float energy = 1.0f;
		Vec3 colorMask = GetDispersionColor(iorVariation);

		for(int i = 0; i < RAYS_MAX_BOUNCES; i++)
		{
			HitData hit = Intersect(ro, rd);

			if(hit.distance > 99999.0f)//No hit
			{
				Vec3 wallHit = RayMath.RayAABB(ro, rd, Vec2(0.0f), Vec2(mWidth, mHeight));
				DrawRay(ro, ro + rd * Math.Abs(wallHit.x), rd, colorMask * (mLightContribution * energy));

				if(bounceEnabled)
				{
					Vec2 normal = Vec2(wallHit.y, wallHit.z);
					ro += rd * Math.Abs(wallHit.x);
					ro += normal * 0.1f;

					float randAngle = mRand.nextFloat() * Math.PI_f;
					float randOffset = 0;

					if(normal.x == -1.0f)
					{
						randOffset = Math.PI_f * 0.5f;
					}
					else if(normal.x == 1.0f)
					{
						randOffset = -Math.PI_f * 0.5f;
					}
					else if(normal.y == 1.0f)
					{
						randOffset = 0;
					}
					else if(normal.y == -1.0f)
					{
						randOffset = Math.PI_f;
					}

					energy *= 0.3f;
					Vec2 randDir = Vec2(Math.Cos(randAngle + randOffset), Math.Sin(randAngle + randOffset));
					rd = randDir;

					continue;
				}
				else{
					return;
				}
			}

			
			DrawRay(ro, ro + rd * hit.distance, rd, colorMask * (mLightContribution * energy));
			ro += rd * hit.distance;
			hit.ior += (iorVariation - 0.5f) * DISPERSION * (hit.isDispersive ? 1.0f : 0.0f);//Applying dispersion

			Vec2 reflected = rd.Reflect(hit.normal);
			Vec2 refracted = rd.Refract(hit.normal, lastIOR / hit.ior);
			float reflectance = GetReflectance(rd, refracted, hit.normal, lastIOR, hit.ior);

			bool reflectIt = mRand.nextFloat() < reflectance;

			if(reflectIt)
			{
			    ro += (hit.normal * 0.1f);
			    rd = reflected;
				//energy *= reflectance;
			}
			else{
			    ro -= (hit.normal * 0.1f);
			    rd = refracted;
				//energy *= (1.0f - reflectance);
				lastIOR = hit.ior;
			}
		}
	}

	public override void RenderFrame()
	{
		for(int i = 0; i < RAYS_PER_FRAME; i++)
		{
			float a = (i + mRand.nextFloat()) / RAYS_PER_FRAME;
			float angle = a * Math.PI_f * mLightRange + mLightDir;

			Vec2 dir = Vec2(Math.Sin(angle), Math.Cos(angle));

			for(int j = 0; j < SPECTRUM_SAMPLES; j++)
			{
				float iorVariation = (j + mRand.nextFloat()) / SPECTRUM_SAMPLES;
				Trace(mLightPos, dir, iorVariation);
			}
		}
	}

	public override void MouseDrag(SDL2.SDL.MouseButtonEvent evt)
	{
		if(evt.button == SDL2.SDL.SDL_BUTTON_LEFT)
		{
			mLightPos = Vec2(evt.x, evt.y);
		}

		if(evt.button == SDL2.SDL.SDL_BUTTON_RIGHT || evt.button == SDL2.SDL.SDL_BUTTON_X1)
		{
			Vec2 p = .(evt.x, evt.y);
			Vec2 dir = (p - mLightPos).Normalize();

			mLightDir = Math.Atan2(dir.x, dir.y);
		}
	}

	public override void KeyDown(SDL2.SDL.KeyboardEvent evt)
	{
		if(evt.keysym.scancode == .A){
			selectedScene = 0;
			ClearFrameBuffer();
		}

		if(evt.keysym.scancode == .S){
			selectedScene = 1;
			ClearFrameBuffer();
		}

		if(evt.keysym.scancode == .Q)
		{
			if(mLightRange != 2.0f) mLightContribution *= 4.0f;
			mLightRange = 2.0f;

			ClearFrameBuffer();
		}

		if(evt.keysym.scancode == .W)
		{
			if(mLightRange != 0.0f) mLightContribution *= 0.25f;
			mLightRange = 0.001f;

			ClearFrameBuffer();
		}

		if(evt.keysym.scancode == .D)
		{
			bounceEnabled = !bounceEnabled;
			ClearFrameBuffer();
		}
	}

	struct HitData
	{
		public bool isDispersive;
		public float ior;
		public float distance;
		public Vec2 normal;
	}
}