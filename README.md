# SynthV-to-Language-Phoneme Plugin
**Synthesizer V Dreamtonics: Language Phoneme Converter**

## INTRODUCTION

Hello everyone, I have developed this script to allow customization of the current dictionary system, which has limitations when handling multilingual words.  
The script requires two supporting files for each language:
- `{language}.dic`
- `{language}-dream.dic`

In this case, I have created files for the Italian language, namely `IT.dic` and `IT-dream.dic`.

## INSTALLATION

Copy .lua script inside script folders.
Create a subdirectory "languages" and put inside it the .dic files.

NOTES: Check the script directory inside the script.
Current is set with "Documenti" name, if it's not working change it accordingly your path.

## HOW IT WORKS

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

## IMPORTANT NOTES
The script evenly splits all words, processing them character by character, and replaces the lyrics with the necessary phonemes.  
This requires subsequent work to regroup the syllables where possible and to fix any timing issues.  
