import {vec3, vec4} from 'gl-matrix';
import Stats from 'stats-js';
import GUI from 'lil-gui';
import Icosphere from './geometry/Icosphere';
import Cube from './geometry/Cube';
import Square from './geometry/Square';

import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';

import noiseSource from './shaders/noise.glsl?raw';
import colorSource from './shaders/color.glsl?raw';
import lambertVertSource from './shaders/lambert-vert.glsl?raw';
import lambertFragSource from './shaders/lambert-frag.glsl?raw';

import BGVertSource from './shaders/background-vert.glsl?raw';
import BGFragSource from './shaders/background-frag.glsl?raw';
import Drawable from './rendering/gl/Drawable';

const controls = {
  tesselations: 5,
  'Load Scene': loadScene, // A function pointer, essentially
  temperature : 6000.0,
  wobble : 0.045,
  noise : 1
};

let icosphere: Icosphere;
let background : Square;
let prevTesselations: number = 5;
let prevColor : vec4 = vec4.fromValues(0.0, 0, 0, 1.0);

function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
  icosphere.create();
  background = new Square(vec3.fromValues(0, 0, 0));
  background.create();
}

function main() {
  // Initial display for framerate
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  // Add controls to the gui
  const gui = new GUI();
  gui.add(controls, 'tesselations', 0, 8).step(1);
  gui.add(controls, 'Load Scene');
  gui.add(controls, 'temperature');
  gui.add(controls, 'wobble', 0, 0.5);
  gui.add(controls, 'noise', {FMB_Worley : 1, FBM_Perlin : 2, Perlin : 3});

  // get canvas and webgl context
  const canvas = <HTMLCanvasElement> document.getElementById('canvas');
  const gl = <WebGL2RenderingContext> canvas.getContext('webgl2');
  if (!gl) {
    alert('WebGL 2 not supported!');
  }
  // `setGL` is a function imported above which sets the value of `gl` in the `globals.ts` module.
  // Later, we can import `gl` from `globals.ts` to access it
  setGL(gl);

  // Initial call to load scene
  loadScene();

  const camera = new Camera(vec3.fromValues(0, 0, 5), vec3.fromValues(0, 0, 0));

  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(0.2, 0.2, 0.2, 1);
  gl.enable(gl.DEPTH_TEST);

  //backface culling
  gl.enable(gl.CULL_FACE);
  gl.cullFace(gl.BACK);
  gl.frontFace(gl.CCW);

  const initSource = "#version 300 es \nprecision highp float;"
  const lambert = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, initSource + colorSource + noiseSource + lambertVertSource),
    new Shader(gl.FRAGMENT_SHADER,initSource + colorSource + noiseSource + lambertFragSource),
  ]);

  const bg = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, initSource + colorSource + noiseSource + BGVertSource),
    new Shader(gl.FRAGMENT_SHADER,initSource + colorSource + noiseSource + BGFragSource),
  ])

  // This function will be called every frame
  function tick() {
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();
    if(controls.tesselations != prevTesselations)
    {
      prevTesselations = controls.tesselations;
      icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, prevTesselations);
      icosphere.create();
    }
    lambert.setGeometryTemp(controls.temperature);
    // lambert.setTemperature(controls.)
    lambert.setWobble(controls.wobble);
    lambert.setNoise(controls.noise);
    renderer.render(camera, bg, [background]);
    renderer.render(camera, lambert, [icosphere]);

    stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
  }, false);

  
  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();

  // Start the render loop
  tick();
}

main();
