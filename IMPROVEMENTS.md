# Marktplaats MCP Server - Verbeteringen

*Gebaseerd op uitgebreide testsessie (2026-01-27)*

---

## 🚨 Prioriteit 1: Context Window Optimalisatie

### Probleem
Responses zijn te groot en slokken veel van Claude's context window op.
- Huidige response: ~14.800 chars voor 20 listings (~3.700 tokens)
- `description` veld alleen al: **35% van response**

### Oplossing: Compact Mode

```python
search_listings(..., compact=True)
```

**Compact response format:**
```json
{
  "total": 21,
  "listings": [
    {
      "id": "m2358052495",
      "title": "Dell 5290 2-in-1",
      "price": 150,
      "city": "Benthuizen",
      "km": 56,
      "seller_type": "private",
      "specs": {"cpu": "i5-8e", "ram": "8GB"}
    }
  ],
  "next_offset": 20
}
```

**Weglaten in compact mode:**
- `description` (grootste besparing!)
- `image` URL
- `attributes` array
- `seller.id`, `seller.is_verified`
- `price_cents` (redundant met `price`)
- `condition` (of verkort naar 1 char: N/G/R)
- `date` verkorten naar "2d" ipv "Eergisteren"
- `link` (kan client reconstrueren: `https://link.marktplaats.nl/{id}`)

**Verwachte besparing: ~75%**

### Bonus: Ultra-compact Mode

```python
search_listings(..., format="ultra")
```

Array-based voor maximale compressie:
```json
{
  "n": 21,
  "l": [
    ["m2358052495", "Dell 5290 2-in-1", 150, "Benthuizen", 56, "P", "i5-8e|8GB|256GB"]
  ]
}
```

**Verwachte besparing: ~90%**

---

## 🔧 Prioriteit 2: Specs Extractie Verbeteren

### Probleem
Sommige listings hebben specs in description maar worden niet geëxtraheerd.

**Voorbeeld:**
```
Dell 5290 2-in-1 Benthuizen: geen specs
→ description bevat "i5 8e generatie", "touchscreen", "detachable"
```

### Oplossing
Uitbreiden met extra patronen:

```python
EXTRA_SPECS_PATTERNS = {
    "touchscreen": r"touch\s?screen|aanraakscherm",
    "detachable": r"detachable|afneembaar|los.*toetsenbord",
    "2in1": r"2-in-1|2in1|convertible",
    "keyboard_included": r"incl.*toetsenbord|met.*keyboard|keyboard.*included",
    "charger_included": r"incl.*oplader|met.*lader|charger.*included",
    "generation": r"(\d+)e?\s*gen(?:eratie)?",
}
```

---

## 🏢 Prioriteit 3: Seller Type Detectie Verbeteren

### Probleem
Sommige duidelijk zakelijke verkopers worden als `private` gedetecteerd:
- "Used Products Dordrecht" → private (FOUT)
- "Buy & Sell Roosendaal" → private (FOUT)
- "Mediahoek.nl" → business (OK)

### Oplossing
Pattern matching toevoegen:

```python
BUSINESS_NAME_PATTERNS = [
    r"used products",
    r"buy\s*&?\s*sell",
    r"mediahoek",
    r"it[- ]?resale",
    r"\.nl$",
    r"\.com$",
    r"b\.?v\.?$",
    r"webshop",
    r"shop",
    r"store",
    r"handel",
    r"electronics",
]

def _detect_seller_type(seller_name: str, is_verified: bool) -> str:
    name_lower = seller_name.lower()
    for pattern in BUSINESS_NAME_PATTERNS:
        if re.search(pattern, name_lower):
            return "business"
    return "business" if is_verified else "private"
```

---

## 🎯 Prioriteit 4: Filtering Uitbreiden

### Nieuwe parameters

```python
search_listings(
    ...,
    exclude_terms=["defect", "beschadigd", "voor onderdelen", "zonder lader"],
    must_include=["werkend", "oplader"],
    min_specs=True,           # Alleen items waar specs gevonden zijn
    working_only=True,        # Exclude defecte items
    exclude_chromebook=True,  # Filter Chromebooks uit laptop results
)
```

### Implementatie
```python
def _filter_listing(listing: dict, exclude_terms: list, must_include: list) -> bool:
    text = f"{listing['title']} {listing['description']}".lower()
    
    for term in exclude_terms:
        if term.lower() in text:
            return False
    
    for term in must_include:
        if term.lower() not in text:
            return False
    
    return True
```

---

## 📦 Prioriteit 5: Accessories Detectie

### Nieuw veld in response

```json
{
  "accessories": {
    "keyboard": true,
    "charger": true,
    "pen": false,
    "case": true,
    "mouse": false,
    "dock": false
  }
}
```

### Implementatie
```python
ACCESSORY_PATTERNS = {
    "keyboard": r"toetsenbord|keyboard|type\s*cover",
    "charger": r"oplader|lader|adapter|charger",
    "pen": r"pen|stylus",
    "case": r"hoes|case|cover|beschermhoes",
    "mouse": r"muis|mouse",
    "dock": r"dock|docking",
}
```

---

## 🛠️ Prioriteit 6: Kleine Verbeteringen

### 1. Condition normalisatie
```python
# null → "Onbekend"
condition = listing.get("condition") or "Onbekend"
```

### 2. Prijs indicators
```json
{
  "price_reduced": true,
  "accepting_bids": true,
  "highest_bid": 145
}
```

### 3. Fields parameter
```python
search_listings(..., fields=["id", "title", "price", "city", "specs"])
```

### 4. Batch get_listing_details
```python
get_listings_details(listing_ids=["m123", "m456", "m789"])
```

---

## 📊 Impact Overzicht

| Verbetering | Impact | Effort |
|-------------|--------|--------|
| Compact mode | 🔥🔥🔥 -75% tokens | Medium |
| Specs extractie | 🔥🔥 Betere data | Low |
| Seller type detectie | 🔥🔥 Accuracy | Low |
| Exclude filters | 🔥 Cleaner results | Medium |
| Accessories detectie | 🔥 Extra info | Low |
| Ultra-compact mode | 🔥🔥🔥 -90% tokens | Medium |

---

## ✅ Implementatie Volgorde

1. **Compact mode** - Grootste impact, doe eerst
2. **Seller type patterns** - Quick win
3. **Specs extractie uitbreiden** - Quick win
4. **Exclude/include filters** - Nice to have
5. **Accessories detectie** - Nice to have
6. **Ultra-compact mode** - Voor power users

---

*Laatst bijgewerkt: 2026-01-27*
