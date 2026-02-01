<script setup>
import * as THREE from 'three'

import VertexShader from '../shaders/vertex.glsl'
import FragmentShader from '../shaders/fragment.glsl'

const containerRef = ref(null)
let scene = null
let camera = null
let renderer = null
let mesh = null
let animationId = null
let startTime = 0

const vertexShader = VertexShader

const fragmentShader = FragmentShader

function init() {
  const container = containerRef.value
  if (!container) {
    return
  }

  scene = new THREE.Scene()
  camera = new THREE.OrthographicCamera(-1, 1, 1, -1, -1, 1)
  renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true })
  renderer.setSize(window.innerWidth, window.innerHeight)
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
  container.appendChild(renderer.domElement)

  const geometry = new THREE.PlaneGeometry(2, 2)
  const resolution = new THREE.Vector2()
  renderer.getDrawingBufferSize(resolution)
  const material = new THREE.ShaderMaterial({
    vertexShader,
    fragmentShader,
    uniforms: {
      uTime: { value: 0 },
      uResolution: { value: resolution.clone() },
    },
    depthWrite: false,
    transparent: true,
    // wireframe: true,
  })
  mesh = new THREE.Mesh(geometry, material)
  scene.add(mesh)

  startTime = performance.now() / 1000
}

function animate() {
  animationId = requestAnimationFrame(animate)
  if (!renderer || !scene || !camera || !mesh){
    return
  }
  const now = performance.now() / 1000
  mesh.material.uniforms.uTime.value = now - startTime
  renderer.getDrawingBufferSize(mesh.material.uniforms.uResolution.value)
  renderer.render(scene, camera)
}

function onResize() {
  if (!renderer || !camera){
    return
  }
  renderer.setSize(window.innerWidth, window.innerHeight)
  if (mesh?.material?.uniforms?.uResolution) {
    renderer.getDrawingBufferSize(mesh.material.uniforms.uResolution.value)
  }
}

function dispose() {
  if (animationId != null) {
    cancelAnimationFrame(animationId)
  }
  if (mesh?.geometry) {
    mesh.geometry.dispose()
  }
  if (mesh?.material) {
    mesh.material.dispose()
  }
  if (renderer) {
    renderer.dispose()
    if (containerRef.value?.contains(renderer.domElement)) {
      containerRef.value.removeChild(renderer.domElement)
    }
  }
  scene = null
  camera = null
  renderer = null
  mesh = null
}

onMounted(() => {
  init()
  animate()
  window.addEventListener('resize', onResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', onResize)
  dispose()
})
</script>

<template>
  <div ref="containerRef" class="shader-background" aria-hidden="true" />
</template>

<style scoped>
.shader-background {
  position: fixed;
  inset: 0;
  z-index: -1;
  overflow: hidden;
}

.shader-background canvas {
  display: block;
  width: 100%;
  height: 100%;
}
</style>
