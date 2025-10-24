# Kryteria Oceny Projektu MapReduce/Hive

## MapReduce - Mapper (Kryteria 1-8)

### Kryterium 01 (1 pkt) - Struktura danych wejściowych
**Ocena programu MapReduce - Mapper - struktura danych wejściowych**

Na początku sprawdź czy wariant implementacji (MapReduce Classic/Hadoop Streaming) zgadza się z deklaracją w opisie/temacie projektu:
- [ ] jeśli tak, kontynuuj sprawdzanie
- [ ] jeśli nie, wówczas wszystkie kryteria dotyczące MapReduce powinny być wyzerowane

Sprawdź czy Mapper prawidłowo interpretuje strukturę danych wejściowych:
- [ ] czy Mapper poprawnie ekstrahuje odpowiednie wartości
- [ ] czy uwzględniony został poprawny podział pól
- [ ] czy zastosowano konwersję typów (o ile była konieczna)
- [ ] czy uwzględniono poprawny format daty
- [ ] itp.

### Kryterium 02 (3 pkt) - Klucz pośredni (grupowania)
**Ocena programu MapReduce - Mapper - klucz pośredni (grupowania)**

Sprawdź czy klucz pośredni (grupowania) odpowiada wymaganiom zadania:
- [ ] w przypadku Hadoop Streaming upewnij się czy właściwie wskazano zakres ciągu znaków obejmowany przez klucz
- [ ] czy użyto właściwy separator (\t, ,, ;)
- [ ] czy jeśli był on niestandardowy, to dostosowano odpowiednio polecenie uruchamiające
- [ ] w przypadku MapReduce Classic sprawa identyfikacji klucza powinna być prosta

### Kryterium 03 (3 pkt) - Komplet danych dla agregatów
**Ocena programu MapReduce - Mapper - komplet danych dla agregatów**

Sprawdź czy dane przekazywane dalej zawierają wystarczające informacje do obliczenia wymaganych agregatów:
- [ ] Upewnij się, że Mapper przekazuje wystarczające dane do późniejszego obliczenia żądanych miar

**Uwaga!** w tym kryterium nie chodzi o możliwość agregacji wielopoziomowej. Wystarczy, że informacje dostarczane przez Mapper umożliwiają wykonanie odpowiednich obliczeń.

Przykładowo:
- [ ] brak ceny i tylko liczba towarów, uniemożliwi obliczenie średniej ceny - kryterium niespełnione
- [ ] tylko cena i brak liczby towarów, umożliwi obliczenie średniej ceny - kryterium spełnione (mimo iż agregacja wielopoziomowa będzie niemożliwa)

### Kryterium 04 (2 pkt) - Komplet danych dla agregacji wielopoziomowej
**Ocena programu MapReduce - Mapper - komplet danych dla agregacji wielopoziomowej**

Sprawdź czy Mapper dostarcza wartości w postaci umożliwiającej zastosowanie agregacji wielopoziomowej (np. w wyniku zastosowania combinerów):
- [ ] w przypadku funkcji niedystrybutywnych (np. średnia) często nie wystarczy przekazać prostej wartości, aby dokonać wielopoziomowych obliczeń (np. potrzebujemy: sumy + liczności)
- [ ] nawet w przypadku funkcji dystrybutywnych trzeba uważać, nie zawsze wartość, na której ma być wykonane obliczenie jest dobrą daną wynikową, czasami już Mapper powinien wykonywać częściową agregację lokalną, aby mogło dojść do dalszych wielopoziomowych agregacji

**Uwaga!** Nie oceniamy w tym kryterium czy agregacja wielopoziomowa (combinery) została użyta. Sprawdzamy tylko, czy byłoby to możliwe na podstawie danych zwracanych przez Mapper.

### Kryterium 05 (1 pkt) - Obsługa wyjątków i błędnych danych
**Ocena programu MapReduce - Mapper - obsługa wyjątków i błędnych danych**

Sprawdź czy Mapper radzi sobie z niepełnymi, pustymi, uszkodzonymi lub błędnie sformatowanymi danymi, pomijając je lub oznaczając:
- [ ] jakakolwiek weryfikacja danych wejściowych i obsługa przypadków błędnych jest w sposób jawny wykonywana

