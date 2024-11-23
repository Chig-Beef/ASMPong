	extern printf
	extern ExitProcess
	extern InitWindow
	extern CloseWindow
	extern SetTraceLogLevel
	extern IsKeyDown
	extern ClearBackground
	extern BeginDrawing
	extern EndDrawing
	extern DrawRectangle
	extern DrawCircle
	extern WindowShouldClose
	extern SetTargetFPS

	global start

section .data								; Constant data

	startingText:		db 'Starting', 10, 0; To signify the start of the program
	finishedText:		db 'Finshed', 10, 0	; To signify the end of the program
	pong_message		db 'Pong', 0

section .text								; Commands

start:
	sub		rsp, 8							; Align stack

	mov		rcx, startingText
	call	printf							; printf("starting");

	; CREATE VARS ;
	sub		rsp, 16							; Player 1
	mov		rdx, rsp						; Save the pointer to p1
	sub		rsp, 16							; Player 2
	mov		r8, rsp							; Save the pointer to p2
	sub		rsp, 20							; Ball
	mov		rcx, rsp						; Save the pointer to ball
	sub		rsp, 12							; Align the stack
	; CREATE VARS ;

	; INIT BALL ;
	mov		dword [rcx], 640				; ball.x = 640;
	mov		dword [rcx+4], 360				; ball.y = 360;
	mov		dword [rcx+8], 10				; ball.r = 10;
	mov		dword [rcx+12], 1				; ball.dx = 1;
	mov		dword [rcx+16], 1				; ball.dy = 1;
	; INIT BALL ;

	; INIT P1 ;
	mov		dword [rdx], 10					; p1.x = 10;
	mov		dword [rdx+4], 10				; p1.y = 10;
	mov		dword [rdx+8], 50				; p1.w = 50;
	mov		dword [rdx+12], 100				; p1.h = 100;
	; INIT P1 ;

	; INIT P2 ;
	mov		dword [r8], 1220				; p2.x = 1220;
	mov		dword [r8+4], 10				; p2.y = 10;
	mov		dword [r8+8], 50				; p2.w = 50;
	mov		dword [r8+12], 100				; p2.h = 100;
	; INIT P2 ;

	; Save Vars ;
	push	rcx
	push	rdx
	push	r8
	sub		rsp, 8
	; Save Vars ;

	; Set FPS
	mov	rcx, 60
	call	SetTargetFPS					; SetTargetFPS(60);

	; Init window
	mov	rcx, 1280
	mov	rdx, 720
	mov	r8, pong_message
	call	InitWindow						; InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Pong")'

	; GAME LOOP ; Currently, p2 is at rsp+8, p1 is at rsp+16, ball is at rsp+24
