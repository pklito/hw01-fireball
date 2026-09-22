# HW 1: WebGL Fireball

<img width="893" height="902" alt="image" src="https://github.com/user-attachments/assets/93c20796-a9b6-49e0-a028-98a256129d6a" />

<p align="center">(source: Me)</p>

## Submission
https://pklito.github.io/hw01-fireball/  

For this fireball, I've implemented both perlin noise, worley (from the last assignment, and FBM that uses both noise functions for the surface of the fireball. These apply displacements and fragment color to the sphere surface, as well as a low frequency sine wave, and some other squashes I did in order to give it a better shape.

I also implemented a realistic kelvin to RGB formula: //https://tannerhelland.com/2012/09/18/convert-temperature-rgb-algorithm-code.html
which i use for the surface color of the fireball.

The sine wave displacement, type of noise used, and surface temperature are adjustable.

For the background, I placed a 2D square and fake a spherical projection using the UV coordinates of the screen, to produce the worley effect around the fireball.
