# ADR-0001: State Management

* **Date:** 2025-08-26
* **Status:** Proposed
* **Context:** Need predictable state, testability, DI.
* **Options:** Bloc, Provider, Riverpod, MobX
* **Decision:** Riverpod for compile‑time safety and simple DI.
* **Consequences:** Add `riverpod_generator`; training for team; avoid global singletons.