**Uwaga!** Nie ma konieczności sprawdzania wszystkich możliwych i niemożliwych wariantów problemów. Istotne jest jedynie czy jakakolwiek weryfikacja danych wejściowych i obsługa przypadków błędnych jest w sposób jawny wykonywana.

### Kryterium 06 (1 pkt) - Brak generowania danych błędnych lub nadmiarowych
**Ocena programu MapReduce - Mapper - brak generowania danych błędnych lub nadmiarowych**

Sprawdź:
- [ ] czy Mapper zawiera ewentualną selekcję danych (filtrowanie nieistotnych rekordów już na etapie mapowania)
- [ ] czy Mapper dokonuje ewentualnej preagregacji danych (w oparciu o wartości bieżącego źródłowego rekordu), jeśli byłoby to możliwe
- [ ] czy Mapper nie generuje danych błędnych (nie wynikających ze źródłowych danych)

### Kryterium 07 (3 pkt) - Oszczędność pamięciowa
**Ocena programu MapReduce - Mapper - oszczędność pamięciowa**

Sprawdź:
- [ ] czy Mapper nie utrzymuje struktur danych w pamięci (słowników, list) obejmujących dane spoza bieżącego źródłowego rekordu
- [ ] czy Mapper przetwarza rekordy "strumieniowo", generując wyniki dla każdego rekordu źródłowego osobno

### Kryterium 08 (1 pkt) - Czytelność i jakość implementacji
**Ocena programu MapReduce - Mapper - czytelność i jakość implementacji**

Sprawdź:
- [ ] czy kod jest dobrze sformatowany
- [ ] czy kod zawiera czytelne komentarze
- [ ] czy kod stosuje zrozumiałe i adekwatne do zawartości nazwy zmiennych i funkcji
- [ ] czy zastosowano logiczną strukturę (np. walidacja → parsowanie → emisja wyników)

## MapReduce - Reducer (Kryteria 9-14)

### Kryterium 09 (1 pkt) - Odczyt danych wejściowych
**Ocena programu MapReduce - Reducer - odczyt danych wejściowych**

Sprawdź czy Reduktor poprawnie interpretuje strukturę danych wejściowych, zgodną z typem/formatem danych generowanym przez mappery:
- [ ] właściwie uwzględniany jest format danych
- [ ] prawidłowo parsowane są wartości przekazywane z mappera, uwzględniając separatory, typy danych i kolejności pól
- [ ] w przypadku MapReduce Classic sprawdź deklaracje typów: w mapperze, reduktorze oraz konfiguracji zadania

### Kryterium 10 (4 pkt) - Poprawna agregacja
**Ocena programu MapReduce - Reducer - poprawna agregacja**

Sprawdź czy Reduktor dokonuje poprawnych agregacji, uwzględniając strukturę danych wejściowych oraz charakter obsługiwanej funkcji:
- [ ] dla każdego klucza wykonywane są poprawne obliczenia zgodne z treścią zadania
- [ ] używane odpowiednich wzory/funkcje
- [ ] nie występują problemy z użyciem niepoprawnych typów danych
- [ ] w szczególności w przypadku funkcji niedystrybutywnych prawidłowo są łączone dane częściowe przekazane przez mappery/combinery

### Kryterium 11 (4 pkt) - Oszczędność pamięciowa
**Ocena programu MapReduce - Reducer - oszczędność pamięciowa**

Sprawdź czy Reduktor jest oszczędny pamięciowo:
- [ ] nie utrzymuje on w pamięci słowników, list ani innych struktur danych gromadzących rekordy z wielu grup/kluczy
- [ ] przetwarza dane "strumieniowo": dla każdego klucza dokonuje agregacji, emituje wynik i przechodzi do następnej grupy/klucza

### Kryterium 12 (4 pkt) - Format wyniku
**Ocena programu MapReduce - Reducer - format wyniku**

