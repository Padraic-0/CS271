TITLE Program Proj5_berginp     (Proj5_berginp.asm)

; Author: Padraic Bergin
; Last Modified: May 23
; OSU email address: berginp@oregonstate.edu
; Course number/section:   CS271 Section 001
; Project Number: 5                Due Date: May 22
; Description: This program creates an array of random values within a range. It is then sorted, median displayed.
;				Then the instances of each value is given.

INCLUDE Irvine32.inc

; (insert macro definitions here)

; (insert constant definitions here)
LO = 15
HI = 50
ARRAYSIZE = 200
LINELIM = 20

.data
	greeting BYTE "Welcome to my array sorting program by Padraic Bergin",0
	greet2 BYTE "This program generates 200 random integars between [15 ... 50]",0
	greet3 BYTE "The original list, sorted list, median value, and instances will be displayed",0
	prompt_unsort BYTE "Your unsorted random numbers:",0
	prompt_sort BYTE "Your sorted random numbers:",0
	prompt_count BYTE "List of instances of each generated number",0
	prompt_median BYTE "The median number of the array: ",0
	goodbye BYTE "Goodbye!",0


	randArray DWORD ARRAYSIZE DUP(0)
	instanceArray DWORD HI-LO+1 DUP(0)
	space BYTE " ",0


; (insert variable definitions here)

.code
;Name: introduction
;Displays program name, my name, and program discription
introduction PROC
	push EBP
	mov ebp, esp
	mov edx, [ebp + 16]
	call WriteString
	call CrLf
	mov edx, [ebp + 12]
	call WriteString
	call CrLf
	mov edx, [ebp + 8]
	call WriteString
	call CrLf
	pop ebp
	ret 12
introduction ENDP

;Name: fillArray
; takes array, and array size
; creates random int between global range, fills each index of the array
fillArray PROC
	PUSH EBP
	mov ebp, esp
	push eax
	push ecx
	push edi

	mov ecx, [ebp+8]
	mov edi, [ebp+12]
	_filling:															;mov [edi+ value to next element(DWORD so 4)], eax
		mov eax, HI - LO + 1
		call RandomRange
		ADD eax, LO
		;call WriteDec
		;call CrLf
		MOV [EDI], EAX
		ADD EDI, 4
		LOOP _filling
	POP edi
	pop ecx
	pop eax
	pop ebp
	ret 8
fillArray ENDP

;Name: printArray
;takes array, array size, and text to display
;displays text, runs loops printing values of the array
printArray PROC
	PUSH EBP
	mov ebp, esp
	push eax
	push ecx
	push edi

	mov ecx, [ebp+8]
	mov edi, [ebp+12]
	mov edx, [ebp+16]
	call CrLf
	call WriteString
	call CrLf
	mov ebx, 0
	_printing:		;mov [edi+ value to next element(DWORD so 4)], eax
		inc ebx
		mov eax, [EDI]
		call WriteDec
		push eax
		mov eax, 32
		call WriteChar
		pop eax
		cmp ebx, LINELIM
		jl skip
		call CrLf
		mov ebx, 0
		skip:
		ADD EDI, 4
		LOOP _printing
	POP edi
	pop ecx
	pop eax
	pop ebp
	ret 12
printArray ENDP

;Name: sortArray
;takes array and size of array
;runs sorting loop, swaping lowest value to front of array
sortArray PROC
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8] ;array
	mov ecx, [ebp + 12] ;arraysize
	;index to replace will be arraysize-ecx * 4
	
	_sort:
		mov ebx, HI
		push ecx
		push edi
		_find_smallest:
		mov eax, [edi]
		cmp eax, ebx
		jg skip
		_store_edi:
			mov edx, edi
			mov ebx, [edi]
		skip:
		add edi, 4
		LOOP _find_smallest
	pop edi
	push [edi]
	push edi
	
	;mov [edi],[edx]
	mov eax, [edx]
	mov [edi], eax
	pop edi
	;mov [edx],[edi]
	pop eax
	mov [edx], eax
	add edi, 4
	pop ecx
	LOOP _sort
	pop ebp
	ret 8
sortArray ENDP

;Name: exchangeElements
;takes array, and two indexs to be swapped
;swaps the indexs
exchangeElements PROC
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8] ;array
	mov eax, [ebp + 12]
	mov edx, [ebp + 16]

	xchg eax,[edx]

	pop ebp
	ret 8
exchangeElements ENDP

;Name: countList
;takes main array and subarray
;totals the amount of each int, saves into the subarray

countList PROC
	push ebp
	mov ebp, esp
	push esi ; preserve esi
	mov edi, [ebp + 8] ;randArray
	mov esi, [ebp + 12] ;instanceArray

	mov ecx, ARRAYSIZE
	mov eax, LO
	mov ebx, 0
	_count:
		mov edx, [edi]
		cmp eax, [edi]
		jne _next
		inc ebx
		jmp _bottom
		_next:
			
			mov [esi], ebx ;mov counted value into array
			mov ebx, 0
			add esi, 4
			inc eax
			jmp _count

	_bottom:
	add edi, 4
	LOOP _count
	mov [esi], ebx ;mov last value
	mov eax, [esi]
	pop esi
	pop ebp
	ret 8
countList ENDP

;Name: displayMedian
;takes a array as a parameter, and prompt
;Uses global ARRAYSIZE to find and print median
displayMedian PROC
	push ebp
	mov ebp, esp
	mov edi, [ebp + 8] ;randArray
	mov edx, [ebp + 12] ;prompt

	call CrLf
	call WriteString
	
	mov eax, ARRAYSIZE		;median will be half way through array
	mov ebx, 2
	mul ebx		
	add edi, eax
	mov eax, [EDI-4]

	call WriteDec
	call CrLf
		

	pop ebp
	ret 8
displayMedian ENDP

farewell PROC
	push ebp
	mov ebp, esp
	mov edx, [ebp + 8]
	call CrLf
	call WriteString
	pop ebp
	ret 4
farewell ENDP

main PROC

; (insert executable instructions here)
	call Randomize ;creates seed

	push OFFSET greeting
	push OFFSET greet2
	push OFFSET greet3
	call introduction ;introduction
	
	push OFFSET randArray
	push ARRAYSIZE
	call fillArray

	push OFFSET prompt_unsort
	push OFFSET randArray
	push ARRAYSIZE
	call printArray

	push ARRAYSIZE
	push OFFSET randArray
	call sortArray

	push OFFSET prompt_sort
	push OFFSET randArray
	push ARRAYSIZE
	call printArray

	push OFFSET instanceArray
	push OFFSET randArray
	call countList

	push OFFSET prompt_count
	push OFFSET instanceArray
	push HI-LO+1
	call printArray

	push OFFSET prompt_median
	push OFFSET randArray
	call displayMedian

	push OFFSET goodbye
	call farewell



	
	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
