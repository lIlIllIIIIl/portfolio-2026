uniform float uTime;
uniform vec2 uResolution;

// Pseudo-random à partir d'un vec2 (pour la couche blanche animée)
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// Bruit valeur 2D lissé, animé par décalage dans le temps
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f); // smoothstep-like
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// Position d'un sommet = base + drift lent + wobble rapide
vec2 vertexPos(vec2 base, float seedX, float seedY, float tc, float tw, float drift, float wobble) {
    vec2 slow = drift * vec2(noise(vec2(seedX, tc)) - 0.5, noise(vec2(seedY, tc + 0.2)) - 0.5);
    vec2 fast = wobble * vec2(noise(vec2(seedX + 10.0, tw)) - 0.5, noise(vec2(seedY + 10.0, tw + 0.3)) - 0.5);
    return base + slow + fast;
}

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;
    float t = uTime * 0.9;

    // Dégradé animé #020316 → #5F546A, variation surtout horizontale
    float n = 0.5
        + 0.25 * cos(t + uv.x * 1.2)
        + 0.18 * cos(t * 0.7 + uv.x * 0.6 + uv.y * 0.2)
        + 0.12 * cos(t * 0.4 + uv.x * 0.35);
    // Tendance verticale : plus foncé en haut, plus clair en bas
    float verticalBias = 0.55;
    float topWeight = pow(uv.y, 2.0);
    n = n - verticalBias * topWeight;
    n = clamp(n, 0.0, 1.0);
    // Contraste modéré (entre l’original et la version forte)
    n = clamp((n - 0.5) * 1.2 + 0.5, 0.0, 1.0);

    vec3 dark = vec3(0.006, 0.01, 0.072);    // entre #020316 et version assombrie
    vec3 violet = vec3(0.32, 0.28, 0.36);    // entre #5F546A et version assombrie
    vec3 col = mix(dark, violet, n);
    col *= 0.96;  // Légèrement plus foncé que l’original, plus clair qu’avant

    // Couche type fumée : 8 sommets avec mouvement aléatoire (vitesse ralentie)
    float margin = -0.15;  // Marge négative pour permettre le mouvement hors écran
    float tc = t * 0.055;  // Vitesse principale (drift lent)
    float tw = t * 0.32;   // Vitesse du tremblement / oscillation
    float drift = 0.75;    // Amplitude du mouvement lent
    float wobble = 0.12;   // Amplitude de l'oscillation rapide (sommets plus « vivants »)
    
    // 4 coins initiaux - mouvement libre + oscillation
    vec2 bl = vertexPos(vec2(0.08, 0.08), 0.0, 0.5, tc, tw, drift, wobble);
    bl = vec2(clamp(bl.x, margin, 1.0 - margin), clamp(bl.y, margin, 1.0 - margin));
    vec2 br = vertexPos(vec2(0.92, 0.08), 1.0, 1.5, tc, tw, drift, wobble);
    br = vec2(clamp(br.x, margin, 1.0 - margin), clamp(br.y, margin, 1.0 - margin));
    vec2 tl = vertexPos(vec2(0.08, 0.92), 2.0, 2.5, tc, tw, drift, wobble);
    tl = vec2(clamp(tl.x, margin, 1.0 - margin), clamp(tl.y, margin, 1.0 - margin));
    vec2 tr = vertexPos(vec2(0.92, 0.92), 3.0, 3.5, tc, tw, drift, wobble);
    tr = vec2(clamp(tr.x, margin, 1.0 - margin), clamp(tr.y, margin, 1.0 - margin));
    
    // 4 sommets au milieu des côtés
    vec2 bm = vertexPos(vec2(0.5, 0.08), 4.0, 4.5, tc, tw, drift, wobble);
    bm = vec2(clamp(bm.x, margin, 1.0 - margin), clamp(bm.y, margin, 1.0 - margin));
    vec2 rm = vertexPos(vec2(0.92, 0.5), 5.0, 5.5, tc, tw, drift, wobble);
    rm = vec2(clamp(rm.x, margin, 1.0 - margin), clamp(rm.y, margin, 1.0 - margin));
    vec2 tm = vertexPos(vec2(0.5, 0.92), 6.0, 6.5, tc, tw, drift, wobble);
    tm = vec2(clamp(tm.x, margin, 1.0 - margin), clamp(tm.y, margin, 1.0 - margin));
    vec2 lm = vertexPos(vec2(0.08, 0.5), 7.0, 7.5, tc, tw, drift, wobble);
    lm = vec2(clamp(lm.x, margin, 1.0 - margin), clamp(lm.y, margin, 1.0 - margin));
    
    // Calcul de la distance perpendiculaire à chaque segment (8 segments pour 8 sommets)
    vec2 p = uv;
    
    // Segment 1: bl → bm
    vec2 seg1Dir = bm - bl;
    float seg1Len = length(seg1Dir);
    float t1 = clamp(dot(p - bl, seg1Dir) / (seg1Len * seg1Len + 0.0001), 0.0, 1.0);
    float dSeg1 = length(p - (bl + t1 * seg1Dir));
    
    // Segment 2: bm → br
    vec2 seg2Dir = br - bm;
    float seg2Len = length(seg2Dir);
    float t2 = clamp(dot(p - bm, seg2Dir) / (seg2Len * seg2Len + 0.0001), 0.0, 1.0);
    float dSeg2 = length(p - (bm + t2 * seg2Dir));
    
    // Segment 3: br → rm
    vec2 seg3Dir = rm - br;
    float seg3Len = length(seg3Dir);
    float t3 = clamp(dot(p - br, seg3Dir) / (seg3Len * seg3Len + 0.0001), 0.0, 1.0);
    float dSeg3 = length(p - (br + t3 * seg3Dir));
    
    // Segment 4: rm → tr
    vec2 seg4Dir = tr - rm;
    float seg4Len = length(seg4Dir);
    float t4 = clamp(dot(p - rm, seg4Dir) / (seg4Len * seg4Len + 0.0001), 0.0, 1.0);
    float dSeg4 = length(p - (rm + t4 * seg4Dir));
    
    // Segment 5: tr → tm
    vec2 seg5Dir = tm - tr;
    float seg5Len = length(seg5Dir);
    float t5 = clamp(dot(p - tr, seg5Dir) / (seg5Len * seg5Len + 0.0001), 0.0, 1.0);
    float dSeg5 = length(p - (tr + t5 * seg5Dir));
    
    // Segment 6: tm → tl
    vec2 seg6Dir = tl - tm;
    float seg6Len = length(seg6Dir);
    float t6 = clamp(dot(p - tm, seg6Dir) / (seg6Len * seg6Len + 0.0001), 0.0, 1.0);
    float dSeg6 = length(p - (tm + t6 * seg6Dir));
    
    // Segment 7: tl → lm
    vec2 seg7Dir = lm - tl;
    float seg7Len = length(seg7Dir);
    float t7 = clamp(dot(p - tl, seg7Dir) / (seg7Len * seg7Len + 0.0001), 0.0, 1.0);
    float dSeg7 = length(p - (tl + t7 * seg7Dir));
    
    // Segment 8: lm → bl
    vec2 seg8Dir = bl - lm;
    float seg8Len = length(seg8Dir);
    float t8 = clamp(dot(p - lm, seg8Dir) / (seg8Len * seg8Len + 0.0001), 0.0, 1.0);
    float dSeg8 = length(p - (lm + t8 * seg8Dir));
    
    // Prendre la distance minimale à tous les segments
    float distToEdge = min(min(min(dSeg1, dSeg2), min(dSeg3, dSeg4)), min(min(dSeg5, dSeg6), min(dSeg7, dSeg8)));
    float soft = 0.42;
    float smoke = smoothstep(0.0, soft, distToEdge);
    // Atténuer uniquement tout près des 8 sommets (évite les points brillants aux sommets)
    float dBl = length(uv - bl);
    float dBm = length(uv - bm);
    float dBr = length(uv - br);
    float dRm = length(uv - rm);
    float dTr = length(uv - tr);
    float dTm = length(uv - tm);
    float dTl = length(uv - tl);
    float dLm = length(uv - lm);
    float distToNearestCorner = min(min(min(dBl, dBm), min(dBr, dRm)), min(min(dTr, dTm), min(dTl, dLm)));
    float cornerDim = mix(0.2, 1.0, smoothstep(0.0, 0.2, distToNearestCorner));
    // Légère atténuation des diagonales uniquement (évite la croix, juste adoucit l'X)
    vec2 center = (bl + bm + br + rm + tr + tm + tl + lm) * 0.125;
    vec2 toP = uv - center;
    float lenP = length(toP) + 0.001;
    float alignBl = max(0.0, dot(toP / lenP, normalize(bl - center)));
    float alignBm = max(0.0, dot(toP / lenP, normalize(bm - center)));
    float alignBr = max(0.0, dot(toP / lenP, normalize(br - center)));
    float alignRm = max(0.0, dot(toP / lenP, normalize(rm - center)));
    float alignTr = max(0.0, dot(toP / lenP, normalize(tr - center)));
    float alignTm = max(0.0, dot(toP / lenP, normalize(tm - center)));
    float alignTl = max(0.0, dot(toP / lenP, normalize(tl - center)));
    float alignLm = max(0.0, dot(toP / lenP, normalize(lm - center)));
    float diagonalAlign = max(max(max(alignBl, alignBm), max(alignBr, alignRm)), max(max(alignTr, alignTm), max(alignTl, alignLm)));
    float diagonalDim = mix(0.92, 1.0, 1.0 - smoothstep(0.92, 1.0, diagonalAlign));
    // Opacité surtout pilotée par le bruit → répartition nuage, pas de forme géométrique
    float opacityVar = 0.4 + 0.35 * noise(uv * 5.0 + vec2(t * 0.12, t * 0.08));
    opacityVar += 0.25 * noise(uv * 11.0 + vec2(t * 0.18 + 2.0, t * 0.14 - 1.0));
    opacityVar += 0.2 * noise(uv * 19.0 + vec2(t * 0.07, t * 0.2 + 3.0));
    opacityVar = clamp(opacityVar, 0.0, 1.0);
    float whiteOpacity = 0.2;
    col = mix(col, vec3(1.0), smoke * opacityVar * cornerDim * diagonalDim * whiteOpacity);

    gl_FragColor = vec4(col, 0.85);
}
