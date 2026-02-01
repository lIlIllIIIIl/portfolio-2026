# Menu About – Récapitulatif des modifications et fonctionnement

## 1. Modifications par fichier

### App.vue

- **État partagé (provide)**
  - `activeAboutSection` : `ref(0)` — index de la section visible (0 = Intro, 1 = Interests, etc.).
  - `aboutScrollDirection` : `ref('down')` — direction du scroll pour l’animation (`'down'` ou `'up'`).  
    Ces deux refs sont fournis via `provide()` pour être lus/modifiés par About (scroll) et Menu (affichage).

- **Template**  
  Inchangé : `<Menu />` + `<router-view />`.

---

### About.vue

- **Injection**
  - `inject('activeAboutSection')` et `inject('aboutScrollDirection')` pour synchroniser la page avec le menu.

- **Structure du template**
  - Un conteneur de scroll avec `ref="containerRef"` et classe `about-scroll-container`.
  - Quatre sections pleine hauteur avec des `id` : `intro`, `interests`, `experiences`, `contact` (alignés avec les libellés du menu).

- **Scroll snap**
  - `scroll-snap-type: y mandatory` sur le conteneur.
  - Chaque section a `scroll-snap-align: start` et `scroll-snap-stop: always`, et `height: 100vh`, pour un défilement section par section.

- **Intersection Observer**
  - Racine = le conteneur de scroll (`containerRef`), `threshold: 0.5`.
  - Dès qu’une section est à au moins 50 % visible :
    - on compare le nouvel index avec `activeAboutSection.value` ;
    - si différent : on met à jour `aboutScrollDirection` (nouvel index > ancien → `'down'`, sinon `'up'`), puis `activeAboutSection.value = index`.
  - L’observer est créé dans `onMounted` et détruit dans `onUnmounted`.

- **Style**
  - Scrollbar masquée.
  - `padding-left` et `padding-right: 12vw` pour laisser la place au menu à gauche et au compteur à droite.

---

### PageMenu.vue

- **Injection**
  - `activeAboutSection` et `aboutScrollDirection` pour afficher la section courante et choisir le sens de l’animation.

- **Logique (computed)**
  - `menuItems` : selon la route (about → Intro, Interests, Experiences, Contact).
  - `isAbout` : `route.name === 'about'`.
  - `activeIndex` : dérivé de `activeAboutSection` (clampé selon la longueur de `menuItems`).
  - `activeItem` : libellé de la section courante.
  - `counterValue` : `activeIndex + 1` (1–4).
  - `counterPrefix` / `counterSuffix` : chaînes fixes pour le compteur, ex. `"[ 0"` et `"     ]"`.
  - `menuTransitionName` : `'menu-slide-reverse'` si `aboutScrollDirection === 'up'`, sinon `'menu-slide'`.

- **Template (page About)**
  - **Gauche** : un bloc fixe (`.about-menu--left`) avec un masque (hauteur fixe, `overflow: hidden`) et une `<Transition>` sur le libellé (`:key="activeItem"`).
  - **Droite** : un bloc fixe (`.about-menu--right`) avec le compteur : préfixe statique + masque avec transition sur le chiffre seul (`:key="counterValue"`) + suffixe statique.
  - Les deux transitions utilisent `:name="menuTransitionName"` et `mode="out-in"`.

- **Template (autres pages)**
  - Un seul bloc à gauche qui affiche la liste des items (ex. Home).

- **Styles**
  - Menu fixe (`position: fixed`), colonnes gauche/droite en `12vw`.
  - Masques avec `height: 1.2em` (label) et `1ch` (chiffre du compteur), `overflow: hidden`.
  - `white-space: pre` sur le compteur pour garder les espaces.
  - Deux jeux de classes de transition :
    - **menu-slide** (scroll vers le bas) : sortie vers le haut (`translateY(-100%)`), entrée depuis le bas (`translateY(100%)` → 0).
    - **menu-slide-reverse** (scroll vers le haut) : sortie vers le bas (`translateY(100%)`), entrée depuis le haut (`translateY(-100%)` → 0).
  - Opacité 0 en sortie/entrée pour un fondu.

---

## 2. Fonctionnement global du menu

### Flux de données

1. **App** fournit deux refs réactives : `activeAboutSection` et `aboutScrollDirection`.
2. **About** :
   - fait défiler un conteneur en scroll-snap (une section = un écran) ;
   - observe les sections avec l’Intersection Observer ;
   - quand une section devient “active” (seuils dépassés), met à jour d’abord la direction, puis l’index de section.
3. **Menu** :
   - injecte ces deux refs ;
   - affiche le libellé correspondant à `activeAboutSection` (gauche) et le chiffre 1–4 (droite) ;
   - choisit la transition (slide ou slide-reverse) selon `aboutScrollDirection`.

Aucun événement personnalisé : tout passe par l’état partagé (provide/inject).

### Comportement visuel

- **Scroll vers le bas** (section suivante) :  
  L’ancien texte part vers le haut en disparaissant, le nouveau entre par le bas en apparaissant (label et chiffre).

- **Scroll vers le haut** (section précédente) :  
  L’ancien texte part vers le bas, le nouveau entre par le haut (même principe, transition inverse).

- Seul le **chiffre** du compteur est animé ; le préfixe `"[ 0"` et le suffixe `"     ]"` restent fixes, avec les espaces préservés grâce à `white-space: pre`.

### Rôle des masques

- Un masque = une zone à hauteur fixe avec `overflow: hidden`.
- On n’y voit qu’une “ligne” de contenu. Quand le contenu change (`:key` différent), la transition le translate (haut/bas) et fait le fondu, donnant l’effet de remplacement dans la même fenêtre.

En résumé : la page About pilote **quelle** section est active et **dans quel sens** on scroll ; le Menu réagit à cet état et affiche libellé + compteur avec la bonne animation.
