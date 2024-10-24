# SynthV-to-Language-Phoneme Plugin
**Synthesizer V Dreamtonics: Language Phoneme Converter**

## INTRODUCTION

Hello everyone, I have developed this script to allow customization of the current dictionary system, which has limitations when handling multilingual words.  
The script requires three supporting files for each language:
- `{language}.dic`
- `{language}-dream.dic`
- `{language}-syl.dic`

In this case, I have created files for the Italian language, namely `IT.dic`,`IT-dream.dic` and `IT-syl.dic`

## INSTALLATION

Copy .lua script inside script folders.
Create a subdirectory "languages" and put inside it the .dic files.

NOTES: Check the script directory inside the script.
Current is set with "Documenti" name, if it's not working change it accordingly your path.

## HOW IT WORKS

### IT-syl.DIC
This file contains the "syllabion rules" for extracting syllabes from words.
The structure is divided as follows:

> {RULE PLACEHOLDER},{REGEX SYLLABATION} {NUMBER OF SYLLABES}

Below is an example for the Italian "RL" rule

> RLB ^[bʧcdfptv][rl][aeɛioɔuèéòäùʊ][bʧcdfhjkʤgʎlmnɲŋpqrsʃtvwʊxyzʦʣ][aeɛioɔuèéòäùʊ](.*) 3

### IT.DIC
This file contains the "conversion rules" for transforming words into IPA (International Phonetic Alphabet).  
The structure is divided as follows:

> //{NOME_REGOLA}  {SIMBOLO_IPA},{SIMBOLO_LINGUA_CORRENTE}
> 
> {REGEX LUA SORGENTE},{REGEX LUA DESTINAZIUONE},{ECCEZIONE_1|ECCEZIONE_2|...}


Below is an example for the Italian "open O" sound, with two underlying conversion rules:

> //O_APERTA ɔ,o
>
> (.-)uo(.*),%1uɔ%2,liquore|languore
> 
> (.-)od(.?),%1ɔd%2,rod(.-)|erod(.-)|corrod(.-)|coda
> 
> (.-)o([bcdfhjkglmnpqrstvwxyz])([aeɛijouʊ])([aeɛijouʊ])(.*),%1ɔ%2%3%4%5,incrocio



In the first case, we are stating:
* Check if the word contains "uo" between two groups of any letters:
    * `(.-)uo(.*)`
* Convert it to "uɔ" while preserving the other letters:
    * `%1uɔ%2`
* Do not apply this rule if the primary word is "liquore" or "languore".

In the second case, we are stating:
* Check if the word ends with "od" followed by exactly one additional letter:
    * `(.-)od(.?)`
* Convert it to "ɔd" while preserving the other letters:
    * `%1ɔd%2`
* Do not apply this rule if the word begins with "rod-", "erod-", "corrod-", or is the word "coda."

In the third case, we are stating:
* Check if the word contains "o" followed by any of the consonants "bcdfhjkglmnpqrstvwxyz" and two vowels:
    * `(.-)o([bcdfhjkglmnpqrstvwxyz])([aeɛijouʊ])([aeɛijouʊ])(.*)`
* Convert it to "ɔ" while preserving the other letters:
    * `%1ɔ%2%3%4%5`
* Do not apply this rule if the word is "incrocio."



### IT-Dream.DIC
This file contains the "conversion rules" for transforming words from IPA to Synthesizer V phonemes.  
The structure is simpler than the previous one:

> {FONEMA IPA},{FONEMA SYNTH 1}:{LINGUA SYNTH 1}|{FONEMA SYNTH 2}:{LINGUA SYNTH 2}


Below is an example:

> ʧ,ch:ING|ch:SPA

In this case, the phoneme `ʧ` can be converted:
* into `ch` for English
* into `ch` for Spanish

## USAGE

The script should be used by:
* Selecting a group of notes

![img_1.png](resources/img_1.png)

* Choosing the conversion language (currently only Italian is supported)

