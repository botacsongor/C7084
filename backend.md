## Feladat: Telefonok API (backend) – két végpont, validációval és hibakezeléssel

Valósíts meg egy HTTP alapú API-t, amely két végpontot biztosít telefonok kezelésére. A végpontok a `routes` fájlban legyenek megvalósítva, és minden kommunikáció JSON formátumban történjen.

### 1) `GET /api/telefonok`

A végpont feladata, hogy az adatbázisból lekérdezze a telefonok listáját, és JSON válaszban visszaküldje a kliensnek.

Hibakezelés:

* Ha az adatbázis-lekérdezés sikertelen (például nincs kapcsolat, hibás lekérdezés, szerverhiba), a végpont hibajelzést adjon vissza JSON formátumban, megfelelő HTTP státusszal.

### 2) `POST /api/telefonok`

A végpont feladata, hogy a kliens által küldött JSON adatokat fogadja, és ezek alapján új telefont rögzítsen az adatbázisban.

Validáció:

* A kérésben érkező adatoknál legyen legalább egy alap ellenőrzés, amely kiszűri a hiányzó vagy érvénytelen bemenetet (például üres mező vagy nem megfelelő típusú adat).
* Ha a bemenet hibás, a végpont ne végezzen adatbázis műveletet, hanem adjon vissza hibajelzést JSON válaszban.

Hibakezelés:

* Ha a beszúrás sikertelen (például adatbázis hiba vagy ütközés), a végpont kezelje a hibát, és adjon vissza JSON formátumú hibaüzenetet megfelelő HTTP státusszal.
* Sikeres beszúrás esetén a végpont JSON válaszban jelezze a sikeres műveletet.
