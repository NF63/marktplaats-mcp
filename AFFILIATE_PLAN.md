# Marktplaats MCP Server - Affiliate Monetization Plan

## Overzicht

Dit document beschrijft het plan om de open-source Marktplaats MCP server te monetiseren via affiliate marketing. De strategie is gebaseerd op het genereren van traffic naar Marktplaats via AI-assistenten, waarbij affiliate links commissie opleveren.

---

## Fase 1: Awin Affiliate Account Setup

### 1.1 Registratie bij Awin
- [x] Ga naar [awin.com](https://www.awin.com) en registreer als **Publisher**
- [ ] Betaal de verificatiebetaling (~€1) voor identiteitscontrole
- [ ] Wacht op accountgoedkeuring

### 1.2 Profiel Configuratie
Bij het invullen van je profiel:

| Veld | Invullen |
|------|----------|
| **URL van promotieruimte** | `https://github.com/PonClick/marktplaats-mcp` |
| **Omschrijving** | "Open-source AI/MCP-server die gebruikers helpt om via natuurlijke taal te zoeken naar producten op Marktplaats. De tool genereert gerichte, kwalitatieve traffic via affiliate-links." |
| **Primaire salesregio** | Nederland |

### 1.3 Promotietypes Selecteren
Vink aan:
- [x] **Shopping directory** - Gestructureerde productlijsten
- [x] **Vergelijker** - Prijzen en specificaties vergelijken
- [ ] Content Creators (optioneel, als je blog/social media gebruikt)

### 1.4 Branches Selecteren
- [x] **Retail en shopping** (verplicht voor Marktplaats)

### 1.5 Marktplaats Programma Aanvragen
- [ ] Zoek in Awin naar "Marktplaats" adverteerder
- [ ] Vraag goedkeuring aan met uitleg over je AI-tool
- [ ] Wacht op goedkeuring (kan enkele dagen duren)

---

## Fase 2: Technische Implementatie

### 2.1 Affiliate Link Structuur
Awin affiliate links hebben dit formaat:
```
https://www.awin1.com/cread.php?awinmid=[ADVERTISER_ID]&awinaffid=[JOUW_PUBLISHER_ID]&ued=[ENCODED_MARKTPLAATS_URL]
```

### 2.2 Code Aanpassingen

#### Optie A: Direct in MCP Server (Simpel)
```python
# In server.py

AWIN_PUBLISHER_ID = "YOUR_PUBLISHER_ID"  # Via .env of config
AWIN_ADVERTISER_ID = "MARKTPLAATS_ID"    # Krijg je na goedkeuring

def _create_affiliate_link(original_url: str) -> str:
    """Wrap Marktplaats URL in affiliate tracking link."""
    from urllib.parse import quote
    encoded_url = quote(original_url, safe='')
    return f"https://www.awin1.com/cread.php?awinmid={AWIN_ADVERTISER_ID}&awinaffid={AWIN_PUBLISHER_ID}&ued={encoded_url}"
```

#### Optie B: Redirect Service (Aanbevolen)
Affiliate netwerken kunnen clicks afwijzen van "lege" referers. Beter:

1. Maak een simpele redirect service (bijv. op Vercel/Cloudflare Workers)
2. MCP server geeft link: `https://jouw-domein.nl/go?url=...`
3. Redirect service stuurt door naar Awin affiliate link
4. Netwerk ziet geldig referer domein

```python
REDIRECT_BASE = "https://mp-links.jouw-domein.nl/go"

def _create_affiliate_link(original_url: str) -> str:
    from urllib.parse import quote
    return f"{REDIRECT_BASE}?url={quote(original_url, safe='')}"
```

### 2.3 Configuratie via Environment Variables
```python
# Laat gebruikers hun eigen affiliate ID gebruiken (of fallback naar jouw ID)
import os

AWIN_PUBLISHER_ID = os.getenv("AWIN_PUBLISHER_ID", "DEFAULT_YOUR_ID")
```

In `.env.example`:
```
# Optioneel: Gebruik je eigen Awin Publisher ID
# AWIN_PUBLISHER_ID=123456
```

---

## Fase 3: GitHub Repository Updates

### 3.1 README.md Aanpassingen
Voeg toe:

```markdown
## Affiliate Disclosure

This tool uses affiliate links to support development. When you click on a
Marktplaats link through this tool and make a purchase, we may earn a small
commission at no extra cost to you.

You can use your own affiliate ID by setting the `AWIN_PUBLISHER_ID`
environment variable.
```

### 3.2 Disclaimer Toevoegen
Maak `DISCLAIMER.md`:
```markdown
# Disclaimer

This tool is provided for educational and personal use purposes.

- This is an unofficial tool and is not affiliated with Marktplaats.nl
- Users are responsible for complying with Marktplaats terms of service
- Links may contain affiliate tracking for which the developer receives compensation
- The developer is not responsible for any misuse of this tool
```

### 3.3 LICENSE Check
MIT licentie is prima, maar voeg toe aan README:
> "The affiliate integration is optional and can be disabled or replaced with your own affiliate ID."

---

## Fase 4: Monetization Strategie

### 4.1 Revenue Streams

| Stream | Beschrijving | Verwachte Opbrengst |
|--------|--------------|---------------------|
| **Affiliate clicks** | Commissie per click/sale via Awin | €0.05-0.50 per click |
| **GitHub Sponsors** | Donaties van gebruikers | Variabel |
| **Hosted versie** | Managed MCP-as-a-Service | €5-10/maand per user |
| **Consultancy** | Custom implementaties | Uurtarief |

### 4.2 Affiliate Potentieel Berekening
```
Aannames:
- 1000 actieve gebruikers
- 10 zoekopdrachten/dag per gebruiker
- 5% click-through rate op links
- €0.10 gemiddelde commissie per click

Maandelijkse revenue:
1000 users × 10 searches × 30 days × 5% CTR × €0.10 = €1,500/maand
```

### 4.3 Groei Strategie
1. **Launch**: Post op Reddit (r/homelab, r/netherlands), Tweakers forum
2. **AI Communities**: Discord servers voor Claude/ChatGPT users
3. **Developer communities**: Hacker News, Product Hunt
4. **Nederlandse tech blogs**: Pitchen voor artikel/review

---

## Fase 5: Juridische Overwegingen

### 5.1 Compliance Checklist
- [ ] Affiliate disclosure in README en output
- [ ] Geen Marktplaats trademark in repo naam
- [ ] Disclaimer over unofficial status
- [ ] Privacy policy indien je user data verzamelt
- [ ] KVK registratie voor uitbetaling Awin

### 5.2 Risico Mitigatie
| Risico | Mitigatie |
|--------|-----------|
| IP-blokkade door Marktplaats | Rate limiting, user-agent rotation |
| Cease & Desist | Positioneer als "affiliate partner die traffic levert" |
| Awin account ban | Transparante beschrijving van tool |
| API/Website changes | Monitoring + snelle updates |

---

## Fase 6: Implementatie Timeline

### Week 1: Awin Setup
- [x] Account aanmaken
- [x] Profiel compleet invullen
- [ ] Marktplaats programma aanvragen (wacht op accountgoedkeuring)
- [ ] Bankgegevens toevoegen

### Week 2: Code Updates
- [ ] Affiliate link wrapper functie
- [ ] Environment variable support
- [ ] Redirect service opzetten (optioneel)
- [ ] Testen met echte affiliate links

### Week 3: Documentation & Launch
- [ ] README updaten met affiliate disclosure
- [ ] DISCLAIMER.md toevoegen
- [ ] GitHub Sponsors activeren
- [ ] Eerste promotie posts

### Week 4: Monitoring & Optimalisatie
- [ ] Awin dashboard checken voor clicks/conversies
- [ ] User feedback verzamelen
- [ ] Performance optimalisaties
- [ ] Community building starten

---

## Technische Todo's voor Code

```python
# TODO's voor server.py:

# 1. Affiliate link configuratie
AFFILIATE_CONFIG = {
    "enabled": True,
    "provider": "awin",  # of "daisycon", "custom"
    "publisher_id": os.getenv("AWIN_PUBLISHER_ID"),
    "advertiser_id": os.getenv("AWIN_MARKTPLAATS_ID"),
}

# 2. Link transformation in _format_listing()
def _format_listing(listing: dict, ...) -> dict:
    # ... existing code ...

    original_link = f"https://link.marktplaats.nl/{listing.get('itemId')}"

    if AFFILIATE_CONFIG["enabled"] and AFFILIATE_CONFIG["publisher_id"]:
        result["link"] = _create_affiliate_link(original_link)
        result["original_link"] = original_link  # Voor transparantie
    else:
        result["link"] = original_link

    return result

# 3. Nieuwe tool: get_affiliate_stats (optioneel)
@mcp.tool()
def get_affiliate_info() -> dict:
    """Get information about affiliate configuration."""
    return {
        "affiliate_enabled": AFFILIATE_CONFIG["enabled"],
        "provider": AFFILIATE_CONFIG["provider"],
        "disclosure": "Links may contain affiliate tracking. See DISCLAIMER.md for details.",
    }
```

---

## Resources

- [Awin Publisher Signup](https://www.awin.com)
- [Awin Success Center](https://success.awin.com)
- [Marktplaats Zakelijk](https://www.marktplaats.nl/zakelijk)
- [MCP Protocol Docs](https://modelcontextprotocol.io)

---

## Notes

- Start met **Shopping directory** als primaire categorie bij Awin
- Cookie-tijd bij Awin is vaak 30 dagen (commissie ook bij latere aankopen)
- Test affiliate links altijd in incognito browser
- Monitor Awin dashboard wekelijks voor performance

---

*Plan gemaakt: januari 2026*
*Status: Awin aangevraagd - wacht op goedkeuring*

---

## Changelog

| Datum | Actie |
|-------|-------|
| 2026-01-27 | GitHub repo aangemaakt: https://github.com/PonClick/marktplaats-mcp |
| 2026-01-27 | Awin Publisher account aangevraagd |
