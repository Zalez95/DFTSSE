;Daniel Gonzalez Alonso
;Practica 3 AOC

global dftsse
segment .data
	dos	dq 2.0
	
segment .bss
	tmp	resq 1
	tmp_x	resq 1
	tmp_y	resq 1
	cont_1 	resw 1
	cont_2	resw 1
	
segment .text
dftsse:
	extern matriz, matriz_Res, max_i
	
	;Primer Bucle
	mov eax, 0;		pongo a 0 el contador del primer bucle
loop1:
	;Comparo el contador del primer bucle (eax) con el maximo de numeros, si es igual salto a finloop1
	cmp eax, [max_i]
	je finloop1
	
	;Copio el contador del primer bucle (eax) a ecx y lo multiplico por 16, tambien lo almaceno en cont_1
	mov [cont_1], eax
	mov ecx, eax
	imul ecx, 16
	
	;Segundo Bucle
	mov ebx,0;		reinicio el contador del segundo bucle (ebx)
loop2:	
	;Comparo el contador del segundo bucle (ebx) con el maximo de numeros, si es igual salto a finloop2
	cmp ebx, [max_i]
	je finloop2
	
	;Copio el contador del segundo bucle (ebx) a edx y lo multiplico por 16,  tambien lo almaceno en cont_2
	mov [cont_2], ebx
	mov edx, ebx
	imul edx, 16
	
	fild word[cont_1]
	fild word[cont_2];		st0 = cont_2, st1 = cont_1
	fldpi
	fld qword[dos];			st0 = dos, st1 = pi, st2 = cont_2, st3 = cont_1
	fmulp;				st0 = 2*pi, st1 = cont_2, st2 = cont_1
	fmulp;				st0 = 2*pi*cont_2, st1 = cont_1
	fmulp;				st0 = cont_1*cont_2*2*pi
	fild word[max_i];		st0 = max_i, st1 = cont_1*cont_2*2*pi
	fdivp;				hacemos la division st1/st0 (div funciona al reves) de ambos elementos en st1 y hacemos pop
	fst qword[tmp];			almacenamos el resultado en tmp sin hacer pop
	
	;ya tenemos el exponente del numero complejo en tmp
	;aplicamos la formula de euler: e^{i*x} = cos(x) + i*sin(x); siendo x el resultado de la operacion anterior 
	;almacenado en tmp para obtener la parte real y la imaginaria (coordenadas cartesianas).

	fcos
	fstp qword[tmp_x];		guardamos el coseno del resultado de la division en tmp_x (la parte real)
	fld qword[tmp]
	fsin
	fstp qword[tmp_y];		guardamos el seno del resultado de la division en tmp_y (la parte imaginaria)

	;hago la multiplicacion en coordenadas cartesianas. Ejemplo:  (a, b) * (c, d) = (ac - bd, ad + bc)
	movddup xmm0, [matriz+edx];	xmm0 = matriz+edx [parte real | parte real]
	movlpd xmm1, [tmp_y]
	shufpd xmm1, xmm1, 0x01
	movlpd xmm1, [tmp_x];		xmm1 = [tmp_x | tmp_y]
	mulpd xmm0, xmm1;		xmm0 = xmm0*xmm1 (matriz[edx](parte real)*tmp_x | matriz[edx](parte real)*tmp_y)


	movddup xmm1, [matriz+edx+8];	xmm1 = matriz+edx [parte imaginaria | parte imaginaria] ([b|b] en el ejemplo anterior)
	movlpd xmm2, [tmp_x]
	shufpd xmm2, xmm2, 0x01
	movlpd xmm2, [tmp_y];		xmm2 = [tmp_y | tmp_x]
	mulpd xmm1, xmm2;		xmm1 = xmm1*xmm2 (matriz[edx](parte imaginaria)*tmp_y | matriz[edx](parte imaginaria)*tmp_x)
	
	;xmm0 = (matriz[edx](real)*tmp_x - matriz[edx](imaginaria)*tmp_y | matriz[edx](real)*tmp_y + matriz[edx](imaginaria)*tmp_x)
	addsubpd xmm0, xmm1

	;almacenamos xmm0 + [matriz_Res+ecx] en la posicion de la matriz adecuada (la posicion esta determinada por ecx)
	movupd xmm1, [matriz_Res+ecx]
	addpd xmm0, xmm1
	movupd [matriz_Res+ecx], xmm0
	
	inc ebx;			incrementamos el contador del segundo bucle (ebx)
	jmp loop2;			saltamos de nuevo a loop2
	
finloop2:
	inc eax;			incrementamos el contador del primer bucle (eax)
	jmp loop1;			saltamos de nuevo a loop1
finloop1:	
	ret;				retornamos al programa que llamo a la funcion