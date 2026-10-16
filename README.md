# 🛒 IntelliCart — Generative AI-Powered Smart Supermarket Trolley

> **Transforming retail trolleys from simple barcode scanners into AI culinary concierges.** 
> IntelliCart bridges mobile content inspiration with physical in-store shopping by converting viral YouTube cooking videos into real-time, aisle-mapped grocery checklists.

---

## 🌟 Overview

Traditional smart carts focus strictly on operational efficiency and self-checkout queue-busting. **IntelliCart** focuses on **revenue expansion and intent capture**. 

By leveraging a zero-install mobile web bridge and a high-throughput Generative AI pipeline, shoppers can scan a QR code on the trolley's tablet, beam any recipe video from their personal smartphone, and instantly receive a localized shopping list mapped directly to supermarket store aisles.

---

## ✨ Key Features

- 📱 **Zero-Install Mobile Web Bridge ("Beam"):** Scan-and-send mobile interface (`index.html`) hosted on Netlify—no app installation or customer login required.
- ⚡ **Sub-100ms Realtime Cloud Sync:** Powered by Supabase Realtime WebSockets to push URLs from mobile devices to the trolley tablet instantaneously.
- 🧠 **AI Recipe Extraction (Groq + Qwen 3.8-27b):** Extracts dish metadata and required raw ingredients from YouTube URLs, automatically standardizing quantities and mapping items to specific store aisles.
- 📴 **Deterministic Offline Failover:** Built-in offline fallback cache ensuring zero-latency presentation stability during retail Wi-Fi dropouts.
- 📷 **High-Speed Edge Scanner:** Front-facing tablet barcode scanner with sub-second feedback, real-time audio cues, and active cart session tracking.
- 💬 **In-Store Conversational AI Assistant:** Interactive product intelligence for real-time inquiries regarding ingredients, allergens, and Halal status.

---

## 🏗️ Architecture & Pipeline

---

## 🛠️ Tech Stack

- **Frontend / Tablet Client:** Flutter (Dart), Material 3 Design
- **Mobile Bridge:** HTML5, JS (ES6), Tailwind CSS, `@supabase/supabase-js`
- **Backend & Cloud Sync:** Supabase (PostgreSQL + Realtime WebSockets)
- **Generative AI Inference:** Groq Cloud API (`qwen/qwen3.8-27b` / `llama-3.1-8b`)
- **Hardware Integration:** `mobile_scanner`, `audioplayers` for low-latency feedback

---

## 🚀 Quick Start

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19+)
- A [Supabase](https://supabase.com) Project URL & Public `anon` Key
- A [Groq](https://groq.com) API Key

### Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/your-username/IntelliCart.git](https://github.com/your-username/IntelliCart.git)
   cd IntelliCart
