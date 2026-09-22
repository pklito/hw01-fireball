# HW 1: WebGL Fireball
<img width="1907" height="902" alt="Screenshot 2026-09-22 025427" src="https://github.com/user-attachments/assets/5a1f3ab4-0432-4711-8317-51f59a46d51e" />

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/7966e7c5-1d81-4042-b2ed-4b3e189d21aa" height="100%" /></td>
    <td><img src="https://github.com/user-attachments/assets/e7dadf3f-f454-41fa-a6b6-79478fe87f19" height="100%" /></td>
    <td><img src="https://github.com/user-attachments/assets/bc333e92-6352-4032-b5bb-cb2096208f01" height="100%" /></td>
  </tr>
</table>
<p align="center">Different Temperature values (source: Me)</p>

**Photo sensitivity warning**: at high temperatures pressing the shoot fireball flashes half of the screen.
## Submission
https://pklito.github.io/hw01-fireball/  

## Task features:
The vertices are displaced with a soft wobble sine wave, as well as a choosable spacial noise function between: **[perlin, fbm(worley), fbm(perlin)]**, as well as some manual modifications to make the fireball shape suit my intended vision.  
The fragment shader of the fireball maps the same noise function (minus my additional warping) to a temperature, which is then converted to RGB (see below).  

The temperature is customizable, and it affects the color of the fireball, as well as the frequency of some of the objects movements.  
The sine wave wobble intensity is also customizable, and lastly, the noise functions, as mentioned above.

For the background, I placed a 2D square and fake a spherical projection using the UV coordinates of the screen, to produce the worley effect around the fireball, with a very low amplitude fbm on top of it.

Lastly, I have the "**Shoot fireball**" feature. this sends the fireball flying, where it shrinks and reappears at the origin.
The background shader lights up, with the **pattern changing depending on the fireball temperature**.

## Implementation
For this fireball, I've implemented both perlin noise, worley (from the last assignment, and FBM that uses both noise functions for the surface of the fireball. These apply displacements and fragment color to the sphere surface, as well as a low frequency sine wave, and some other squashes I did in order to give it a better shape.  

I decided trying to split my code into several `.glsl` files, which proved to be somewhat helpful but also a host to many inconveniences. My naive implementation is as follows:
```typescript
const initSource = "#version 300 es \nprecision highp float;"
  const lambert = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, initSource + colorSource + noiseSource + lambertVertSource),
    new Shader(gl.FRAGMENT_SHADER,initSource + colorSource + noiseSource + lambertFragSource),
  ]);
```
**Note**: As you you may guess, this breaks the error messages and the linter, also some conventions. so if you look into a shader and see missing uniforms, theyre probably defined in `noise.glsl` or `colors.glsl`.

I used quint/smootherstep quite often in this task, I also decided to use a `quint(triangle(u_Time))` wave for a slight movement of the whole fireball.

I also implemented a realistic kelvin to RGB formula: //https://tannerhelland.com/2012/09/18/convert-temperature-rgb-algorithm-code.html
which i use for the surface color of the fireball.  
Most of my visuals are based on this float -> RGB mapping.
