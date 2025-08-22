for the builder # Builder.io × React Cards Integration Guide

Builder.io is a **visual CMS / page builder** that lets non-developers drag-and-drop content and then delivers it through an API or SDK into your frontend framework (like React).  

When you say *“integrate into React cards”*, here’s what that typically means:  

---

## 1. Install Builder.io React SDK
```bash
npm install @builder.io/react
```

---

## 2. Register Your React Components (cards) with Builder
You make your card component available in Builder so that content editors can place it on a page.

```tsx
// Card.tsx
import React from "react";
import { Builder } from "@builder.io/react";

export const Card = ({ title, description, image }: any) => (
  <div className="rounded-2xl shadow-md p-4">
    <img src={image} alt={title} className="rounded-xl mb-2" />
    <h3 className="text-xl font-bold mb-1">{title}</h3>
    <p>{description}</p>
  </div>
);

// Register the component in Builder
Builder.registerComponent(Card, {
  name: "Card",
  inputs: [
    { name: "title", type: "string" },
    { name: "description", type: "longText" },
    { name: "image", type: "file", allowedFileTypes: ["jpeg", "png", "webp"] },
  ],
});
```

Once registered, **non-devs in Builder.io’s UI can drag this “Card” onto pages** and fill in the fields.

---

## 3. Render Builder Content in Your React App
You then add a `BuilderComponent` into your page template:

```tsx
import { BuilderComponent, builder } from "@builder.io/react";

// set your API key
builder.init("YOUR_PUBLIC_API_KEY");

export default function HomePage() {
  return (
    <div>
      <BuilderComponent model="page" contentLoaded={(content) => console.log(content)} />
    </div>
  );
}
```

---

## 4. How the flow works
- **In Builder UI**: A marketer/designer drags in your “Card” block, fills in the inputs (title, description, image).  
- **Builder saves JSON**: The content model (page with card data) is stored in Builder.io.  
- **Your app**: At runtime, `BuilderComponent` fetches JSON from Builder.io and renders your registered React `Card` component with the inputs.  

So your “cards” are just **normal React components**; Builder supplies them with content defined in its CMS interface.

---

✅ **End result:** You can keep card design and interactivity in React code (developer-owned), while letting non-developers create/edit instances of those cards (content + data) directly in Builder’s UI.

---

## Full Demo: Builder.io + React Cards

Below is a complete demo with a `Card`, `CardGrid`, registration in Builder.io, and a fallback.

