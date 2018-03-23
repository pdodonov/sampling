################################################################
### Script para selecionar sítios de estudo a partir de um   ###   
###   conjunto pré-definido                                  ###
################################################################
### Autor: Pavel Dodonov - pdodonov@gmail.com                ###
################################################################
### Laboratório de Ecologia Aplicada à Conservação (LEAC)    ###
### PPG em Ecologia e Conservação da Biodiversidade (PPGECB) ###
### Universidade Estadual de Santa Cruz (UESC)               ###
### Ilhéus - BA - Brasil                                     ###
################################################################
### Copyright: CC BY 3.0 US                                  ###
### https://creativecommons.org/licenses/by/3.0/us/          ###
### Cópias, compartilhamentos e modificações são permitidas, ###
###    contanto que o autor original seja mencionado.        ###
################################################################

### Objetivo: a partir de um conjunto pré-definido de sítios 
###    amostrais, definir um subconjunto de sítios que:
### 1) Respeitem uma distância mínima entre eles;
### 2) Maximizem a variação nos valores de uma variável 
###    explanatória.

### Para isso, criei uma função.
var.diff <- function(x) return(var(diff(sort(x))))
diff.range <- function(x) return(diff(range(x)))



select.site <- function(x, var.site, dist.min, coord.X, coord.Y, var.expl, Nmax, Nsets=10000, Nmin) {
	site.names <- x[,var.site]
	Nsites <- nrow(x)
	sites <- 1:Nsites
	coords <- as.matrix(x[,c(coord.X, coord.Y)])
	dists <- as.matrix(dist(coords))
	dists.allowed <- dists >= dist.min
	sites.rand <- numeric()
	sites.chosen <- list()
	sites.N <- numeric(Nsets)
	X <- x[,var.expl]
	for(j in 1:Nsets) {
		site.foo <- sample(sites, 1)
		site.rand <- site.foo
		#check distances for this site
		dists.allowed.now <- dists.allowed[site.foo,]
		#remove sites that are not allowed
		sites.new <- sites[dists.allowed.now]
		#start the iterations
		repeat {
			# randomize next site
			if(length(sites.new) > 1) {
				site.foo <- sample (sites.new, 1)
			} else site.foo <- sites.new
			site.rand <- c(site.rand, site.foo)
			# check if enough sites had been sampled
			if(length(site.rand) == Nmax) break
			# check distances for the new siterat
			dists.allowed.now <- dists.allowed[site.rand,]
			dists.allowed.now <- apply(dists.allowed.now,2,all)
			sites.new <- sites[dists.allowed.now]
			if(length(sites.new) == 0) break
		}
		sites.chosen[[j]] <- sort(site.rand)
		sites.N[j] <- length(site.rand)
		if(j %% 500 == 0)  print(c(j,sites.N[j]))
	}
	### Agora temos conjuntos de sítios com ao menos dist.min entre eles.
	### Vamos pegar os conjuntos únicos.
	sites.chosen <- unique(sites.chosen)
	### Vamos remover os que têm poucos sítios
	sites.chosen2 <- sites.chosen[unlist(lapply(sites.chosen, length)) >= Nmin]
	### Calculamos duas medidas de variação da variável explanatória:
	###   amplitude e variância das diferenças.
	X.chosen2 <- list()
	for(j in 1:length(sites.chosen2)) {
		X.chosen2[[j]] <- X[sites.chosen2[[j]]]
	}
	ranges <- unlist(lapply(X.chosen2, diff.range))
	vars <- unlist(lapply(X.chosen2, var.diff))
	sites.final <- matrix(ncol=4, nrow=length(sites.chosen2))
	sites.final <- as.data.frame(sites.final)
	names(sites.final) <- c("sitios", "X", "amplitude", "variancia")
	for(j in 1:nrow(sites.final)) {
		ordem <- order(X.chosen2[[j]])
		foo <- paste(site.names[sites.chosen2[[j]]][ordem], collapse=" ")
		sites.final[j,1] <- foo
		foo <- paste(round(X.chosen2[[j]][ordem],2), collapse=" ")
		sites.final[j,2] <- foo
		sites.final[j,3] <- ranges[j]
		sites.final[j,4] <- vars[j]
	}
	return(sites.final)
}

### Para fins de exemplo, vamos trabalhar com dados simulados.
### Simulei as coordenadas para serem mais ou menos parecidas 
###    com coordenadas UTM.
set.seed(17)
Nsitios <- 42 # Número de sítios a serem simulados
sitios <- 1:Nsitios # Identificação dos sítios
coord.X <- runif(Nsitios, min=111000, max=160000)
coord.Y <- runif(Nsitios, min=5440000, max=5540000)
X <- abs(rnorm(42, mean=60, sd=30))
### X é a variável explanatória cuja variação queremos maximizar.
### Juntamos isso tudo num objeto
sitios.tot <- data.frame(sitios, coord.X, coord.Y, X)
### Na prática, usaríamos read.table ou read.csv para abrir 
###    o arquivo com essas informações.
str(sitios.tot)

### Usamos a função criada

sitios.possiveis <- select.site (x=sitios.tot, var.site="sitios", dist.min=5000, coord.X="coord.X", coord.Y="coord.Y", var.expl="X", Nmax=20, Nsets=10000, Nmin=20)

### Ordenando por amplitude e depois variação
sitios.possiveis <- sitios.possiveis[order(sitios.possiveis$amplitude, sitios.possiveis$variancia, decreasing=c(T,F)),]

### Exportando o arquivo
write.table(sitios.possiveis, file="sitios_possiveis_sim.csv", quote=T, sep=",", dec=".", row.names=F, col.names=T)

### Este arquivo .csv (separado por vírgulas) pode ser aberto facilmente no Libre Office e provavelmente no Excel também. Agora é com você, jovem Padawan :-)



