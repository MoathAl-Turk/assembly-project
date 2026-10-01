org 100h

.data
snakecol db 10,9,8,7, 100 dup(0) 
snakerow db 12,12,12,12, 100 dup(0)
length db 4    
dir db 1    ; 0:Up, 1:Right, 2:Down, 3:Left    
fdc db 15
fdr db 10
score db 0   
fdlistcol db 20, 40, 60, 10, 30
fdlistrow db 5, 10, 15, 20, 7
fdindx  dw 0    
scr db 'score: $'
gameover db ' GAME OVER :( $'
final db ' final score: $'
r db ' press r to restart ;) $'

.code
start:
mov ax,03h   
int 10h 
    
 ;took this from AI i kept getting glitched when restarting the game so i had to clean the screen MANUALLY
 ;{   
mov ax, 0600h  
mov bh, 07h     
mov cx, 0000h   
mov dx, 184Fh 
int 10h    
;}

    ; Reset game data
mov length,4
mov score,0
mov dir,1
mov snakecol[0],10
mov snakecol[1],9
mov snakecol[2],8
mov snakecol[3],7
mov snakerow[0],12
mov snakerow[1],12
mov snakerow[2],12
mov snakerow[3],12
     
     
     
  ; i reduced the row to 23 cause i kept having an issue when drawing the wall the top border kept dissappearing but when i reduced it to 23 it worked
mov ah,2
mov bh,0
mov dx,0
int 10h            
mov ah,2     
mov dl,218 ;=tlc    
int 21h            
   mov cx,78
top: 
    mov dl,196;=-     
    mov ah,2
    int 21h
    loop top
  
mov dl,191;=trc     
mov ah,2
int 21h
mov bl,1   ;counter     
sloop:
      mov ah,2    
      mov dh,bl       
      mov dl,0        
      int 10h   
      mov ah,2     
      mov dl,179;=|    
      int 21h
      mov ah,2     
      mov dh,bl
      mov dl,79       
      int 10h    
      mov ah,2     
      mov dl,179     
      int 21h    
      inc bl          
      cmp bl,23      
      jne sloop 
      
                
  mov ah,2     
  mov dh,23       
  mov dl,0        
  int 10h  
  mov ah,2    
  mov dl,192;=blc     
  int 21h   
  mov cx,78 
  
bottom: 
       mov dl,196     
       mov ah,2
       int 21h
       loop bottom     
       mov dl,217;=brc     
       mov ah,2
       int 21h
    
        
game:
 ;score
mov ah,2
mov bh,0
mov dh,1
mov dl,2
int 10h 
mov dx,offset scr         ;i could use loop to print the string but func 9 is faster by using offset
mov ah,9
int 21h    
mov al,score
add al,48
mov dl,al      
mov ah,2    
int 21h    
    
        
;movinf the snake by getting the coordinates of the tail     
mov ax,0
mov al,length
dec al
mov si,ax
mov dl,snakecol[si] 
mov dh,snakerow[si] 
mov ah,2     
int 10h               
mov ah,2     
mov dl,' '        
int 21h
mov ax,0
mov al,length
dec al
mov si,ax        
L1:
mov al,snakecol[si-1]
mov snakecol[si],al
mov al,snakerow[si-1]
mov snakerow[si],al
dec si
jnz L1
    ;00=get/01h=check
mov ah,01h       
int 16h
jz move  ;if no key was pressed the zero flag is set to 1     
mov ah,00h       
int 16h
cmp al,'a'
je left
cmp al,'s'
je right
jmp move 
 ;i took the logic from AI to know how to move left and right
 ;when turning left dec by 1 and when right inc by 1 => dir
left:
dec dir       
jmp L2
right:
inc dir
L2:
and dir, 3   

move:
mov al,dir
cmp al,0
je hup
cmp al,1
je hright
cmp al,2
je hdown 
               ;if it is 3
dec snakecol[0]      
jmp crash
hup:    
dec snakerow[0]
jmp crash
hright: 
inc snakecol[0]
jmp crash
hdown:  
inc snakerow[0]

crash:
cmp snakecol[0],0
je game_over
cmp snakecol[0],79
je game_over
cmp snakerow[0],0
je game_over
cmp snakerow[0],23
je game_over

mov cx,0
mov cl,length
dec cl          
mov si,1 
selfcrash:
mov al,snakecol[0]
cmp al,snakecol[si]
jne L3
mov al,snakerow[0]
cmp al,snakerow[si]
je game_over
L3:
inc si
loop selfcrash

mov al,snakecol[0]
cmp al,fdc
jne drawfd
mov al,snakerow[0]
cmp al,fdr
jne drawfd
inc score
inc length
call generate_food 

drawfd:
mov dl,fdc 
mov dh,fdr
mov ah,02h    
int 10h  
mov ah,2    
mov dl,'*'   
int 21h
mov cx,0 
mov cl,length
mov si,0 

drawsnake:
mov dl,snakecol[si]
mov dh,snakerow[si]
mov ah,2    
int 10h   
mov dl,'O'     
cmp si,0
jne L4
mov dl,'@'     
L4:
mov ah,2     
int 21h
inc si
loop drawsnake

jmp game     

game_over:
mov ah,2
mov dh,10
mov dl,30
int 10h
mov dx,offset gameover
mov ah,9
int 21h
mov ah,2
mov dh,12
mov dl,30
int 10h
mov dx,offset final
mov ah,9
int 21h
mov al,score
 add al,48
mov dl,al
mov ah,2
int 21h
mov ah, 02h
mov dh, 14
mov dl, 30
int 10h
mov dx, offset r
mov ah, 09h
int 21h

wait_for_key:
mov ah,00h
int 16h
cmp al,'r'
je start        
jmp wait_for_key 
; i didnt know how to to do a random so i did a fixed loop instead/ i think its possible with xor but i cant know how to apply it    
generate_food:
mov di,fdindx             
mov al,fdlistcol[di]  
mov fdc,al               
mov al,fdlistrow[di]    
mov fdr,al                
inc fdindx              
cmp fdindx,5            
jne done_gen
mov fdindx, 0            
done_gen:
    ret
    
end start