Sprawdź czy Reduktor generuje dane w formacie zgodnym z wymaganiami dalszych etapów przetwarzania:
- [ ] format wynikowych danych (kolejność pól, separatory, typy danych) odpowiada specyfikacji zadania (np. nie brakuje żadnych atrybutów) i może być użyty w kolejnym etapie projektu
- [ ] nie są umieszczone w wyniku elementy uniemożliwiające jego dalsze przetwarzanie

**Uwaga!** Zwróć uwagę na to, że reduktor może generować dodatkowe wartości (miary) jeśli wymagane przez treść projektu elementy są niewystarczające do wykonania obliczeń na późniejszych etapach przetwarzania.

### Kryterium 13 (1 pkt) - Obsługa wyjątków i błędów
**Ocena programu MapReduce - Reducer - obsługa wyjątków i błędów**

Sprawdź czy Reduktor jest odporny na błędne lub niepełne dane w grupie:
- [ ] poprawnie obsługiwane są przypadki, w których część rekordów/wartości w grupie jest niepoprawna (np. pusta)
- [ ] w przypadku sytuacji błędnych nie są generowane błędy wykonania
- [ ] w przypadku braku poprawnych wartości w grupie nadal emitowany jest logicznie spójny wynik

**Uwaga!** Nie ma konieczności sprawdzania wszystkich możliwych i niemożliwych wariantów problemów. Istotne jest jedynie czy jakakolwiek weryfikacja danych wejściowych i obsługa przypadków błędnych jest w sposób jawny wykonywana.

### Kryterium 14 (1 pkt) - Czytelność i jakość implementacji
**Ocena programu MapReduce - Reducer - czytelność i jakość implementacji**

Sprawdź czy:
- [ ] kod jest czytelny, dobrze sformatowany, logicznie podzielony (np. etap agregacji → emisja wyników)
- [ ] zmiennym i funkcjom nadano zrozumiałe nazwy
- [ ] logika przetwarzania jest jasno i poprawnie udokumentowana komentarzami

## MapReduce - Combiner (Kryteria 15-20)

### Kryterium 15 (1 pkt) - Odczyt danych wejściowych
**Ocena programu MapReduce - Combiner - odczyt danych wejściowych**

Sprawdź czy agregator łączący (combiner) poprawnie interpretuje strukturę danych wejściowych, zgodną z typem/formatem danych generowanym przez mappery:
- [ ] właściwie uwzględniany jest format danych
- [ ] prawidłowo parsowane są wartości przekazywane z mappera, uwzględniając separatory, typy danych i kolejności pól
- [ ] w przypadku MapReduce Classic sprawdź deklaracje typów: w mapperze, reduktorze oraz konfiguracji zadania

### Kryterium 16 (4 pkt) - Poprawna agregacja
**Ocena programu MapReduce - Combiner - poprawna agregacja**

Sprawdź czy agregator łączący (combiner) dokonuje poprawnych agregacji, uwzględniając strukturę danych wejściowych oraz charakter obsługiwanej funkcji:
- [ ] dla każdego klucza wykonywane są poprawne obliczenia zgodne z treścią zadania
- [ ] używane odpowiednich wzory/funkcje
- [ ] nie występują problemy z użyciem niepoprawnych typów danych
- [ ] w szczególności w przypadku funkcji niedystrybutywnych prawidłowo są łączone dane częściowe przekazane przez mappery/poprzednie iteracje combinerów

### Kryterium 17 (4 pkt) - Oszczędność pamięciowa
**Ocena programu MapReduce - Combiner - oszczędność pamięciowa**

Sprawdź czy agregator łączący (combiner) jest oszczędny pamięciowo:
- [ ] nie utrzymuje on w pamięci słowników, list ani innych struktur danych gromadzących rekordy z wielu grup/kluczy
- [ ] przetwarza dane "strumieniowo": dla każdego klucza dokonuje agregacji, emituje wynik i przechodzi do następnej grupy/klucza

### Kryterium 18 (4 pkt) - Format wyniku
**Ocena programu MapReduce - Combiner - format wyniku**

