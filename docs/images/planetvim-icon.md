# PlanetVim icon

The PlanetVim icon reuses Vim's original lettering over a blue circular planet with a foreground orbit ring. The circle is slightly smaller than the V's overall height.

- [Editable SVG master](planetvim-icon.svg).
- [Transparent 1024 × 1024 PNG](planetvim-icon.png).

The README displays the icon at 128 pixels.

## Exact lettering and source

The final SVG directly reuses the paths from Vim's `runtime/vimlogo.eps`, from source snapshot `124371c5a149a8c0c75c04b6c90ac11e71a0aa97`. Inkscape converted that EPS to SVG. The nine diamond paths were omitted, while all 31 letter paths were retained with their original coordinates, transforms, fills, strokes, spacing and relative sizes. A shared uniform scale and translation positions the lettering over the new circle. The ring's front arc is the topmost layer, crossing in front of the circle and all lettering, including `im`.

The original letter artwork retains the [Vim license](VIM-ICON-LICENSE.txt), copied unmodified from that source snapshot. The circle and orbit ring are PlanetVim additions. The icon does not rely on fonts or external assets.

Render the transparent PNG from the SVG master with:

```sh
rsvg-convert docs/images/planetvim-icon.svg --output docs/images/planetvim-icon.png
```

The built-in image generation tool produced the exploratory designs below. For the final icon, direct vector reuse replaces generated lettering to meet the exact-lettering requirement.

## Circular color exploration prompts

These built-in image-generation drafts guided the composition; the delivered SVG and PNG use the original vector lettering instead.

### Green draft

```text
Use case: precise-object-edit, logo-brand.
The reference image is the ORIGINAL Vim logo rendered from Vim's upstream vimlogo.eps. Treat it as the edit target, not a loose style reference.
User requirement: keep the text 'Vim' EXACTLY as in this original logo, replace the background diamond with a circle, and add a planetary ring in front. This is the GREEN variant.
Preserve the original Vim lettering as an unchanged foreground cutout: the exact large angular slab-serif V, the exact small angular italic i and m, the original relative size, alignment, spacing, charcoal outlines, silver-gray faces, white bevels, gray edge shading, and straight clipped corners. Do NOT redraw it with another font, do NOT round off the angular letterforms, do NOT replace it with a generic white serif V, and do NOT re-typeset the word. Uniformly scale the whole original text group only as necessary to fit the icon.
Change only the green diamond behind the lettering into a true circular planet, using classic saturated Vim green, with a simple dark outline. Completely remove every diamond corner. Add one pale mint-green elliptical Saturn ring around the circle, tilted gently upward to the right. The near arc must visibly sweep IN FRONT of the lower part of the circular planet, with small far portions passing behind the circle at the sides. Keep the lettering readable and unchanged; let the front arc pass just below most of the lettering, across the low foot of the V at most. The ring should be clearly visible but secondary to the original Vim wordmark.
Square application icon with the complete circle, text and ring centered and uncropped, comfortable transparent padding on all sides, genuinely transparent RGBA background. No white canvas, no black canvas, no checkerboard texture. No other text, labels, stars, gradients or decoration. Preserve the original logo lettering's bevels, but make the new circle and ring clean flat colors with smooth edges. Return exactly one finished green icon.
```

### Blue draft

```text
Use case: precise-object-edit.
Create the BLUE color variant of this exact PlanetVim icon. Change COLORS ONLY. Replace the green circular planet with saturated medium blue (approximately #2477C8), and replace the pale mint ring with pale sky blue (approximately #A8DFFF). Keep the complete geometry, exact original Vim lettering shapes, silver-gray letter faces, white bevels, gray letter edges, charcoal outlines, letter positions and spacing, front-ring overlap, circle size, transparent background, canvas size and margins UNCHANGED. Do not redraw or restyle any text or shape. The background remains a true circle, and the ring remains in front exactly as shown. No new elements, no extra text, no labels, no wordmark, no background. Return one blue icon with actual RGBA transparency.
```

