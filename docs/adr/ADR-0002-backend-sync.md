# ADR-0002: Backend & Sync

* **Date:** 2025-08-26
* **Status:** Proposed
* **Context:** Multi‑account, offline‑first, and existing Firebase artifacts in current repo.
* **Options:** Firebase (Auth + Firestore), Supabase, local‑only + periodic export
* **Decision:** Use Firebase Auth + Firestore with Cloud Functions for token creation/refresh; Isar for local cache and queues.
* **Consequences:** Vendor lock‑in; fast iteration; strong SDK support. Add privacy policy and data export.