Sprawdź czy agregator łączący (combiner) generuje dane o strukturze identycznej ze strukturą danych wejściowych:
- [ ] format klucza i wartości jest zgodny z tym, co produkują mappery
- [ ] struktura danych wyjściowych pozwala na ich dalsze łączenie (kolejne iteracje combinerów lub reduktory)
- [ ] Combiner nie zmienia semantyki danych – dokonuje tylko częściowej agregacji, nie może zmieniać formatu danych

### Kryterium 19 (1 pkt) - Obsługa wyjątków i błędów
**Ocena programu MapReduce - Combiner - obsługa wyjątków i błędów**

Sprawdź czy agregator łączący (combiner) jest odporny na błędne lub niepełne dane w grupie:
- [ ] poprawnie obsługiwane są przypadki, w których część rekordów/wartości w grupie jest niepoprawna (np. pusta)
- [ ] w przypadku sytuacji błędnych nie są generowane błędy wykonania
- [ ] w przypadku braku poprawnych wartości w grupie nadal emitowany jest logicznie spójny wynik

**Uwaga!** Nie ma konieczności sprawdzania wszystkich możliwych i niemożliwych wariantów problemów. Istotne jest jedynie czy jakakolwiek weryfikacja danych wejściowych i obsługa przypadków błędnych jest w sposób jawny wykonywana.

### Kryterium 20 (1 pkt) - Czytelność i jakość implementacji
**Ocena programu MapReduce - Combiner - czytelność i jakość implementacji**

Sprawdź czy:
- [ ] kod jest czytelny, dobrze sformatowany, logicznie podzielony (np. etap agregacji → emisja wyników)
- [ ] zmiennym i funkcjom nadano zrozumiałe nazwy
- [ ] logika przetwarzania jest jasno i poprawnie udokumentowana komentarzami

## MapReduce - Skrypt uruchamiający (Kryteria 21-25)

### Kryterium 21 (1 pkt) - Typ
**Ocena programu MapReduce - skrypt uruchamiający - typ**

Sprawdź czy polecenie uruchamiające jest zgodne z deklarowanym i zaimplementowanym wariantem MapReduce (MapReduce Classic lub Hadoop Streaming):

**Uwaga!** Przez skrypt rozumiemy zawartość dostarczonego w ramach projektu skryptu run_mr.sh.

W ramach tego i poniższych kryteriów dotyczących skryptu, nie oceniamy np. polecenia zawartego w definicji przepływu Apache Airflow chyba, że ocena dotyczy fragmentów identycznych zarówno w przepływie jak i w skrypcie (np. nie ma potrzeby uruchamiania skryptu jeśli jego poprawność lub wada została udowodniona identycznym poleceniem w przepływie).

**Uwaga!** W przypadku wariantu MapReduce Classic kryteria dotyczące "skryptu uruchamiającego" odnoszą się także do sposobu konfiguracji zadania MapReduce zawartego w metodzie run klasy głównej programu MapReduce.

- [ ] polecenie uruchamiające zgodne z wariantem implementacji

### Kryterium 22 (2 pkt) - Obsługa parametrów
**Ocena programu MapReduce - skrypt uruchamiający - obsługa parametrów**

Sprawdź czy parametry wywołania skryptu dotyczące ścieżek dla danych źródłowych oraz wynikowych zostały poprawnie obsłużone:
- [ ] W przypadku MapReduce Classic sprawdź czy konfiguracja zadania uwzględnia parametry dotyczące miejsca danych źródłowych i wynikowych

### Kryterium 23 (2 pkt) - Konfiguracja zadania
**Ocena programu MapReduce - skrypt uruchamiający - konfiguracja zadania**

Sprawdź czy:
- [ ] w przypadku Hadoop Streaming: mapper, reducer i ewentualny combiner są poprawnie wskazane i dostarczone
- [ ] w przypadku MapReduce Classic: klasy mappera, reducera i combinera (jeśli został użyty) są prawidłowo zadeklarowane, a konfiguracja zadania (job) spójna

### Kryterium 24 (6 pkt) - Poprawność wyniku ⭐
**Ocena programu MapReduce - skrypt uruchamiający - poprawność wyniku**

