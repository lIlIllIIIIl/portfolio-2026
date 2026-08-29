/**
 * Associe les libellés présents dans `works.json` (#/stack[]) aux icônes Simple Icons,
 * uniquement celles réellement importées (bundler-friendly).
 */

import {
  siCss,
  siDotnet,
  siJavascript,
  siHtml5,
  siMongodb,
  siMysql,
  siNodedotjs,
  siPostgresql,
  siNextdotjs,
  siReact,
  siPrisma,
  siSymfony,
  siSqlite,
  siTailwindcss,
  siThreedotjs,
  siTypescript,
  siUnity,
  siVercel,
  siVite,
  siVuedotjs,
  siSass,
  siWebgl,
  siWebpack,
} from 'simple-icons'

/** @type {Record<string, import('simple-icons').SimpleIcon>} */
const KEY_TO_ICON = {
  'vue.js': siVuedotjs,
  vuejs: siVuedotjs,
  vue: siVuedotjs,

  'node.js': siNodedotjs,
  nodejs: siNodedotjs,
  node: siNodedotjs,

  javascript: siJavascript,
  js: siJavascript,

  typescript: siTypescript,
  ts: siTypescript,

  react: siReact,
  'react.js': siReact,

  'next.js': siNextdotjs,
  nextjs: siNextdotjs,
  next: siNextdotjs,

  symfony: siSymfony,
  unity: siUnity,

  tailwind: siTailwindcss,
  'tailwind css': siTailwindcss,
  tailwindcss: siTailwindcss,

  sass: siSass,
  scss: siSass,

  vite: siVite,
  html: siHtml5,
  html5: siHtml5,
  css: siCss,
  css3: siCss,

  'three.js': siThreedotjs,
  threejs: siThreedotjs,
  webgl: siWebgl,

  '.net': siDotnet,
  dotnet: siDotnet,
  'c#': siDotnet,
  csharp: siDotnet,

  prisma: siPrisma,
  mysql: siMysql,
  sqlite: siSqlite,
  mongodb: siMongodb,
  mongo: siMongodb,
  postgresql: siPostgresql,
  postgres: siPostgresql,
  webpack: siWebpack,
  vercel: siVercel,
}

/** @param {string} label */
export function normalizeStackLabel(label) {
  return label.trim().toLowerCase().replace(/\s+/g, ' ')
}

/** @param {string} label */
export function resolveStackIcon(label) {
  const key = normalizeStackLabel(label)
  if (KEY_TO_ICON[key]) { return KEY_TO_ICON[key] }
  const compact = key.replace(/[.\s]/g, '')
  return KEY_TO_ICON[compact] ?? null
}
