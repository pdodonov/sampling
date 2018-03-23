Partindo de um conjunto de sítios pré-definidos, para os quais temos
as coordenadas e o valor da variável explanatória de principal
interesse (tipo cobertura florestal), o algoritmo faz o seguinte:

1) Escolhe N sítios aleatórios (até o número máximo de sítios definido
pela pessoa) com ao menos X metros entre eles (distância mínima também
definida pela pessoa)
2) Repete este procedimento um número bem grande de vezes, criando M
conjuntos de sítios aleatórios, e exclui os que estiverem repetidos.
3) Agora o objetivo é maximizar a variação na variável explanatória.
Para isso, queremos i) que haja uma boa amplitude de variação (ou
seja, coberturas variando de 8 a 90% é melhor que variando de 20 a
70%) e ii) que haja uma boa distribuição de valores (ou seja,
coberturas de 8, 14, 20, 28, 36, 42, 50% é melhor do que coberturas de
8, 22, 36, 38, 40, 42, 55% - neste último temos muitos valores
concentrados no centro e o ajuste nas pontas fica pior). Para isso, o
algoritmo calcula a amplitude de variação e a variância das diferenças
entre os pontos ordenados.
4) Ordenar os conjuntos de sítios por i) maior amplitude de variação e
ii) menor variância nas diferenças (distribuição mais homogênea)
5) Salva isso num arquivo .csv, permitindo que vc escolha qual
conjunto de sítios usar.