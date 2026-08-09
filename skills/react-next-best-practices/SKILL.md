---
name: react-next-best-practices
description: React and Next.js projects e best practices follow kore clean, scalable, and performant code likhar jonno. Use for any React or Next.js related task.
---

# React + Next.js Best Practices

## Rules
- Use functional components + hooks only
- Prefer Server Components in Next.js (App Router)
- Use TypeScript when possible
- Proper folder structure (app/, components/, lib/, hooks/, types/)
- Avoid prop drilling — use context or state management wisely
- Use Tailwind for styling
- Optimize images with next/image
- Handle loading and error states properly
- Keep components small and focused

## Next.js Specific
- Use App Router (not Pages Router)
- Prefer Server Actions over API routes when possible
- Use Suspense and streaming
- Proper metadata and SEO setup
- Use next/font for fonts

## Code Style
- Clear naming conventions
- Extract reusable components
- Custom hooks for logic
- No `any` type in TypeScript
- Consistent file naming (kebab-case or PascalCase for components)