**Uwaga!** To kryterium wymaga znajomości poprawnego wyniku dla danych testowych.
**Uwaga!** To kryterium w rzeczywistości jest oceną całości przetwarzania MapReduce, a nie samego skryptu.

Sprawdź czy wynik uzyskany w rezultacie użycia skryptu (lub jego odpowiednika w definicji przepływu):
- [ ] zawiera poprawne wartości obliczonych wybranych agregatów
- [ ] zawiera wymaganą liczbę grup
- [ ] zawiera strukturę zgodną ze specyfikacją projektu (kolejność pól, typy danych, separatory)
- [ ] jest logicznie spójny i kompletny, może być użyty w kolejnych etapach przetwarzania

### Kryterium 25 (1 pkt) - Powtarzalność i ewentualna konieczność poprawy polecenia
**Ocena programu MapReduce - skrypt uruchamiający - powtarzalność i ewentualna konieczność poprawy polecenia**

Sprawdź czy:
- [ ] polecenia zawarte w skrypcie pozwalają na powtarzalne uruchomienie zadania MapReduce, w szczególności czy przed uruchomieniem zadania MapReduce usuwają istniejące ewentualnie miejsce docelowe
- [ ] ewentualne usunięcie nie istniejącego katalogu przeznaczonego na miejsce generowania wyniku nie powoduje błędu
- [ ] nie było konieczności poprawiania (w wyniku błędów popełnionych przez autora) poleceń zawartych w skrypcie zanim udało się go poprawnie uruchomić

## Hive - Skrypt HQL (Kryteria 26-34)

### Kryterium 26 (3 pkt) - Wykonanie bez błędów
**Ocena programu Hive - skrypt HQL - wykonanie bez błędów**

Sprawdź czy:
- [ ] skrypt zawierający polecenia HQL wykonuje bez błędów generowanych w wyniku użytych w skrypcie poleceń
- [ ] podczas wykonywania skryptu nie są generowane krytyczne wyjątki np. z powodu brakujących tabel, kolumn, itp.

### Kryterium 27 (2 pkt) - Użycie parametrów
**Ocena programu Hive - skrypt HQL - użycie parametrów**

Sprawdź czy skrypt zawierający polecenia HQL korzysta z parametrów określających położenie danych źródłowych oraz miejsce generowania danych wynikowych:
- [ ] skrypt wykorzystuje parametry dla lokalizacji danych

### Kryterium 28 (2 pkt) - Wykorzystanie danych źródłowych
**Ocena programu Hive - skrypt HQL - wykorzystanie danych źródłowych**

Sprawdź czy skrypt zawierający polecenia HQL:
- [ ] poprawnie definiuje struktury umożliwiające sięgnięcie do danych źródłowych będących wynikiem działania MapReduce
- [ ] poprawnie definiuje struktury umożliwiające sięgnięcie do danych źródłowych ze zbioru datasource4
- [ ] powyższe struktury umożliwiają dalsze ich przetwarzanie

**Uwaga!** Po wykonaniu przepływu struktury definiujące powyższe dane źródłowe powinny być nadal dostępne. Może Ci to pomóc w ocenie tego kryterium.

### Kryterium 29 (8 pkt) - Poprawność obliczeń ⭐
**Ocena programu Hive - skrypt HQL - poprawność obliczeń**

**Uwaga!** To kryterium wymaga znajomości poprawnego wyniku dla danych testowych.

Sprawdź czy polecenia HQL zawarte w skrypcie:
- [ ] tworzą wyniki na poziomie agregacji zgodnym z wymaganiami projektu
- [ ] wyliczają wartości agregacji zgodnie z ich charakterem i typami wykorzystywanych funkcji
- [ ] tworzą wyniki, które są poprawne i spójne z oczekiwanym rezultatem
- [ ] posiadają wszystkie wymagane w projekcie atrybuty/pola
- [ ] wartości wybranych miar/agregacji dla wybranych grup są zgodne z oczekiwanymi wynikami dla danych testowych

**Uwaga!** To kryterium nie wymaga poprawności w zakresie formatu danych wynikowych (JSON).

