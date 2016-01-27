/* Daniel Gonzalez Alonso
 * Practica 3 AOC - Transformada discreta de Fourier
 */

#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

/* Variables compartidas:
 *  - matriz contendra los valores originales
 *  - matriz_Res contendra los resultados
 *  - max_i contendra el numero de numeros de la matriz
 */
int max_i=1024;
double matriz[1024][2], matriz_Res[1024][2];

// Funcion que imprime el resultado por pantalla
void imprimir_Resultado(){
	int i;
	printf ("Indice |     Numero Original    |          DFT\n");
	for (i=0;i<max_i;i++){
		printf("   %d   | (%lf)+(%lf)i | (%lf)+(%lf)i\n",i+1,matriz[i][0],matriz[i][1],matriz_Res[i][0],matriz_Res[i][1]);
	}
}

int main(void){
	srand(time(NULL));
	int i, j;
	
	// Creamos la matriz original en "matriz" con numeros aleatorios.
	for(i=0;i<max_i;i++){
		for (j=0;j<2;j++){
			matriz[i][j]=((double)rand())/(RAND_MAX);
		}
	}
	
	// relleno de 0's la matriz de los resultados
	for (i=0;i<max_i;i++){
		for (j=0;j<2;j++){
			matriz_Res[i][j]=0;
		}
	}
	
	/* Llamo a la funcion en Ensamblador dftsse que calculara la DFT de los numeros de matriz
	 * y almacenara los resultados en matriz_Res
	 */
	dftsse();
	
	// Imprimo el resultado por pantalla
	printf ("\nTransformada discreta de Fourier en Ensamblador:\n");
	imprimir_Resultado();

	return 0;
}