![img_2.png](resources/img_2.png)

As you can see, the script will transform this group of notes:

![img.png](resources/img.png)

into this:

![img_3.png](resources/img_3.png)


Follows an example log

>[Logger Thu Oct 24 14:56:55 2024] INFO  - OS: Windows
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Language: IT
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Start processing rules
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Open Sillabe rule file C:\Users\ferra\OneDrive\Documenti\Dreamtonics\Synthesizer V Studio\scripts\Utilities\languages\IT-syl.dic
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Open IPA rule file C:\Users\ferra\OneDrive\Documenti\Dreamtonics\Synthesizer V Studio\scripts\Utilities\languages\IT.dic
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Open dream rule file C:\Users\ferra\OneDrive\Documenti\Dreamtonics\Synthesizer V Studio\scripts\Utilities\languages\IT-dream.dic
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - End processing rules
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Start processing notes
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Process note at 1
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Process word "amore" at 1
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Current word notes number are 4
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Check sillabe 1 "a" for lyric 1 "amore"
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Process sillabe "a" --> IPA: "a" --> Dream: 1: {1: a 2: CAN 3: a }
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Check sillabe 2 "mo" for lyric 2 "+"
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Process sillabe "mo" --> IPA: "mo" --> Dream: 1: {1: m o 2: CAN 3: mo }
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Check sillabe 3 "re" for lyric 3 "+"
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Process sillabe "re" --> IPA: "re" --> Dream: 1: {1: r 2: SPA 3: r } 2: {1: e 2: CAN 3: e }
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Process note at 5
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Process word "ti" at 5
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Current word notes number are 1
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Process single word "ti" --> IPA: "ti" --> Dream: 1: {1: t 2: SPA 3: t } 2: {1: i 2: CAN 3: i }
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Process note at 6
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Process word "voglio" at 6
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Current word notes number are 1
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Process single word "voglio" --> IPA: "vɔʎjo" --> Dream: 1: {1: v 2: ING 3: v } 2: {1: O 2: CAN 3: ɔ } 3: {1: y 2: SPA 3: ʎ } 4: {1: j o 2: CAN 3: jo }
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Process note at 7
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Process word "baciare" at 7
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Current word notes number are 5
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Check sillabe 1 "ba" for lyric 1 "baciare"
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Process sillabe "ba" --> IPA: "ba" --> Dream: 1: {1: b 2: SPA 3: b } 2: {1: a 2: CAN 3: a }
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Check sillabe 2 "cia" for lyric 2 "+"
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Process sillabe "cia" --> IPA: "ʧa" --> Dream: 1: {1: ch 2: SPA 3: ʧ } 2: {1: a 2: CAN 3: a }
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Check sillabe 3 "re" for lyric 3 "+"
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Process sillabe "re" --> IPA: "re" --> Dream: 1: {1: r 2: SPA 3: r } 2: {1: e 2: CAN 3: e }
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Process note at 11
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Process note at 12
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Process word "tutta" at 12
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Current word notes number are 2
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Check sillabe 1 "tut" for lyric 1 "tutta"
>
>[Logger Thu Oct 24 14:56:55 2024] INFO  - Process sillabe "tut" --> IPA: "tut" --> Dream: 1: {1: t 2: SPA 3: t } 2: {1: u 2: CAN 3: u } 3: {1: t 2: SPA 3: t }
>
>[Logger Thu Oct 24 14:56:56 2024] INFO  - Check sillabe 2 "ta" for lyric 2 "+"
>
>[Logger Thu Oct 24 14:56:56 2024] INFO  - Process sillabe "ta" --> IPA: "ta" --> Dream: 1: {1: t 2: SPA 3: t } 2: {1: a 2: CAN 3: a }



## IMPORTANT NOTES
The script evenly splits all words, processing them character by character, and replaces the lyrics with the necessary phonemes.  
This requires subsequent work to regroup the syllables where possible and to fix any timing issues.  
