namespace LightTracing;

using SDL2;
using System;
using System.IO;
using System.Diagnostics;
using System.Threading;

public class Renderer
{
	public String mTitle = new .("Light Tracing") ~ delete _;
	public int32 mWidth = 1000;
	public int32 mHeight = 700;

	private SDL.Window* mWindow;
	private SDL.Surface* mSurface;
	private Vec3[] frameBuffer;

	public int mFrames = 0;

	public this()
	{
		mWindow = SDL.CreateWindow(mTitle, .Undefined, .Undefined, mWidth, mHeight, .Shown);
		mSurface = SDL.GetWindowSurface(mWindow);

		frameBuffer = new Vec3[mWidth * mHeight];
		ClearFrameBuffer();

	}

	public ~this()
	{
		if(frameBuffer != null)
			delete frameBuffer;
		if (mWindow != null)
			SDL.DestroyWindow(mWindow);
	}

	Vec3 Tonemapping(Vec3 x)
	{
		//Tanh Tonemapping from XorDev : https://mini.gmshaders.com/p/tonemaps
		return Vec3(Math.Tanh(x.x), Math.Tanh(x.y), Math.Tanh(x.z));

		//ACES Tonemapping
		/*float a = 2.51f;
		float b = 0.03f;
		float c = 2.43f;
		float d = 0.59f;
		float e = 0.14f;
		return (x*(x*a + b)) / (x*(x*c+d)+e);*/
	}

	Vec3 LinearToGamma(Vec3 t)
	{
		//Fast Approximation
		return Vec3(Math.Sqrt(t.x), Math.Sqrt(t.y), Math.Sqrt(t.z));

		//const float c = 1.0f/2.2f;
	    //return Vec3(Math.Pow(t.x, c), Math.Pow(t.y, c), Math.Pow(t.z, c));
	}

	public void BlitFrameBuffer()
	{
		uint8* pixels = (uint8*)mSurface.pixels;
		float weight = 1.0f / (mFrames + 1.0f);

		for (int y = 0; y < mHeight; y++)
		{
		    for (int x = 0; x < mWidth; x++)
			{
				Vec3 color = frameBuffer[x + y * mWidth] * weight;
				color = Tonemapping(color);
				color = LinearToGamma(color);

		        uint8 b = (uint8)(color.x * 255.0f);
		        uint8 g = (uint8)(color.y * 255.0f);
		        uint8 r = (uint8)(color.z * 255.0f);

				pixels[x * 4 + y * mSurface.pitch + 0] = r;
				pixels[x * 4 + y * mSurface.pitch + 1] = g;
				pixels[x * 4 + y * mSurface.pitch + 2] = b;
				pixels[x * 4 + y * mSurface.pitch + 3] = 255;
		    }
		}

		SDL.UpdateWindowSurface(mWindow);
	}

	public void Run()
	{
		bool mouseDown = false;

		while (true) {
			SDL.Event event;

			while (SDL.PollEvent(out event) != 0)
			{
				switch(event.type)
				{
					case .Quit:
						return;
					case .KeyDown:
						KeyDown(event.key);
					case .MouseButtonDown:
						mouseDown = true;
						MouseDrag(event.button);
					case .MouseButtonUp:
						mouseDown = false;
					case .MouseMotion:
						if(mouseDown){
							MouseDrag(event.button);
						}
					default:
				}
			}

			String str = scope String(256);
			str.AppendF("Light Tracing | Frames {}", mFrames);
			SDL.SetWindowTitle(mWindow, str);

			BlitFrameBuffer();

			if(mouseDown)
			{
				ClearFrameBuffer();
			}

			RenderFrame();

			mFrames ++;
		}
	}

	public virtual void RenderFrame(){}
	public virtual void KeyDown(SDL.KeyboardEvent evt){}
	public virtual void MouseDrag(SDL.MouseButtonEvent evt){}

	//Utility Functions -----------------------------------------------
	public void ClearFrameBuffer()
	{
		mFrames = 0;
		for(int i = 0; i < mWidth * mHeight; i++)
		{
			frameBuffer[i] = Vec3(0.0f, 0.0f, 0.0f);
		}
	}

	public void AddPixelColor(int x, int y, Vec3 color)
	{
		if(x < 0 || y < 0 || x >= mWidth || y >= mHeight) return;
		frameBuffer[x + y * mWidth] += color;
	}

	public void DrawLineDDA(float x0, float y0, float x1, float y1, Vec3 color)
	{
	    float dx = x1 - x0;
	    float dy = y1 - y0;

	    float steps = (Math.Abs(dx) > Math.Abs(dy)) ? Math.Abs(dx) : Math.Abs(dy);

	    if (steps == 0.0f) {
	        AddPixelColor((int)Math.Round(x0), (int)Math.Round(y0), color);
	        return;
	    }

	    float xStep = dx / steps;
	    float yStep = dy / steps;

	    float x = x0;
	    float y = y0;

	    for (int i = 0; i <= (int)steps; i++) {
	        AddPixelColor((int)Math.Round(x), (int)Math.Round(y), color);
	        
	        x += xStep;
	        y += yStep;
	    }
	}
}
