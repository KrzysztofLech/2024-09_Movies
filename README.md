# Zadanie testowe
Wrzesień 2024


## Opis zadania:
Napisz aplikację do wyświetlania listy filmów (w postaci listy lub kafelków) obecnie granych w kinach.
Lista może mieć możliwość wyszukiwania autocomplete. Po naciśnięciu na dany film, powinny zostać
wyświetlone szczegóły filmu.

## Wymagania biznesowe:
1. Wykorzystaj API The Movie DB: [https://developer.themoviedb.org/docs/getting-started](https://developer.themoviedb.org/docs/getting-started)
1. Wyświetl kolekcję filmów obecnie granych w kinach (użyj endpointa /movie/now_playing) uwzględniając paginację
1. Stwórz ekran szczegółów z plakatem filmu, tytułem, datą wydania, oceną oraz krótkim opisem (overview). Dane mogą zostać przekazane do tego widoku lub może zostać wykonany dodatkowy call o szczegóły filmu.
1. Na ekranie listy powinno być także zaimplementowane wyszukiwanie z podpowiadaniem (autocomplete). Użyj tutaj endpointa /serach/movie.
1. Powinniśmy mieć możliwość oznaczenia filmu jako ulubiony (dodanie serduszka na liście / kafelku oraz np. na NavigationBarze na ekranie szczegółów). Serduszko będzie włączona jeśli film jest ulubiony. Stan polubienia filmu ma być zapisywany i prezentowany po ponownym uruchomieniu aplikacji.

## Wymagania do kodu i projektu:
* język: Swift
* aplikacja powinna uruchamiać się na symulatorze oraz dowolnym iPhone z iOS 15 i wyżej
* UI wg własnego uznania, napisane w UIKit / SwiftUI
