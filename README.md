# LightTracer
Simulating 2D Light Transport using Light Tracing (currently on CPU)</br>
Inspired by: https://benedikt-bitterli.me/tantalum/

In RayTracing, for each point we try to gather incomming light by sending rays in all directions and tracing their path.</br>
In LightTracing, we shoot rays from light source, trace the path they follow, then draw the path to the frame buffer (we splat the line paths to the image).</br>
It's better than RayTracing for our use case cause it gives sharper caustics.

The implementation doesnt priorities speed or accuracy, it just serve as a playground for some light experiments.</br>
And also it's more of a project I started to learn Beef Language (the best programming lang I found so far !).</br>

## Screenshots


## TODO
- Draw Paths using GPU
- Accurate Dispersion/Spectral Rendering
- Other Shapes/Lenses Support
- Mirrors/Diffusers
- Accurate BRDFs