## Vim-style revision prompt

The edit target was the earlier PlanetVim icon. The visual reference was the classic Vim/GVim icon installed at `/usr/share/icons/hicolor/48x48/apps/gvim.png`; Vim's original icon is not bundled here.

```text
Use case: logo-brand, precise-object-edit.
Image 1 is the current PlanetVim icon to redesign. Image 2 is the installed classic Vim/GVim application icon, supplied strictly as the visual style reference.
User request: Make the PlanetVim icon more similar to Vim's classic icon.
Redesign image 1 to strongly echo image 2: replace the round green planet with Vim's familiar vivid green diamond, a square rotated 45 degrees. Use the classic oversized slanted white/light-gray serif capital V with a crisp thin charcoal outline, and the smaller italic lowercase 'im' tucked beside its lower-right stroke, reading exactly 'Vim', with the recognizable proportions and arrangement of the reference. The large V should extend slightly beyond the diamond as in the reference. Keep the classic bright Vim green, light lettering, and dark contours; reproduce the clean logo geometry at high resolution rather than pixelating the low-resolution reference.
Retain PlanetVim's distinguishing feature: one clean, restrained pale mint planetary orbit ring wrapping diagonally around the green diamond. The orbit should integrate with the diamond, passing behind the upper part and across the lower green area, with ALL lettering clearly in front of the ring and fully readable. Make the orbit substantially less dominant than the V and green diamond. The result should immediately look like a Vim-family app with a planetary orbit.
Create a polished square application icon on a genuinely transparent RGBA background, with balanced transparent margins around the whole uncropped silhouette. Clean smooth antialiased edges, flat colors, no mottling, no grain, no stray pixels, no gradients, no 3D lighting, no glow, no extra shadows. Exactly the letters 'Vim'; no 'PlanetVim' wordmark, captions, labels, stars, other symbols, mockups, or multiple variants. Return only one finished isolated icon.
```

## Initial prompt

```text
Use case: logo-brand.
Asset type: PlanetVim application icon for a Linux GVim-based IDE and its GitHub project.
Primary request: Create one distinctive, polished PlanetVim icon combining a green planet with a bold white capital V, a subtle nod to Vim. A clean circular emerald-green planet, one broad pale mint orbital ring tilted diagonally and wrapping behind and in front of the planet, and a large crisp white V at the center. Keep the V fully readable, with the front of the orbit passing below it. The green planet and orbit should form one balanced, memorable silhouette.
Style: restrained flat vector-style graphic, geometric shapes, clean confident edges, minimal color count, strong contrast. No photorealism, no 3D bevels, no gradients, no glow, no drop shadows, no texture. Readable as an app icon at 32 and 48 pixels.
Composition: square 1024 by 1024 canvas; one centered icon occupying about 85 percent of the width with comfortable transparent margins and no cropping. Genuinely transparent RGBA background, not a checkerboard illustration or white rectangle. The green symbol should work on both light and dark desktops.
Text: exactly one uppercase letter "V" as part of the icon. No other letters or words, no wordmark, no caption, no watermark, no stars, no small decorative details. Return only the finished isolated icon, not a presentation board, mockup, or variants.
```

## Refinement prompt

```text
Use case: precise-object-edit, logo-brand.
Edit the attached PlanetVim application icon. Keep the exact design concept and arrangement: the circular green planet, bold white serif capital V, and tilted mint orbital ring. Change only the rendering quality: make all shapes perfectly clean, smooth and flat, with solid uniform emerald-green fill for the planet, solid pale mint fill for the ring, and pure white for the V. Remove all mottling, gradients, dark smudges, grain, stray pixels, and ragged cutout edges. Use clean antialiased contours like a professionally drawn geometric vector logo. Keep the V large and readable at small application-icon sizes. Preserve a truly transparent alpha background and generous transparent padding around the complete uncropped silhouette. No background color, no checkerboard, no shadows, no textures, no extra text or new elements. One finished square app icon only.
```
