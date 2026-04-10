# Cyanide Pulse Design System

### 1. Overview & Creative North Star
**Creative North Star: The Neon Terminal**
Cyanide Pulse is a high-fidelity, futuristic interface system designed for deep immersion. It rejects the "flat" web aesthetic in favor of a layered, tactical environment that feels like a physical terminal. By utilizing high-contrast typography, luminous accents, and heavy backdrop blurs, the system creates a sense of "digital depth" where data isn't just displayed—it’s projected.

### 2. Colors
The palette is built on a "Deep Space" foundation (`#0b0e14`) with vibrant, bioluminescent highlights.
- **The "No-Line" Rule:** Sectioning is achieved through the transition from `surface_container_low` to `surface_container_high`. No 1px solid borders are permitted for layout boundaries. Instead, use 5-10% opacity white/primary outlines only for interactive states.
- **Surface Hierarchy:** The background uses a subtle radial glow and a 40px grid texture. Components sit atop this using `surface_container/40` with a 20px backdrop blur to imply transparency.
- **Signature Textures:** Use `primary` to `primary_container` gradients for active progress bars and hero status indicators to simulate glowing gas-discharge displays.

### 3. Typography
The system employs a dual-font strategy to balance technical precision with modern readability.
- **Display & Headlines (Space Grotesk):** Used for mission-critical data and large headers. Its geometric quirks reinforce the "high-tech" feel.
- **Body & Labels (Plus Jakarta Sans):** A humanist sans-serif that ensures legibility during long sessions.
- **Ground Truth Scale:** 
  - **Hero Stats:** `4.5rem` (Space Grotesk, Bold)
  - **Large Headings:** `1.5rem`
  - **Standard Labels:** `11px` / `0.75rem` (all-caps with `0.2em` tracking)
  - **Micro-Data:** `8px` to `10px` for tactical readouts.

### 4. Elevation & Depth
Elevation is expressed through light emission rather than physical shadow.
- **The Layering Principle:** Nested containers move from `surface-container-low` (base) to `surface-container-highest` (focused element).
- **Ambient Glows:** Use `shadow-xl` with primary-colored diffusion (`rgba(88, 231, 251, 0.2)`) to create a "bloom" effect around active modules.
- **Glassmorphism:** Navigation and overlays must use `backdrop-blur-xl` and semi-transparent fills (e.g., `bg-cyan-950/60`) to maintain context of the underlying grid.

### 5. Components
- **The Tactical Button:** High roundedness (`2rem` / `pill`). Primary buttons use a heavy drop shadow of their own color.
- **Data Cards:** Containers must have a `border-b-4` of the status color (Primary for active, Error for alert) to ground them in the UI.
- **Keyboard Keys:** Aspect-ratio locked `3/4` blocks with subtle `surface-container-high` fills and primary-toned outlines.
- **Health/Status Bars:** Encapsulated in `error/10` tracks with a glowing `primary` fill, utilizing inner glows for a liquid-crystal effect.

### 6. Do's and Don'ts
- **Do:** Use all-caps with generous letter spacing for labels to create a professional, military-grade feel.
- **Do:** Use "Stunned" or "Solved" overlays with `backdrop-blur-3xl` to interrupt the user flow during critical events.
- **Don't:** Use solid, opaque backgrounds for any component—everything should feel like it is projected onto the glass.
- **Don't:** Mix roundedness types. All interactive elements must adhere to the `rounded-xl` (1rem) or `rounded-full` standard.
- **Do:** Use icons as filled variants (`FILL: 1`) only when they represent a critical "On" state or active sensor.