### Kryterium 30 (2 pkt) - Format danych wynikowych
**Ocena programu Hive - skrypt HQL - format danych wynikowych**

Sprawdź czy wynik zawiera rekordy w formacie JSON z atrybutami zgodnymi z projektem:
- [ ] format JSON z odpowiednimi atrybutami

### Kryterium 31 (1 pkt) - Użycie SERDE
**Ocena programu Hive - skrypt HQL - użycie SERDE**

Sprawdź czy do generowania wyników wykorzystano mechanizm SERDE:
- [ ] wykorzystano SERDE

### Kryterium 32 (8 pkt) - Wydajność ⭐
**Ocena programu Hive - skrypt HQL - wydajność**

Sprawdź czy w trakcie uzyskiwania wyniku nie korzystano z niepotrzebnych fizycznych struktur pośrednich w tym:
- [ ] tabel (w tym tymczasowych) do przechowywania wyników pośrednich
- [ ] tabel, do których kopiowano dane źródłowe
- [ ] itp.

Ponadto sprawdź czy w trakcie uzyskiwania wyniku nie odwoływano się do źródłowych danych wielokrotnie:
- [ ] brak wielokrotnego odwoływania się do danych źródłowych

Zakładamy, że:
- jednorazowe sięgnięcie do danych źródłowych i złożone przetwarzanie danych jest wydajniejsze od
- uproszczonego przetwarzania danych i wielokrotnego sięgania do danych źródłowych

### Kryterium 33 (2 pkt) - Powtarzalność uruchomienia
**Ocena programu Hive - skrypt HQL - powtarzalność uruchomienia**

Sprawdź czy skrypt może bez przeszkód być uruchamiany wielokrotnie bez wpływu na generowany wynik:
- [ ] skrypt nie usuwa danych źródłowych z ich oryginalnych miejsc
- [ ] usuwa wszelkie trwałe struktury lub definicje przed ich utworzeniem

### Kryterium 34 (2 pkt) - Debugowalność
**Ocena programu Hive - skrypt HQL - debugowalność**

Sprawdź czy skrypt pozostawia po swoim wykonaniu zarówno definicje/struktury dla:
- [ ] danych źródłowych (sprawdź także atrybuty dla danych źródłowych będących wynikiem programu MapReduce)
- [ ] danych wynikowych

## Hive - Skrypt uruchamiający (Kryteria 35-38)

### Kryterium 35 (2 pkt) - Poprawność polecenia
**Ocena programu Hive - skrypt uruchamiający - poprawność polecenia**

Sprawdź czy polecenie uruchamiające jest składniowo poprawne i zawiera wszelkie wymagane parametry:
- [ ] polecenie składniowo poprawne z wszystkimi parametrami

### Kryterium 36 (1 pkt) - Obsługa parametrów
**Ocena programu Hive - skrypt uruchamiający - obsługa parametrów**

Sprawdź czy parametry wywołania skryptu dotyczące ścieżek dla danych źródłowych oraz wynikowych zostały poprawnie obsłużone i dostarczone do skryptu HQL zgodny z jego zawartością:
- [ ] parametry poprawnie przekazane do HQL

### Kryterium 37 (1 pkt) - Użycie beeline
**Ocena programu Hive - skrypt uruchamiający - użycie beeline**

Sprawdź czy użyto w tym skrypcie programu beeline (lub innego "nowoczesnego" mechanizmu np. wywołania usługi REST) i w związku z tym nie wykorzystano hive CLI, co traktowane jest jako przestarzałe i co nie jest zalecane (0 pkt.):
- [ ] użyto beeline zamiast hive CLI

### Kryterium 38 (1 pkt) - Brak konieczności poprawy
**Ocena programu Hive - skrypt uruchamiający - brak konieczności poprawy**

Sprawdź czy nie było konieczności poprawiania (w wyniku błędów popełnionych przez autora) poleceń zawartych w skrypcie zanim udało się go poprawnie uruchomić:
- [ ] brak konieczności poprawy poleceń

## Apache Airflow (Kryteria 39-46)

### Kryterium 39 (1 pkt) - Parametry - wariant MapReduce
**Ocena przepływu Apache Airflow - parametry - wariant MapReduce**

