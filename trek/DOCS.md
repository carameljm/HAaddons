# TREK - Travel Planner

> Self-hosted collaborative travel and trip planning platform built for Home Assistant.

## Overzicht / Overview
**TREK** is een modern platform om reizen, routes, bezienswaardigheden, paklijsten en uitgaven te beheren en live te delen met reisgenoten.

### Belangrijkste Functies
* 🗺️ **Interactieve Kaarten:** Leaflet, MapLibre & Mapbox ondersteuning met POI-markeringen en routeoptimalisatie.
* 👥 **Real-time Samenwerking:** Meerdere reisgenoten kunnen tegelijkertijd reisschema's bewerken.
* 💰 **Budget & Uitgaven:** Registreer wie wat betaald heeft en bereken direct vereffeningen ("Wie is wie wat verschuldigd").
* 📦 **Paklijsten & Documenten:** Veilig tickets, hotelbevestigingen en paspoortkopieën opslaan.
* 🤖 **Model Context Protocol (MCP):** Koppel lokale AI of LLMs om reisroutes automatisch op te stellen.
* 🔒 **End-to-End Veiligheid:** SQLite database versleuteld opgeslagen in Home Assistant `/data` of `/share/trek`.

---

## Configuratie Opties (Home Assistant UI)
In de Home Assistant Add-on instellingenpagina kun je de volgende opties instellen:

| Optie | Beschrijving | Standaard |
|---|---|---|
| `admin_email` | E-mailadres voor het eerste beheerderaccount | `email@email.com` |
| `admin_password` | Wachtwoord voor het eerste beheerderaccount | (Willekeurig gegenereerd in logs) |
| `encryption_key` | 32-byte hex sleutel (`openssl rand -hex 32`) | (Automatisch aangemaakt en bewaard) |
| `tz` | Tijdzone (bijv. Europe/Brussels) | `Europe/Brussels` |
| `log_level` | Logboek detailniveau (debug, info, warn, error) | `info` |

---

## Dashboard Integratie (Lovelace Kaart)
Je kunt TREK direct insluiten in elk Home Assistant Dashboard met een Iframe-kaart:

```yaml
type: iframe
url: /api/hassio_ingress/trek/
title: TREK Reisplanner
aspect_ratio: 75%
```