```tsx
import React, { useEffect, useState } from "react";
import { Builder, builder, BuilderComponent } from "@builder.io/react";

// 1) Init Builder.io (replace with your Public API Key)
builder.init("YOUR_PUBLIC_API_KEY");

// 2) Card component (your design system)
export type CardProps = {
  title?: string;
  description?: string;
  image?: string;
  href?: string;
  badge?: string;
};

export const Card: React.FC<CardProps> = ({ title, description, image, href, badge }) => (
  <a
    href={href || "#"}
    className="group block rounded-2xl border border-zinc-200 dark:border-zinc-800 bg-white/60 dark:bg-zinc-900/60 backdrop-blur p-4 shadow-sm hover:shadow-md transition-shadow duration-200"
  >
    {image && (
      <div className="relative mb-3 overflow-hidden rounded-xl">
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img src={image} alt={title || "Card image"} className="w-full h-40 object-cover transform group-hover:scale-[1.02] transition-transform" />
        {badge && (
          <span className="absolute top-2 left-2 text-xs font-semibold px-2 py-1 rounded-full bg-black/80 text-white">
            {badge}
          </span>
        )}
      </div>
    )}
    <h3 className="text-lg font-semibold tracking-tight mb-1">{title || "Card title"}</h3>
    <p className="text-sm text-zinc-600 dark:text-zinc-400">{description || "Card description goes here."}</p>
  </a>
);

// 3) Optional grid wrapper to lay out multiple cards from Builder content
export const CardGrid: React.FC<{ columns?: number; children?: React.ReactNode }> = ({ columns = 3, children }) => (
  <div
    className={`grid gap-4 md:gap-6 xl:gap-8`} style={{ gridTemplateColumns: `repeat(${Math.max(1, Math.min(6, columns))}, minmax(0, 1fr))` }}
  >
    {children}
  </div>
);

// 4) Register components with Builder so editors can drag them in the visual editor
Builder.registerComponent(Card, {
  name: "Card",
  inputs: [
    { name: "title", type: "string" },
    { name: "description", type: "longText" },
    { name: "image", type: "file", allowedFileTypes: ["jpeg", "png", "webp", "jpg"] },
    { name: "href", type: "url" },
    { name: "badge", type: "string" },
  ],
});

Builder.registerComponent(CardGrid, {
  name: "CardGrid",
  inputs: [
    { name: "columns", type: "number", defaultValue: 3 },
    { name: "children", type: "uiBlocks", hideFromUI: false },
  ],
});

// 5) Demo page that renders a Builder "page" model. If no content is found, it falls back to local sample cards.
const FallbackCards: React.FC = () => (
  <div className="max-w-6xl mx-auto px-4 py-10">
    <h2 className="text-2xl font-bold mb-6">Sample Cards (local fallback)</h2>
    <CardGrid columns={3}>
      <Card
        title="Getting started with HEI"
        description="A quick primer on how shared-equity works and what to expect."
        image="https://images.unsplash.com/photo-1520607162513-77705c0f0d4a?q=80&w=1200&auto=format&fit=crop"
        href="#"
        badge="Guide"
      />
      <Card
        title="Security & Compliance"
        description="How we protect your docs with encryption and access controls."
        image="https://images.unsplash.com/photo-1555949963-aa79dcee981d?q=80&w=1200&auto=format&fit=crop"
        href="#"
        badge="Docs"
      />
      <Card
        title="Your Property Dashboard"
        description="Track valuation updates, lien positions, and key milestones."
        image="https://images.unsplash.com/photo-1515516969-d4008cc6241a?q=80&w=1200&auto=format&fit=crop"
        href="#"
        badge="Product"
      />
    </CardGrid>
  </div>
);

const useBuilderPage = (model = "page", urlPath = "/") => {
  const [content, setContent] = useState<any>(null);

  useEffect(() => {
    let mounted = true;
    builder
      .get(model, { url: urlPath })
      .toPromise()
      .then((res) => {
        if (mounted) setContent(res || null);
      })
      .catch(() => setContent(null));
    return () => {
      mounted = false;
    };
  }, [model, urlPath]);

  return content;
};

export default function BuilderCardsDemo() {
  const content = useBuilderPage("page", "/"); // Use URL targeting in Builder for this route

  return (
    <main className="min-h-screen bg-gradient-to-b from-zinc-50 to-white dark:from-zinc-950 dark:to-black">
      <div className="max-w-6xl mx-auto px-4 py-8">
        <h1 className="text-3xl font-bold tracking-tight mb-2">Builder.io × React Cards</h1>
        <p className="text-zinc-600 dark:text-zinc-400 mb-8">
          Drag-and-drop cards in Builder; this page renders them with your React components.
        </p>
      </div>

      {content ? (
        <BuilderComponent model="page" content={content} />
      ) : (
        <FallbackCards />
      )}

      <footer className="max-w-6xl mx-auto px-4 py-10 text-xs text-zinc-500">
        Replace <code>YOUR_PUBLIC_API_KEY</code> with your Builder key. In Builder, create a <strong>Page</strong> model and target this route ("/"). Then drag in <strong>CardGrid</strong> and <strong>Card</strong> components.
      </footer>
    </main>
  );
}
```

---

## 5. Usage Notes

- Replace `YOUR_PUBLIC_API_KEY` with your Builder.io public key.  
- In Builder.io, create a **Page** model targeting `/`.  
- Drag in a `CardGrid`, then add `Card` components inside.  
- Publish the page, and your React app will render them.  

---
