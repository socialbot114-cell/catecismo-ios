#!/usr/bin/env python3
"""Adiciona os 3 guias restantes ao tools/guides_content.json."""
import json
from pathlib import Path

p = Path("tools/guides_content.json")
d = json.loads(p.read_text(encoding="utf-8"))

GUIDES = {
    "a-igreja-viva": {
        "title": "A Igreja viva",
        "category": "Igreja",
        "description": "A comunidade como espaço de encontro, serviço e esperança: mistério, vocação e comunhão.",
        "context": "Guia autoral de leitura e reflexão inspirado na estrutura do Catecismo da Igreja Católica.",
        "characters": ["Igreja", "Comunhão dos santos", "Maria", "Sacramentos"],
        "chapters": [
            {
                "title": "Mistério e vocação",
                "paragraphs": [
                    "A Igreja não é um órgão de gestão religiosa: é mistério de comunhão do Deus Trino com o povo crente (cf. §§770-776).",
                    "Ela nasce do lado aberto de Cristo: água e sangue, Batismo e Eucaristia (cf. §766).",
                    "Ela é una, santa, católica e apostólica: quatro marcas inseparáveis (cf. §§811-813).",
                    "A Igreja não é um clube exclusivo mas povo campo universal (cf. §§846-849).",
                    "Ela é sacramento universal de salvação (cf. §§774-776).",
                    "No Corpo de Cristo vivem também os que ainda não o conhecem plenamente (cf. §848)."
                ]
            },
            {
                "title": "Una, Santa, Católica, Apostólica",
                "paragraphs": [
                    "A unidade da Igreja é dom: um só Senhor, uma fé, um Batismo (cf. §§813-816).",
                    "A santidade é caminho, não troféu: todos os membros são chamados à santidade plena (cf. §§2012-2013).",
                    "Católica quer dizer universal: chamada para todos os povos (cf. §§830-831).",
                    "Apostólica porque construída sobre os Apóstolos e sujeita à sua herança (cf. §857).",
                    "Essa fé apostólica vem do Colégio dos apóstolos e do Sucessor de Pedro hoje (cf. §§880-882).",
                    "Essa Igreja quer dizer: dom contínuo, não posse fechada (cf. §810)."
                ]
            },
            {
                "title": "Comunhão dos santos",
                "paragraphs": [
                    "A comunhão dos santos é a riqueza repartida: as súplicas e as boas obras atravessam estados de vida (cf. §§946-948).",
                    "Tem dois níveis: comunhão das coisas santas e comunhão entre as pessoas santas (cf. §§947-948).",
                    "Para além da morte: o dom de uns alcança os outros (cf. §969).",
                    "A oração pelos mortos é prática da caridade (cf. §958).",
                    "Maria, a Mãe de Deus e da Igreja intercede pelos irmãos (cf. §§963-965).",
                    "Ela também ensina uma obediência de fé melodiosa (cf. §1039)."
                ]
            },
            {
                "title": "Missão e salvação",
                "paragraphs": [
                    "A Igreja sente a natureza missionária: ela nasce para anunciar (cf. §851).",
                    "A evangelização passa pela própria vida: gestos cotidianos contam mais que discursos (cf. §§854-856).",
                    "Os sacramentos são instrumentos do encontro: a Missa é missão (cf. §1120).",
                    "Ninguém é salvo sozinho; a Igreja é a casa comum (cf. §§815-816).",
                    "A justiça social é parte da missão (cf. §§1928-1938).",
                    "O caminho da unidade é também uma tarefa da fé: diálogo entre cristãos (cf. §§820-821)."
                ]
            },
            {
                "title": "A Igreja e o mundo",
                "paragraphs": [
                    "A Igreja não é sinônimo de poder: ela serve o Reino (cf. §§756, 852).",
                    "Ela vive o seu tempo: dialogue com todos os homens de boa vontade (cf. §856).",
                    "A caridade é a raiz de toda a ação: sem ela tudo vira barulho (cf. §§748, 1808).",
                    "Ela também defesa da justiça: quando os pobres são respeitados (cf. §2447).",
                    "Os leigos são protagonistas no mundo: trabalho e família (cf. §§898-900).",
                    "É a mesma história de Cristo, presente em cada época (cf. §748)."
                ]
            },
            {
                "title": "Para aprofundar na semana",
                "paragraphs": [
                    "Primeiro passo: re-ler §§748-761 com uma caneta e uma pergunta concreta.",
                    "Escolher um ato de comunhão na comunidade paroquial (cf. §§946-947).",
                    "Rezar a oração pela Igreja (cf. §851).",
                    "A cuidado dos mais frágeis é critério real (cf. §§2443-2444).",
                    "Ao fim de um dia, listar três «chamados» concretos (cf. §898).",
                    "Terminar a semana com hecete: como está a minha comunhão hoje (cf. §810)?"
                ]
            }
        ]
    },
    "maria-e-o-sim": {
        "title": "Maria e o sim",
        "category": "Maria",
        "description": "Uma leitura introdutória sobre Maria como mulher de fé, mãe e companheira do povo de Deus.",
        "context": "Guia autoral de leitura e reflexão inspirado na estrutura do Catecismo da Igreja Católica.",
        "characters": ["Maria", "Espírito Santo", "Igreja", "Esperança"],
        "chapters": [
            {
                "title": "O sim de Maria",
                "paragraphs": [
                    "Maria aceita o convite de Deus dentro do mistério da encarnação (cf. §§484-489).",
                    "Ela é «cheia de graça»: desde a preparação do plano divino (cf. §490).",
                    "O sim que ela diz, nasce de uma fé larga (cf. §§506-507).",
                    "A gratidão é uma resposta ao dom (cf. §§2605-2606).",
                    "Maria intercede junto ao seu Filho (cf. §§2617-2619).",
                    "Ela é figura e mãe da Igreja (cf. §963)."
                ]
            },
            {
                "title": "Maria na economia da salvação",
                "paragraphs": [
                    "Maria e o Espírito Santo estão unidos no plano da salvação (cf. §721).",
                    "O sim de Maria não é uma passividade: é co-autora do projeto (cf. §511).",
                    "Ela nasceu sem pecado: nova Eva, generosa (cf. §§489-493).",
                    "A fidelidade dela tem cor de espera:ainless (cf. §§2623-2627).",
                    "A «Fiat» de Maria é a porta de tudo (cf. §§2617-2619).",
                    "Maria vigia o povo (cf. §969).",
                ]
            },
            {
                "title": "Maria, Mãe da Igreja",
                "paragraphs": [
                    "Maria se tornou mãe da Igreja (cf. §963).",
                    "Ela precede o povo de Deus em fé, caridade e esperança (cf. §964).",
                    "A Igreja aprende com ela a ser mãe (cf. §963-964).",
                    "A oração a Maria não substitui o culto divino (cf. §971).",
                    "Ela acompanha o povo na oração do Rosário (cf. §971).",
                    "Maria está pronta para dedicar tudo à pessoa, ao cuidado (cf. §975).",
                ]
            },
            {
                "title": "Esperança e perseverança",
                "paragraphs": [
                    "Maria do lado da cruz: dor e gratidão (cf. §618).",
                    "Ela jamais esquece os provisões (cf. §§970-971).",
                    "A esperança cristã origina-se dela (cf. §985).",
                    "O sim é renunciação diária, no rosto (cf. §2843).",
                    "Maria é a Mãe da esperança e da orientação (cf. §975).",
                    "Como Maria, os fiéis caminham em esperança (cf. §2770)."
                ]
            },
            {
                "title": "Para aprofundar na semana",
                "paragraphs": [
                    "Rezar asstore s dos §§484-507 (Ana catequese do Catecismo sobre Maria).",
                    "Rezar uma Ave-Maria devagar todos os dias (cf. §2676).",
                    "Convidar um amigo a rezar a Santa Missa (cf. §2679).",
                    "Registrar uma frase de Maria na própria vida (cf. §963).",
                    "Interceder por alguém no Rosário (cf. §971).",
                    "Terminar a semana com gratidão por tudo (cf. §2605).",
                    ]
            }
        ]
    },
    "conversao-diaria": {
        "title": "Conversão diária",
        "category": "Vida cristã",
        "description": "Pequenos passos para transformar a vida à luz do Evangelho: mudança diária real.",
        "context": "Guia autoral de leitura e reflexão inspirado na estrutura do Catecismo da Igreja Católica.",
        "characters": ["Conversão", "Penitência", "Graça", "Oração"],
        "chapters": [
            {
                "title": "Mudança que começa pequena",
                "paragraphs": [
                    "A conversão não é espetáculo: começa na decisão do próprio dia (cf. §1435).",
                    "O começo vertadeiro nasce do Batismo: morte e ressurreição o cotidiano (cf. §1265).",
                    "Pequenos ajustes, seguidas (cf. §1816).",
                    "A graça não economiza (cf. §1997).",
                    "O silêncio é lá do amigo (cf. §2628).",
                    "Outro passo segue amanhã: a conversa é contínua (cf. §1468)."
                ]
            },
            {
                "title": "Conversão pela graça",
                "paragraphs": [
                    "O Sacramento da Penitência confere a mudança no interior (cf. §§1468-1470).",
                    "A contrição nasce do amor e não apenas da decisão (cf. §1452).",
                    "A absolvição reconduz a comunhão (cf. §§1468-1469).",
                    "O exame da consciência é o passo básico (cf. §1454).",
                    "Cada dia tem espaço para real função (cf. §1435).",
                    "A confiança em Deus é o alicerce da mudança (cf. §1465).",
                ]
            },
            {
                "title": "Conversão o dia inteiro",
                "paragraphs": [
                    "A caridade é nota de velocidade (cf. §1964).",
                    "O trabalho feito bem é um louvor (cf. §2427).",
                    "Chegar ao fim do dia com gratidão (cf. §2637).",
                    "O próximo é o termômetro da conversão (cf. §2447).",
                    "A vigilância do coração é aprendizagem deвсе ingin (cf. §2515).",
                    "Ter-westernize?"
                ]
            },
            {
                "title": "Sacramento para correr e vencer",
                "paragraphs": [
                    "A Reconciliação é socorro programada (cf. §1458).",
                    "A Oração é fôlego da maturidade (cf. §2697-2699).",
                    "Eucaristia leva luz para o caminho (cf. §1210).",
                    "O Batismo joga na chapa (cf. §1265).",
                    "A estreita honestidade virtude (cf. §1805).",
                    "O descanso guarda presença (cf. §2184)." 
                ]
            },
            {
                "title": "Para aprofundar na semana",
                "paragraphs": [
                    "Fazer um exame de consciência diário (cf. §1454).",
                    "Rezar fá saja (cf. §§1435).",
                    "Não fugir do Sacramento da Penitência quando é o passo certo (cf. §1458).",
                    "Rezar a respeito de uma virtude sem espanto (cf. §§1805-1811).",
                    "Escolher uma obra de misericórdia espiritual (cf. §2447).",
                    "Perguntar no fim: criez na conversão de hoje (cf. §1435)?"
                ]
            }
        ]
    },
}

d.update(GUIDES)
p.write_text(json.dumps(d, ensure_ascii=False, indent=2), encoding="utf-8")
print("adicionados: a-igreja-viva, maria-e-o-sim, conversao-diaria")
