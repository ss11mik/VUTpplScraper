# VUTpplScraper

Tento repozitář obsauje 2 bash skripty, (scrape.sh) a (stats.sh), které umožňují získat seznam osob v systému [VUT v Brně](https://vut.cz) a vypočítat z něj statistiky.


## API

Systém Studis poskytuje API endpoint `https://www.vut.cz/intra/vut-zpravy?action=ajax&term=$query&ajax=0`, který slouží pro našeptávání příjemců pro VUT zprávy. Odpověď je ve formátu JSON a je limitována na 100 výsledků. Pro dotaz s méně než 3 znaky API vrací prázdný výsledek, což lze ale obejít přidáním několika znaků tečky (.), které jinak neovlivňují výsledek vyhledávání.

API navíc nerozlišuje vyhledávání ve jméně a příjmení, což přináší redundanci ve výsledcích. Ta je řešena pouze odstraněním duplikátních řádků na konci skriptu. API taktéž nerozlišuje diakritiku ani velikost písmen.

Systém VUT poskytuje také jiné možnosti vyhledávání osob, tento byl vyhodnocen nejlépe z hlediska počtu potřebných requestů.

## Formát výstupu
Výstupní soubor je ve formátu
```
[tituly] Příjmení Jméno [tituly] (VUT číslo) - role [fakulta|součást VUT|VUT],...
```

Osoba může mít více vztahů s VUT, každý vztah zahrnuje roli a fakultu, součást VUT, případně obecně jen VUT. Role může nabývat hodnot:
- student
- zaměstnanec
- externista
- (osoba bez role)

Výstup skriptu nezahrnuje specializaci studia osoby (jelikož se v odpovědích používaného endpointu nevyskytuje).

## scrape.sh
`scrape.sh` implementuje stažení (*scrape*) všech osob ve VUT systému a jejich rolí.  Jelikož použitý endpoint vrací fixně 100 záznamů (případně méně), skript provádí rekursívní zanořování do vyhledávaného řetězce, dokud API nevrátí méně než 100 záznamů. V takovém případě je jasné, že není potřeba se dále zanořovat. V opačném případě se provedou další dotazy na původní řetězec + \[a-z\] a případně rekursivně dále.

Skript tedy například provede dotaz "a", na který dostane odpověď se 100 záznamy. Proto následně provede dotazy na "aa", "ab",..., "az" a pro odpovědi se 100 výsledky se takto dále zanořuje.

Odpovědi na jednotlivé dotazy jsou uloženy do složky pojmenované aktuálním datem a časem. Po skončení prohledávání jsou odstraněny duplicity, sežazený seznam je uložen do textového souboru `vut_datum_cas.txt` a na standardní výstup je vypsána statistika doby běhu, počtu requestů atd.

Mezi jednotlivé požadavky je vložena mezera 0.5 sekundy, jejímž účelem je zamezit přetěžování serverů nebo síťové infrastruktury. Hodnota 0.5 sekundy je magická konstanta.

## stats.sh
Skript `stats.sh` pracuje s výstupem předešlého skriptu, na jehož základě vypočítá personální statistiky pro jednotlivé faktuly, součásti a celé VUT. Ukázka výstupu se nachází v souboru (vut_230302_2155_stats.txt). Součet studentů, zaměstnanců a externistů fakulty nemusí odpovídat počtu osob dané fakulty, jelikož osoba může mít více vztahů s jednou nebo i více fakultami.

Skript má jeden parametr, jméno souboru se seznamem osob. Statistiku vypisuje na standardní výstup.


## Použití
Pro použití je nutné mít přístup do VUT systému. skript vyžaduje validní cookies s přihlášením k www.vut.cz v souboru `cookies.txt`. Lze je exportovat např. pomocí [cookies.txt addonu](https://addons.mozilla.org/en-US/firefox/addon/cookies-txt/) pro Firefox.

Běh scrape.sh orientačně trvá při současné situaci (březen 2023) přibližně 1 hodinu, během které je provedeno kolem 12 000 requestů, z toho přibližně 8 000 vrátí prázdný seznam.
