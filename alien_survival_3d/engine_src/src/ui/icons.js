// Inline SVG icons for the HUD and touch controls (original artwork).
const s = (body, vb = '0 0 48 48') => `<svg viewBox="${vb}" xmlns="http://www.w3.org/2000/svg" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round">${body}</svg>`;

export const ICONS = {
  fire: s('<circle cx="24" cy="24" r="13"/><circle cx="24" cy="24" r="3" fill="currentColor"/><path d="M24 4v8M24 36v8M4 24h8M36 24h8"/>'),
  aim: s('<circle cx="24" cy="24" r="15"/><path d="M24 9v7M24 32v7M9 24h7M32 24h7"/><circle cx="24" cy="24" r="2" fill="currentColor"/>'),
  reload: s('<path d="M38 20a15 15 0 1 0 1 9"/><path d="M39 9v11H28"/>'),
  jump: s('<circle cx="27" cy="9" r="4" fill="currentColor"/><path d="M18 22l7-6 6 5 6-3M25 16l-4 12 7 5-2 10M21 28l-8 4"/><path d="M8 44h10" />'),
  crouch: s('<circle cx="22" cy="11" r="4" fill="currentColor"/><path d="M21 17l-3 11h10l3 12M18 28l-6 8 2 6M21 18l9 4 6-3"/>'),
  grenade: s('<ellipse cx="22" cy="29" rx="11" ry="13"/><path d="M18 16h8v-4h-8zM26 13l8-4M30 14a4 4 0 1 0 6 3"/><path d="M14 27h16M14 33h16"/>'),
  switch: s('<path d="M8 17h28l-6-6M40 31H12l6 6"/>'),
  sprint: s('<circle cx="30" cy="8" r="4" fill="currentColor"/><path d="M14 20l8-6 8 3 4 7 6 1M30 17l-6 11 7 6-3 10M24 28l-9 3-5 7"/>'),
  roll: s('<circle cx="24" cy="24" r="12"/><path d="M24 12a12 12 0 0 1 12 12M36 24l4-5M36 24l-5-3"/><path d="M6 42h36"/>'),
  interact: s('<path d="M17 25V12a3 3 0 0 1 6 0v11M23 22v-3a3 3 0 0 1 6 0v4M29 23a3 3 0 0 1 6 0v8c0 7-5 12-11 12-5 0-8-3-11-8l-4-7a3 3 0 0 1 5-3l4 5"/>'),
  pause: s('<path d="M17 12v24M31 12v24" stroke-width="5"/>'),
  heart: s('<path d="M24 40S8 30 8 18a8 8 0 0 1 16-3 8 8 0 0 1 16 3c0 12-16 22-16 22z" fill="currentColor"/>'),
  shield: s('<path d="M24 5l15 6v11c0 10-7 18-15 21C16 40 9 32 9 22V11z" fill="currentColor"/>'),
  coin: s('<circle cx="24" cy="24" r="16" fill="currentColor"/><path d="M28 17h-6a4 4 0 0 0 0 8h4a4 4 0 0 1 0 8h-7M24 13v4M24 33v3" stroke="#000"/>'),
  gem: s('<path d="M14 8h20l8 11-18 22L6 19z" fill="currentColor"/><path d="M6 19h36M18 8l-4 11 10 22 10-22-4-11" stroke="#000" stroke-width="2"/>'),
  skull: s('<path d="M12 30v-8a12 12 0 0 1 24 0v8l-4 3v6H16v-6z"/><circle cx="19" cy="24" r="3" fill="currentColor"/><circle cx="29" cy="24" r="3" fill="currentColor"/>'),
  clock: s('<circle cx="24" cy="24" r="16"/><path d="M24 14v10l7 5"/>'),
  wave: s('<path d="M6 30c6-10 12-10 18 0s12 10 18 0M6 20c6-10 12-10 18 0s12 10 18 0"/>'),
  bullets: s('<path d="M12 40V18l4-8 4 8v22zM22 40V18l4-8 4 8v22zM32 40V18l4-8 4 8v22z" fill="currentColor" stroke-width="1.5"/>'),
};
