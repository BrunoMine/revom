# revom

[![download](https://img.shields.io/github/tag/BrunoMine/revom.svg?style=flat-square&label=release)](https://github.com/BrunoMine/revom/archive/master.zip)
[![git](https://img.shields.io/badge/git-project-green.svg?style=flat-square)](https://github.com/BrunoMine/revom)
[![forum](https://img.shields.io/badge/minetest-mod-green.svg?style=flat-square)](https://forum.minetest.net/viewtopic.php?f=9&t=21605)
[![bower](https://img.shields.io/badge/bower-mod-green.svg?style=flat-square)](https://minetest-bower.herokuapp.com/mods/revom)

## Descrição
Modo de jogo que espalha os jogadores de forma homogenea pelo mundo
Nome deriva de REVOção de Mundo pois pretende revolucionar a experiencia multiplayer em minetest

## Requisitos _(Requirements)_

## Configurações avançadas
É possivel reconfigurar o loot de itens padrão adicionando a seguinte linha em `minetest.conf`
```conf
revom_set_item_loot_<itemstring trocando o ':' por '_'> = <raridade 0.000 a 1.000> <preciosidade 1 a 10> <intervalo de quantidades> <intervalo de desgaste para ferramentas>
# Exemplos
# Cuidado com os espaços e os traços para intervalos (min-max)
# use disable para desativar o loot do item
# Escreva nil nos trechos que não vai usar
revom_set_item_loot_farming_bread = 1.000 4 98-99 nil
revom_set_item_loot_3d_armor_helmet_wood = 0.001 1 nil 1000-65000
revom_set_item_loot_3d_armor_helmet_diamond = disable
```

## Licença
Veja LICENSE.txt para informações detalhadas da licença LGPL 3.0

### Autores do código fonte
Originalmente por BrunoMine, Bruno Borges <borgesdossantosbruno@gmail.com> (LGPL 3.0)

### Autores de mídias (texturas, modelos and sons)
Todos que não estao listados aqui:
BrunoMine, Bruno Borges <borgesdossantosbruno@gmail.com> (CC BY-SA 3.0)



