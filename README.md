# LightTracer
Simulating 2D Light Transport using Light Tracing (currently on CPU)</br>
Inspired by: https://benedikt-bitterli.me/tantalum/

In RayTracing, for each point we try to gather incomming light by sending rays in all directions and tracing their path.</br>
In LightTracing, we shoot rays from light source, trace the path they follow, then draw the path to the frame buffer (we splat the line paths to the image).</br>
It's better than RayTracing for our use case cause it gives sharper caustics.

The implementation doesnt priorities speed or accuracy, it just serve as a playground for some light experiments.</br>
And also it's more of a project I started to learn Beef Language (the best programming lang I found so far !).</br>

## Screenshots
<img width="1002" height="739" alt="Untitled-7" src="https://github.com/user-attachments/assets/a107f2de-67e9-4702-acd5-132f3df989e0" />

<img width="1002" height="739" alt="Untitled-6" src="https://github.com/user-attachments/assets/7df726fa-c530-4b50-b645-75a8d8328e2e" />

<img width="1002" height="739" alt="Untitled-5" src="https://github.com/user-attachments/assets/82c5ae77-1978-4618-abb9-673e0e91528f" />

<img width="1002" height="739" alt="Untitled-4" src="https://github.com/user-attachments/assets/b1980e1e-4606-4aee-983c-60f6c4940caf" />

<img width="1002" height="739" alt="Untitled-3" src="https://github.com/user-attachments/assets/fecd7a6c-41fa-49cc-bce0-12781c636fe1" />

<img width="1002" height="739" alt="Untitled-2" src="https://github.com/user-attachments/assets/68433ace-e1b9-421d-adb2-ec10e9863fb4" />

## TODO
- Draw Paths using GPU
- Accurate Dispersion/Spectral Rendering
- Other Shapes/Lenses Support
- Mirrors/Diffusers
- Accurate BRDFs
