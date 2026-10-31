# -*- coding: utf-8 -*-
# Generates qml/i18n.js. Keys = English. Columns: pl, de, es, it, fr.
import json, sys
L = ["pl", "de", "es", "it", "fr"]
S = {
"%1 satellites in view, %2 in use.": ("Widoczne satelity: %1, używane: %2.", "%1 Satelliten sichtbar, %2 genutzt.", "%1 satélites visibles, %2 en uso.", "%1 satelliti visibili, %2 in uso.", "%1 satellites visibles, %2 utilisés."),
"About": ("O programie", "Über", "Acerca de", "Informazioni", "À propos"),
"Active signal": ("Aktywny sygnał", "Aktives Signal", "Señal activa", "Segnale attivo", "Signal actif"),
"All applications use the same positioning service of the phone, so this application cannot make the GPS itself faster. The first fix is quicker outdoors, with mobile data on (assisted GPS) and shortly after another fix.":
 ("Wszystkie aplikacje korzystają z tej samej usługi lokalizacji telefonu, więc ta aplikacja nie przyspieszy samego GPS. Pierwsza pozycja pojawia się szybciej na zewnątrz, z włączoną transmisją danych (wspomagany GPS) i krótko po poprzednim ustaleniu pozycji.",
  "Alle Anwendungen nutzen denselben Ortungsdienst des Telefons, daher kann diese Anwendung das GPS selbst nicht beschleunigen. Die erste Position kommt schneller im Freien, mit eingeschalteten mobilen Daten (A-GPS) und kurz nach einer vorherigen Position.",
  "Todas las aplicaciones usan el mismo servicio de ubicación del teléfono, así que esta aplicación no puede acelerar el GPS. La primera posición llega antes al aire libre, con datos móviles activos (GPS asistido) y poco después de otra posición.",
  "Tutte le applicazioni usano lo stesso servizio di localizzazione del telefono, quindi questa applicazione non può rendere il GPS più veloce. La prima posizione arriva prima all'aperto, con i dati mobili attivi (GPS assistito) e poco dopo un'altra posizione.",
  "Toutes les applications utilisent le même service de localisation du téléphone : cette application ne peut donc pas accélérer le GPS. La première position arrive plus vite en extérieur, avec les données mobiles activées (GPS assisté) et peu après une autre position."),
"Altitude": ("Wysokość", "Höhe", "Altitud", "Altitudine", "Altitude"),
"Application settings": ("Ustawienia aplikacji", "Einstellungen", "Ajustes de la aplicación", "Impostazioni", "Réglages de l'application"),
"Average data": ("Dane uśrednione", "Durchschnittswerte", "Datos promedio", "Dati medi", "Données moyennes"),
"Averages are counted from valid readings, not from time. The accuracy bars show the last reading (bar) and the average (dot) on a 0–50 m scale.":
 ("Średnie liczone są z poprawnych odczytów, nie z czasu. Paski dokładności pokazują ostatni odczyt (pasek) i średnią (kropka) w skali 0–50 m.",
  "Durchschnitte werden aus gültigen Messungen berechnet, nicht über die Zeit. Die Genauigkeitsbalken zeigen die letzte Messung (Balken) und den Durchschnitt (Punkt) auf einer Skala von 0–50 m.",
  "Los promedios se calculan con lecturas válidas, no por tiempo. Las barras de precisión muestran la última lectura (barra) y el promedio (punto) en una escala de 0–50 m.",
  "Le medie sono calcolate sulle letture valide, non sul tempo. Le barre di precisione mostrano l'ultima lettura (barra) e la media (punto) su una scala 0–50 m.",
  "Les moyennes sont calculées sur les mesures valides, pas sur le temps. Les barres de précision montrent la dernière mesure (barre) et la moyenne (point) sur une échelle de 0 à 50 m."),
"Avg altitude": ("Śr. wysokość", "Ø Höhe", "Altitud media", "Altitudine media", "Altitude moy."),
"Avg latitude": ("Śr. szerokość", "Ø Breite", "Latitud media", "Latitudine media", "Latitude moy."),
"Avg longitude": ("Śr. długość", "Ø Länge", "Longitud media", "Longitudine media", "Longitude moy."),
"Avg speed": ("Śr. prędkość", "Ø Geschw.", "Velocidad media", "Velocità media", "Vitesse moy."),
"Compass calibration": ("Kalibracja kompasu", "Kompasskalibrierung", "Calibración brújula", "Calibrazione bussola", "Calibrage boussole"),
"Copy OpenStreetMap link": ("Kopiuj link OpenStreetMap", "OpenStreetMap-Link kopieren", "Copiar enlace de OpenStreetMap", "Copia link OpenStreetMap", "Copier le lien OpenStreetMap"),
"Copy as decimal degrees": ("Kopiuj w stopniach dziesiętnych", "Als Dezimalgrad kopieren", "Copiar en grados decimales", "Copia in gradi decimali", "Copier en degrés décimaux"),
"Copy average position": ("Kopiuj średnią pozycję", "Durchschnittsposition kopieren", "Copiar posición media", "Copia posizione media", "Copier la position moyenne"),
"Data from GPS unit": ("Dane z odbiornika GPS", "Daten vom GPS-Empfänger", "Datos del receptor GPS", "Dati dal ricevitore GPS", "Données du récepteur GPS"),
"Designed and written by Claude (Anthropic) together with smyhu for the Nokia N9.":
 ("Zaprojektowany i napisany przez Claude (Anthropic) wspólnie ze smyhu dla Nokii N9.",
  "Entworfen und geschrieben von Claude (Anthropic) zusammen mit smyhu für das Nokia N9.",
  "Diseñado y escrito por Claude (Anthropic) junto con smyhu para el Nokia N9.",
  "Progettato e scritto da Claude (Anthropic) insieme a smyhu per il Nokia N9.",
  "Conçu et écrit par Claude (Anthropic) avec smyhu pour le Nokia N9."),
"E": ("E", "O", "E", "E", "E"),
"Faster first fix": ("Szybsze ustalenie pozycji", "Schnellere erste Position", "Primera posición más rápida", "Prima posizione più rapida", "Première position plus rapide"),
"GPS is not active": ("GPS jest wyłączony", "GPS ist nicht aktiv", "El GPS no está activo", "Il GPS non è attivo", "Le GPS n'est pas actif"),
"GPS is off. Tap here to start.": ("GPS wyłączony. Stuknij tutaj, aby włączyć.", "GPS ist aus. Zum Starten hier tippen.", "GPS apagado. Toca aquí para empezar.", "GPS spento. Tocca qui per avviare.", "GPS éteint. Touchez ici pour démarrer."),
"Horizontal accuracy": ("Dokładność pozioma", "Horizontale Genauigkeit", "Precisión horizontal", "Precisione orizzontale", "Précision horizontale"),
"How to use it": ("Jak korzystać", "Bedienung", "Cómo se usa", "Come si usa", "Mode d'emploi"),
"Inspired by the layout of GPS MeeFo by DV8 Creations; all code and graphics are new.":
 ("Układ wzorowany na GPS MeeFo (DV8 Creations); cały kod i grafika są nowe.",
  "Layout nach dem Vorbild von GPS MeeFo (DV8 Creations); Code und Grafiken sind neu.",
  "Diseño inspirado en GPS MeeFo de DV8 Creations; todo el código y los gráficos son nuevos.",
  "Layout ispirato a GPS MeeFo di DV8 Creations; tutto il codice e la grafica sono nuovi.",
  "Disposition inspirée de GPS MeeFo de DV8 Creations ; tout le code et les graphismes sont nouveaux."),
"Latitude": ("Szerokość", "Breite", "Latitud", "Latitudine", "Latitude"),
"Loading map": ("Wczytywanie mapy", "Karte wird geladen", "Cargando mapa", "Caricamento mappa", "Chargement de la carte"),
"Loading…": ("Wczytywanie…", "Wird geladen…", "Cargando…", "Caricamento…", "Chargement…"),
"Longitude": ("Długość", "Länge", "Longitud", "Longitudine", "Longitude"),
"Map of average position": ("Mapa średniej pozycji", "Karte der Durchschnittsposition", "Mapa de la posición media", "Mappa della posizione media", "Carte de la position moyenne"),
"Map of last known position": ("Mapa ostatniej znanej pozycji", "Karte der letzten bekannten Position", "Mapa de la última posición conocida", "Mappa dell'ultima posizione nota", "Carte de la dernière position connue"),
"Maps: © OpenStreetMap contributors (OSM France, OpenTopoMap, CyclOSM), © Esri.":
 ("Mapy: © współtwórcy OpenStreetMap (OSM France, OpenTopoMap, CyclOSM), © Esri.",
  "Karten: © OpenStreetMap-Mitwirkende (OSM France, OpenTopoMap, CyclOSM), © Esri.",
  "Mapas: © colaboradores de OpenStreetMap (OSM France, OpenTopoMap, CyclOSM), © Esri.",
  "Mappe: © contributori OpenStreetMap (OSM France, OpenTopoMap, CyclOSM), © Esri.",
  "Cartes : © contributeurs OpenStreetMap (OSM France, OpenTopoMap, CyclOSM), © Esri."),
"N": ("N", "N", "N", "N", "N"),
"Network": ("Sieć", "Netzwerk", "Red", "Rete", "Réseau"),
"No": ("Nie", "Nein", "No", "No", "Non"),
"Not available": ("Niedostępne", "Nicht verfügbar", "No disponible", "Non disponibile", "Indisponible"),
"Open position in Maps": ("Otwórz pozycję w Mapach", "Position in Karten öffnen", "Abrir posición en Mapas", "Apri posizione in Mappe", "Ouvrir la position dans Cartes"),
"S": ("S", "S", "S", "S", "S"),
"Satellite and network": ("Satelity i sieć", "Satellit und Netzwerk", "Satélite y red", "Satellite e rete", "Satellite et réseau"),
"Satellite data": ("Dane satelitów", "Satellitendaten", "Datos de satélites", "Dati dei satelliti", "Données satellites"),
"Satellite": ("Satelity", "Satellit", "Satélite", "Satellite", "Satellite"),
"Satellites in use": ("Satelity używane", "Genutzte Satelliten", "Satélites en uso", "Satelliti in uso", "Satellites utilisés"),
"Satellites in view": ("Satelity widoczne", "Sichtbare Satelliten", "Satélites visibles", "Satelliti visibili", "Satellites visibles"),
"Searching for signal": ("Szukanie sygnału", "Signalsuche", "Buscando señal", "Ricerca del segnale", "Recherche du signal"),
"Searching: %1 satellites in view, %2 in use": ("Szukanie: widoczne satelity %1, używane %2", "Suche: %1 Satelliten sichtbar, %2 genutzt", "Buscando: %1 satélites visibles, %2 en uso", "Ricerca: %1 satelliti visibili, %2 in uso", "Recherche : %1 satellites visibles, %2 utilisés"),
"Session finished": ("Sesja zakończona", "Sitzung beendet", "Sesión terminada", "Sessione terminata", "Session terminée"),
"Session finished. Tap here for options.": ("Sesja zakończona. Stuknij tutaj, aby wybrać.", "Sitzung beendet. Für Optionen hier tippen.", "Sesión terminada. Toca aquí para ver opciones.", "Sessione terminata. Tocca qui per le opzioni.", "Session terminée. Touchez ici pour les options."),
"Shows what the GPS receiver sees: satellites in view and in use, signal strength, position, accuracy and averages.":
 ("Pokazuje, co widzi odbiornik GPS: satelity widoczne i używane, siłę sygnału, pozycję, dokładność i średnie.",
  "Zeigt, was der GPS-Empfänger sieht: sichtbare und genutzte Satelliten, Signalstärke, Position, Genauigkeit und Durchschnitte.",
  "Muestra lo que ve el receptor GPS: satélites visibles y en uso, intensidad de señal, posición, precisión y promedios.",
  "Mostra ciò che vede il ricevitore GPS: satelliti visibili e in uso, potenza del segnale, posizione, precisione e medie.",
  "Montre ce que voit le récepteur GPS : satellites visibles et utilisés, force du signal, position, précision et moyennes."),
"Skip this page on startup": ("Pomijaj tę stronę przy starcie", "Diese Seite beim Start überspringen", "Omitir esta página al iniciar", "Salta questa pagina all'avvio", "Ignorer cette page au démarrage"),
"Source": ("Źródło", "Quelle", "Fuente", "Fonte", "Source"),
"Speed": ("Prędkość", "Geschwindigkeit", "Velocidad", "Velocità", "Vitesse"),
"Start new session": ("Nowa sesja", "Neue Sitzung", "Nueva sesión", "Nuova sessione", "Nouvelle session"),
"Start the GPS on startup": ("Włączaj GPS przy starcie", "GPS beim Start einschalten", "Activar el GPS al iniciar", "Avvia il GPS all'avvio", "Activer le GPS au démarrage"),
"Startup settings": ("Ustawienia startowe", "Starteinstellungen", "Ajustes de inicio", "Impostazioni di avvio", "Réglages de démarrage"),
"Stop the GPS after 5 minutes": ("Wyłączaj GPS po 5 minutach", "GPS nach 5 Minuten ausschalten", "Apagar el GPS tras 5 minutos", "Spegni il GPS dopo 5 minuti", "Arrêter le GPS après 5 minutes"),
"Tap here to start.": ("Stuknij tutaj, aby włączyć.", "Zum Starten hier tippen.", "Toca aquí para empezar.", "Tocca qui per avviare.", "Touchez ici pour démarrer."),
"Tap the map name to change the map, use − and + to zoom. Maps need an internet connection; some use HTTPS and need the TLS 1.2 update.":
 ("Stuknij nazwę mapy, aby ją zmienić; − i + zmieniają powiększenie. Mapy wymagają internetu, część z nich używa HTTPS i potrzebuje aktualizacji TLS 1.2.",
  "Kartennamen antippen, um die Karte zu wechseln; − und + zoomen. Karten brauchen Internet; manche nutzen HTTPS und benötigen das TLS-1.2-Update.",
  "Toca el nombre del mapa para cambiarlo; − y + para el zoom. Los mapas necesitan internet; algunos usan HTTPS y requieren la actualización TLS 1.2.",
  "Tocca il nome della mappa per cambiarla; − e + per lo zoom. Le mappe richiedono internet; alcune usano HTTPS e richiedono l'aggiornamento TLS 1.2.",
  "Touchez le nom de la carte pour la changer ; − et + pour le zoom. Les cartes nécessitent internet ; certaines utilisent HTTPS et demandent la mise à jour TLS 1.2."),
"Tap the map to centre it on your position": ("Stuknij mapę, aby wyśrodkować ją na pozycji", "Karte antippen, um sie auf die Position zu zentrieren", "Toca el mapa para centrarlo en tu posición", "Tocca la mappa per centrarla sulla posizione", "Touchez la carte pour la centrer sur votre position"),
"Tap to look around while waiting.": ("Stuknij, aby rozejrzeć się w aplikacji podczas czekania.", "Tippen, um sich während des Wartens umzusehen.", "Toca para explorar mientras esperas.", "Tocca per guardarti intorno durante l'attesa.", "Touchez pour explorer en attendant."),
"The GPS was stopped to save the battery. What would you like to do?": ("GPS wyłączono, aby oszczędzać baterię. Co chcesz zrobić?", "Das GPS wurde zum Akkusparen ausgeschaltet. Was möchten Sie tun?", "El GPS se apagó para ahorrar batería. ¿Qué quieres hacer?", "Il GPS è stato spento per risparmiare batteria. Cosa vuoi fare?", "Le GPS a été arrêté pour économiser la batterie. Que voulez-vous faire ?"),
"The position plot shows the last 5 readings around the average position (red dot). R is the radius of the outer ring.":
 ("Wykres pozycji pokazuje 5 ostatnich odczytów wokół średniej pozycji (czerwona kropka). R to promień zewnętrznego okręgu.",
  "Das Positionsdiagramm zeigt die letzten 5 Messungen um die Durchschnittsposition (roter Punkt). R ist der Radius des äußeren Rings.",
  "El gráfico de posición muestra las últimas 5 lecturas alrededor de la posición media (punto rojo). R es el radio del anillo exterior.",
  "Il grafico di posizione mostra le ultime 5 letture intorno alla posizione media (punto rosso). R è il raggio dell'anello esterno.",
  "Le graphique de position montre les 5 dernières mesures autour de la position moyenne (point rouge). R est le rayon de l'anneau extérieur."),
"The refresh button starts a new session: the GPS is switched on and the averages start from zero.":
 ("Przycisk odświeżania zaczyna nową sesję: GPS się włącza, a średnie liczą się od zera.",
  "Die Aktualisieren-Taste startet eine neue Sitzung: Das GPS wird eingeschaltet und die Durchschnitte beginnen bei null.",
  "El botón de actualizar inicia una nueva sesión: se enciende el GPS y los promedios empiezan de cero.",
  "Il pulsante di aggiornamento avvia una nuova sessione: il GPS si accende e le medie ripartono da zero.",
  "Le bouton d'actualisation démarre une nouvelle session : le GPS s'allume et les moyennes repartent de zéro."),
"The share button copies the average position or opens it in the Maps application.":
 ("Przycisk udostępniania kopiuje średnią pozycję albo otwiera ją w Mapach.",
  "Die Teilen-Taste kopiert die Durchschnittsposition oder öffnet sie in der Karten-App.",
  "El botón de compartir copia la posición media o la abre en Mapas.",
  "Il pulsante di condivisione copia la posizione media o la apre in Mappe.",
  "Le bouton de partage copie la position moyenne ou l'ouvre dans Cartes."),
"The sky plot shows satellites by direction and height above the horizon (centre = straight up). Bright, larger circles are used for the position. The plot turns with the compass; the N mark points north.":
 ("Mapa nieba pokazuje satelity według kierunku i wysokości nad horyzontem (środek = prosto w górę). Jasne, większe kółka są używane do ustalenia pozycji. Wykres obraca się z kompasem; znacznik N wskazuje północ.",
  "Die Himmelskarte zeigt Satelliten nach Richtung und Höhe über dem Horizont (Mitte = senkrecht oben). Helle, größere Kreise werden für die Position genutzt. Die Karte dreht sich mit dem Kompass; die N-Marke zeigt nach Norden.",
  "El mapa del cielo muestra los satélites por dirección y altura sobre el horizonte (centro = justo arriba). Los círculos claros y grandes se usan para la posición. El gráfico gira con la brújula; la marca N apunta al norte.",
  "La mappa del cielo mostra i satelliti per direzione e altezza sull'orizzonte (centro = verticale). I cerchi chiari e grandi sono usati per la posizione. Il grafico ruota con la bussola; il segno N indica il nord.",
  "La carte du ciel montre les satellites selon leur direction et leur hauteur au-dessus de l'horizon (centre = à la verticale). Les cercles clairs et plus grands servent à la position. Le graphique tourne avec la boussole ; le repère N indique le nord."),
"Time to first fix": ("Czas do 1. pozycji", "Zeit bis 1. Position", "Tiempo a 1.ª posición", "Tempo al 1° fix", "Délai 1re position"),
"waiting…": ("czekam…", "warte…", "esperando…", "in attesa…", "en attente…"),
"Time": ("Czas", "Zeit", "Hora", "Ora", "Heure"),
"Use dark theme": ("Ciemny motyw", "Dunkles Design", "Tema oscuro", "Tema scuro", "Thème sombre"),
"Use decimal notation": ("Zapis dziesiętny", "Dezimalschreibweise", "Notación decimal", "Notazione decimale", "Notation décimale"),
"Use degrees notation": ("Zapis w stopniach", "Grad-Schreibweise", "Notación en grados", "Notazione in gradi", "Notation en degrés"),
"Use imperial units": ("Jednostki imperialne", "Imperiale Einheiten", "Unidades imperiales", "Unità imperiali", "Unités impériales"),
"Use light theme": ("Jasny motyw", "Helles Design", "Tema claro", "Tema chiaro", "Thème clair"),
"Use metric units": ("Jednostki metryczne", "Metrische Einheiten", "Unidades métricas", "Unità metriche", "Unités métriques"),
"Valid samples": ("Poprawne odczyty", "Gültige Messungen", "Lecturas válidas", "Letture valide", "Mesures valides"),
"Vertical accuracy": ("Dokładność pionowa", "Vertikale Genauigkeit", "Precisión vertical", "Precisione verticale", "Précision verticale"),
"View last session": ("Pokaż ostatnią sesję", "Letzte Sitzung ansehen", "Ver última sesión", "Vedi ultima sessione", "Voir la dernière session"),
"W": ("W", "W", "O", "O", "O"),
"While the phone is searching for satellites, a green box shows their signal. Tap it to look around the application while waiting.":
 ("Gdy telefon szuka satelitów, zielone okienko pokazuje ich sygnał. Stuknij je, aby w tym czasie przeglądać aplikację.",
  "Während das Telefon Satelliten sucht, zeigt ein grünes Feld deren Signal. Antippen, um sich währenddessen in der App umzusehen.",
  "Mientras el teléfono busca satélites, un recuadro verde muestra su señal. Tócalo para explorar la aplicación mientras esperas.",
  "Mentre il telefono cerca i satelliti, un riquadro verde ne mostra il segnale. Toccalo per esplorare l'applicazione durante l'attesa.",
  "Pendant que le téléphone cherche les satellites, un cadre vert montre leur signal. Touchez-le pour explorer l'application en attendant."),
"Yes": ("Tak", "Ja", "Sí", "Sì", "Oui"),
"Your position stays on the phone. The application does not send, store or share it. Only the map tiles for the area around you are downloaded from the selected map server.":
 ("Twoja pozycja zostaje w telefonie. Aplikacja jej nie wysyła ani nie udostępnia. Z wybranego serwera map pobierane są tylko fragmenty mapy okolicy.",
  "Ihre Position bleibt auf dem Telefon. Die App sendet oder teilt sie nicht. Nur die Kartenkacheln Ihrer Umgebung werden vom gewählten Kartenserver geladen.",
  "Tu posición se queda en el teléfono. La aplicación no la envía ni la comparte. Solo se descargan del servidor de mapas elegido los mosaicos de tu zona.",
  "La tua posizione resta sul telefono. L'applicazione non la invia né la condivide. Dal server di mappe scelto vengono scaricati solo i riquadri della tua zona.",
  "Votre position reste sur le téléphone. L'application ne l'envoie ni ne la partage. Seules les tuiles de carte de votre secteur sont téléchargées depuis le serveur choisi."),
"Your privacy": ("Prywatność", "Datenschutz", "Privacidad", "Privacy", "Confidentialité"),
"for Nokia N9, version %1": ("dla Nokii N9, wersja %1", "für Nokia N9, Version %1", "para Nokia N9, versión %1", "per Nokia N9, versione %1", "pour Nokia N9, version %1"),
}
d = {}
for k, v in sorted(S.items()):
    assert len(v) == 5, k
    d[k] = dict(zip(L, v))
js = json.dumps(d, ensure_ascii=False, indent=1, sort_keys=True)
open(sys.argv[1], "w").write(u"""// Translations. Keys are English (fallback); languages: pl, de, es, it, fr.
// Generated by tools/i18n.py - edit there. Copyright (c) 2026 smyhu. MIT License.
// No ".pragma library": needs the "helper" context object.

var dict = %s;

var lang = "";
function language() {
    if (lang == "") {
        lang = ("" + helper.language).substring(0, 2).toLowerCase()
        if (lang == "") lang = "en"
    }
    return lang
}

// t("text", a1, a2): translation with %%1 and %%2 replaced.
function t(s, a1, a2) {
    var r = s
    var e = dict[s]
    if (e !== undefined && e[language()] !== undefined)
        r = e[language()]
    if (a1 !== undefined) r = r.replace("%%1", a1)
    if (a2 !== undefined) r = r.replace("%%2", a2)
    return r
}
""" % js)
