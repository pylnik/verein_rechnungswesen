# Vereinskasse – Buchhaltungs-App für den Kassenwart

Eine Flutter-App zur Vereinsbuchhaltung für Android und Windows Desktop. Alle Daten werden lokal gespeichert und über einen Cloud-Ordner (Dropbox, OneDrive o. Ä.) synchronisiert. Es wird kein eigener Server benötigt.

---

## Projektbeschreibung

Der Kassenwart eines Sportvereins kann mit dieser App:

- Einnahmen, Ausgaben und Erstattungen erfassen
- Belege (PDFs) an Buchungen anhängen
- Buchungen in Kategorien einordnen (Lizenzen, Trikots, Hallenmiete, …)
- Buchungen zu Gruppen zusammenfassen (z. B. „Trikot-Bestellung 2026")
- Berichte und Auswertungen erstellen (ab Sprint 3)

Die App läuft vollständig offline. Synchronisation erfolgt automatisch über einen gemeinsam genutzten Cloud-Ordner (Dropbox, OneDrive, Google Drive etc.), der einmalig in den Einstellungen konfiguriert wird.

---

## Architektur

```
┌─────────────────────────────────────────────────┐
│                   Flutter App                   │
│  ┌──────────────┐   ┌──────────────────────────┐│
│  │    UI Layer  │   │        Data Layer         ││
│  │  (lib/ui/)   │──▶│  AppState + EventStore    ││
│  └──────────────┘   │      (lib/data/)          ││
│                     └─────────────┬────────────-┘│
└───────────────────────────────────┼─────────────-┘
                                    │ liest/schreibt
                              ┌─────▼──────┐
                              │ events.jsonl│  ← Cloud-Ordner
                              └────────────┘
```

### Event-Store (append-only JSONL)

Jede Änderung wird als JSON-Zeile in `events.jsonl` im konfigurierten Cloud-Ordner gespeichert. Beim App-Start werden alle Events der Reihe nach wiedergegeben, um den aktuellen Zustand zu rekonstruieren. Das Dateiformat ist bewusst einfach gehalten, damit es auch ohne die App lesbar und versionierbar ist.

Unterstützte Event-Typen:

| Event                  | Beschreibung                        |
|------------------------|-------------------------------------|
| `transactionCreated`   | Neue Buchung anlegen                |
| `transactionUpdated`   | Buchung bearbeiten                  |
| `transactionDeleted`   | Buchung löschen                     |
| `categoryCreated`      | Kategorie anlegen                   |
| `categoryDeleted`      | Kategorie löschen                   |
| `groupCreated`         | Gruppe anlegen                      |
| `groupUpdated`         | Gruppe bearbeiten                   |

### Datenmodelle

- **Transaction** – Buchung (Einnahme / Ausgabe / Erstattung) mit UUID, Betrag, Kategorie, Zahlungsart, Notizen und optionalem PDF-Anhang
- **Category** – Buchungskategorie
- **Group** – Zusammenfassung mehrerer Buchungen (z. B. Sammelbestellung)

---

## Setup

### Voraussetzungen

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.10
- Android Studio / VS Code mit Flutter-Plugin

### Installation

```bash
git clone https://github.com/pylnik/verein_rechnungswesen.git
cd verein_rechnungswesen
flutter pub get
```

### Starten

```bash
# Windows Desktop
flutter run -d windows

# Android (Gerät oder Emulator angeschlossen)
flutter run -d android

# Alle verfügbaren Geräte anzeigen
flutter devices
```

### Cloud-Ordner konfigurieren

1. App starten
2. Tab **Einstellungen** öffnen
3. Auf „Cloud-Ordner" tippen und den Dropbox- bzw. OneDrive-Ordner auswählen
4. App neu starten – alle Daten werden nun dort gespeichert

---

## Projektstruktur

```
lib/
├── main.dart                  # Einstiegspunkt, Tab-Navigation
├── models/
│   ├── transaction.dart       # Buchungs-Datenmodell
│   ├── category.dart          # Kategorie-Datenmodell
│   └── group.dart             # Gruppen-Datenmodell
├── data/
│   ├── event_store.dart       # Append-only JSONL Event-Store
│   └── app_state.dart         # Aktueller Zustand (aus Events aufgebaut)
├── ui/
│   ├── transactions_screen.dart  # Buchungsliste (Tab 1)
│   ├── capture_screen.dart       # Buchung erfassen (Tab 2)
│   ├── reports_screen.dart       # Berichte (Tab 3, Platzhalter)
│   └── settings_screen.dart      # Einstellungen (Tab 4)
└── utils/
    └── pdf_parser.dart        # PDF-Textextraktion (syncfusion_flutter_pdf)

assets/
└── categories.json            # Standard-Kategorien
```

---

## Geplante Features (Sprint-Übersicht)

| Sprint | Inhalt |
|--------|--------|
| **1** ✅ | Grundstruktur, Datenmodell, Event-Store, Basis-UI |
| **2** | Buchung erfassen: vollständiges Formular, Validierung, PDF-Anhang speichern |
| **3** | Berichte: Monatsübersicht, Kategorien-Auswertung, Saldo, Export als PDF |
| **4** | Gruppen: Sammelbestellungen anlegen, Buchungen zuordnen, Gruppenübersicht |
| **5** | PDF-Parser: automatische Feldbefüllung aus Bankauszug-PDFs |
| **6** | Cloud-Sync: Konflikterkennung, Merge-Strategie, Offline-Hinweise |