Czy parametr określający wariant MapReduce miał wartość domyślną zgodną z deklaracją w opisie projektu?
- [ ] wartość domyślna parametru zgodna z deklaracją

### Kryterium 40 (1 pkt) - Polecenie MR - zgodność ze skryptem
**Ocena przepływu Apache Airflow - polecenie MR - zgodność ze skryptem**

Czy użyte w przepływie polecenie uruchamiające program MapReduce jest zgodne z dołączonym skryptem?
- [ ] polecenie w przepływie zgodne ze skryptem

### Kryterium 41 (1 pkt) - Polecenie MR - parametry
**Ocena przepływu Apache Airflow - polecenie MR - parametry**

Czy użyte w przepływie polecenie uruchamiające program MapReduce uwzględnia w sposób poprawny parametry przepływu określające miejsce dla danych źródłowych i wynikowych?
- [ ] parametry przepływu poprawnie uwzględnione

### Kryterium 42 (1 pkt) - Polecenie Hive - zgodność ze skryptem
**Ocena przepływu Apache Airflow - polecenie Hive - zgodność ze skryptem**

Czy użyte w przepływie polecenie uruchamiające program Hive jest zgodne z dołączonym skryptem?
- [ ] polecenie Hive zgodne ze skryptem

### Kryterium 43 (1 pkt) - Polecenie Hive - parametry
**Ocena przepływu Apache Airflow - polecenie Hive - parametry**

Czy użyte w przepływie polecenie uruchamiające program Hive uwzględnia w sposób poprawny parametry przepływu określające miejsce dla danych źródłowych i wynikowych?
- [ ] parametry Hive poprawnie uwzględnione

### Kryterium 44 (1 pkt) - Zawartość - zmiany
**Ocena przepływu Apache Airflow - zawartość - zmiany**

Sprawdź czy przepływ:
- [ ] we wszystkich pozostałych miejscach nie uległ zmianie, lub
- [ ] jeśli uległ zmianie, to zmiany te były niezbędne i w związku z tym uzasadnione

### Kryterium 45 (1 pkt) - Zawartość - powtarzalność
**Ocena przepływu Apache Airflow - zawartość - powtarzalność**

Sprawdź czy przepływ umożliwia jego wielokrotne uruchamianie - nie wprowadzono w nim zmian, które to blokują:
- [ ] przepływ umożliwia wielokrotne uruchamianie

### Kryterium 46 (1 pkt) - Zawartość - wynik
**Ocena przepływu Apache Airflow - zawartość - wynik**

Sprawdź czy przepływ w ramach ostatniej jednostki (tasku) prezentuje poprawnie wynik końcowy przetwarzania:
- [ ] ostatni task poprawnie prezentuje wynik końcowy

## Podsumowanie punktacji

**Najważniejsze kryteria wysokopunktowe:**
- **Kryterium 24**: Poprawność wyniku MapReduce (6 pkt)
- **Kryterium 29**: Poprawność obliczeń Hive (8 pkt) ⭐
- **Kryterium 32**: Wydajność Hive (8 pkt) ⭐

**Kryteria techniczne (4 pkt każde):**
- **Kryterium 10**: Reducer - poprawna agregacja (4 pkt)
- **Kryterium 11**: Reducer - oszczędność pamięciowa (4 pkt)
- **Kryterium 12**: Reducer - format wyniku (4 pkt)
- **Kryterium 16**: Combiner - poprawna agregacja (4 pkt)
- **Kryterium 17**: Combiner - oszczędność pamięciowa (4 pkt)
- **Kryterium 18**: Combiner - format wyniku (4 pkt)

**Kryteria średniopunktowe (3 pkt):**
- **Kryterium 02**: Mapper - klucz pośredni (3 pkt)
- **Kryterium 03**: Mapper - komplet danych dla agregatów (3 pkt)
- **Kryterium 07**: Mapper - oszczędność pamięciowa (3 pkt)
- **Kryterium 26**: Hive - wykonanie bez błędów (3 pkt)

**Łączna liczba punktów: około 100+**