gameLoop:

	; UPDATE ;

	; MOVE PLAYER 1 ;
	mov		rcx, 83							; KEY_S
	call	IsKeyDown
	cmp		al, 0
	je		noSKey							; if IsKeyDown(KEY_S) {
	mov		r8, [rsp+16]					;	// Load in p1
	mov		eax, [r8+4]
	add		eax, 2							;	p1.y += 2;
	mov		[r8+4], eax
noSKey:										; }
	mov		rcx, 87							; KEY_W
	call	IsKeyDown
	cmp		al, 0
	je		noWKey							; if IsKeyDown(KEY_W) {
	mov		r8, [rsp+16]					;	// Load in p1
	mov		eax, [r8+4]
	sub		eax, 2							;	p1.y -= 2;
	mov		[r8+4], eax
noWKey:										; }
	; MOVE PLAYER 1 ;

	; MOVE PLAYER 2 ;
	mov		rcx, 264						; KEY_DOWN
	call	IsKeyDown
	cmp		al, 0
	je		noDownKey						; if IsKeyDown(KEY_DOWN) {
	mov		r8, [rsp+8]						;	// Load in p2
	mov		eax, [r8+4]
	add		eax, 2							;	p2.y += 2;
	mov		[r8+4], eax
noDownKey:									; }
	mov		rcx, 265						; KEY_UP
	call	IsKeyDown
	cmp		al, 0
	je		noUpKey							; if IsKeyDown(KEY_UP) {
	mov		r8, [rsp+8]						;	// Load in p2
	mov		eax, [r8+4]
	sub		eax, 2							;	p2.y -= 2;
	mov		[r8+4], eax
noUpKey:									; }
	; MOVE PLAYER 2 ;

	; MOVE BALL ;
	mov		rcx, [rsp+24]					; Load in ball pointer

	mov		r11d, [rcx]						; r11 = b.x
	mov		r10d, [rcx+12]					; r10 = b.dx
	add		r11d, r10d						; b.x += b.dx
	mov		[rcx], r11d						; b.x = r11

	mov		r11d, [rcx+4]					; r11 = b.y
	mov		r10d, [rcx+16]					; r10 = b.dy
	add		r11d, r10d						; b.y += b.dy
	mov		[rcx+4], r11d					; b.y = r11
	; MOVE BALL ;

	; BALL COLLISION WITH SIDES ;
	cmp		r11d, 720
	jng		noBottomCollision				; if b.y > 720 {
	mov		dword [rcx+16], -1				;	b.dy = -1;
noBottomCollision:							; }

	cmp		r11d, 0
	jnl		noTopCollision					; if b.y < 0 {
	mov		dword [rcx+16], 1				;	b.dy = -1
noTopCollision:								; }

	mov		r11d, [rcx]						; Load in b.x

	cmp		r11d, 0
	jnl		noLeftCollision					; if b.x < 0 {
	mov		dword [rcx], 640				;	b.x = 640;
	mov		dword [rcx+4], 360				;	b.y = 360;
noLeftCollision:							; }

	cmp		r11d, 1280
	jng		noRightCollision				; if b.x > 1280 {
	mov		dword [rcx], 640				;	b.x = 640;
	mov		dword [rcx+4], 360				;	b.y = 360;
noRightCollision:							; }
	; BALL COLLISION WITH SIDES ;

	; PLAYER ONE BALL COLLISION ;
	mov		rdx, [rsp+16]					; Load in player 1
	mov		rcx, [rsp+24]					; Load in ball
	mov		r11d, [rcx]						; Load in ball.x
	mov		r10d, [rcx+4]					; Load in ball.y
	mov		r9d, [rdx]						; Load in p1.x
	cmp		r9d, r11d
	jg		noPlayerOneCollision			; if p1.x < b.x
	add		r9d, [rdx+8]
	cmp		r9d, r11d
	jl		noPlayerOneCollision			;	&& p1.x+p1.w > b.x
	mov		r9d, [rdx+4]
	cmp		r9d, r10d
	jg		noPlayerOneCollision			;	&& p1.y < b.y
	add		r9d, [rdx+12]
	cmp		r9d, r10d
	jl		noPlayerOneCollision			;	&& p1.y+p1.h > b.y {
	mov		dword [rcx+12], 1				;	b.dx = 1;
noPlayerOneCollision:						; }
	; PLAYER ONE BALL COLLISION ;

	; PLAYER TWO BALL COLLISION ;
	mov		r8, [rsp+8]						; Load in player 2 (ball is already loaded in
	mov		r9d, [r8]						; Load in p2.x
	cmp		r9d, r11d
	jg		noPlayerTwoCollision
	add		r9d, [r8+8]
	cmp		r9d, r11d
	jl		noPlayerTwoCollision
	mov		r9d, [r8+4]
	cmp		r9d, r10d
	jg		noPlayerTwoCollision
	add		r9d, [r8+12]
	cmp		r9d, r10d
	jl		noPlayerTwoCollision
	mov		dword [rcx+12], -1
noPlayerTwoCollision:
	; PLAYER TWO BALL COLLISION ;

	; UPDATE ;

	; DRAW ;
	call	BeginDrawing

	; Clear
	mov		rcx, 0xFF000000					; BLACK = 0, 0, 0, 255 (yeah, it's backwards)
	call	ClearBackground					; ClearBackground(BLACK);

	; Draw p1
	mov		rax, [rsp+16]					; Load p1 into rax
	mov		r9, 0xFFFFFFFFFFFFFFFF			; Place in colour argument
	push	r9
	push	r9
	push	r9
	push	r9
	push	r9
	push	r9
	mov		ecx, [rax]						; Load p1's rectangle into the correct registers
	mov		edx, [rax+4]
	mov		r8d, [rax+8]
	mov		r9d, [rax+12]
	call	DrawRectangle					; DrawRectangle(p1.x, p1.y, p1.w, p1.h, WHITE);
	pop		r9								; Take off colour argument
	pop		r9
	pop		r9
	pop		r9
	pop		r9
	pop		r9

	; Draw p2
	mov		rax, [rsp+8]					; Load p2 into rax
	mov		r9, 0xFFFFFFFFFFFFFFFF			; Place in colour argument
	push	r9
	push	r9
	push	r9
	push	r9
	push	r9
	push	r9
	mov		ecx, [rax]						; Load p2's rectangle into the correct registers
	mov		edx, [rax+4]
	mov		r8d, [rax+8]
	mov		r9d, [rax+12]
	call	DrawRectangle					; DrawRectangle(p2.x, p2.y, p2.w, p2.h, WHITE);
	pop		r9								; Take off colour argument
	pop		r9
	pop		r9
	pop		r9
	pop		r9
	pop		r9

	; Draw ball
	mov		r10, [rsp+24]
	mov		rcx, [r10]
	mov		rdx, [r10+4]
	mov		r8, 0xFFFFFFFFFFFFFFFF
	cvtsi2ss xmm2, [r10+8]
	call	DrawCircle						; DrawCircle(b.x, b.y, b.r, BALL_COLOR);

	call	EndDrawing
	; DRAW ;

	call	WindowShouldClose				; while (!WindowShouldClose()) {
	cmp		al, 0							;	gameLoop();
	je		gameLoop						; }
	; GAME LOOP ;

	; Close window
	call	CloseWindow

	; Delete saved vars ;
	sub		rsp, 32
	; Delete saved vars ;

	; DELETE VARS
	add		rsp, 12							; Take off padding
	add		rsp, 20							; Deallocate the ball
	add		rsp, 16							; Deallocate p2
	add		rsp, 16							; Deallocate p1
	; DELETE VARS

	mov		rcx, finishedText
	call	printf							; printf("finished");

	xor		rax, rax
	call	ExitProcess
