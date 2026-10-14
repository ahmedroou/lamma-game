# Exact image generation prompts

Mode: built-in `image_gen.imagegen` for both calls.

## Original artwork (opaque background)

Use case: logo-brand. Asset type: production launcher icon for Lamma, an Arabic social trivia card game. Generate one polished square 1024x1024 app icon, not a mockup or presentation sheet. Full-bleed uniform very dark charcoal background #101215 extending to all four square edges, no outer border, no baked rounded icon container. Center a bold compact fan of exactly THREE thick softly rounded playing cards: lavender #B5A0FF behind on the left, sky blue #8FD6F5 behind on the right, bright lime #D5F85A upright in front. Give the cards a beautifully restrained tactile soft 3D style with crisp clean silhouettes, subtle bevels and gentle close shadows, matte material, no tiny ornament. The front lime card carries one large dark charcoal ARABIC question mark «؟», centered and visually bold. Slightly dynamic playful fan angles, balanced and premium. Entire card emblem stays inside the central 60 percent of the canvas in both axes so adaptive circular/squircle launcher masking never crops it. Strong recognizability at 32px. The emblem is the only object. No letters, no app-name wordmark, no Latin question mark, no Flutter logo, no watermark, no frame, no scenery, no extra cards, no loose confetti. Opaque background.

## Adaptive foreground (transparent background)

Use case: background-extraction. Edit target: the supplied generated Lamma launcher artwork. Remove ONLY the nearly black charcoal background outside the three-card emblem and replace it with true alpha transparency. Preserve the three cards, Arabic question mark, exact lime/lavender/cyan colors, material, silhouette, proportions, relative positions and all icon detail unchanged. Keep the square canvas, emblem centered, and existing outer margins. Keep subtle contact shadows BETWEEN the cards. Remove any broad dark ambient shadow beyond the outer card silhouette with the background. Do not redraw, add, crop, reframe, or change the mark; no extra content.

