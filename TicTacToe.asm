Data segment       
    
    ;variables for GUI    
    heading db "===============",13,10,"| TIC TAC TOE |",13,10,"===============$"          
    board db "     |   |   ",13,10,"  ---+---+---",13,10,"     |   |   ",13,10,"  ---+---+---",13,10,"     |   |   $"      
    labels db "   P1:x P2:o$"
    newline db 13, 10, "$" 
    
    ;variables running the game (core vars)
    turn db 10 dup('$')
    moves db 9 dup(" ")    
    player db 1
    xo db " xo" 
    
    ;variables for different messages
    player_message db "Turn of Player1: $"
    error_message db "Invalid Input! Enter a number from 1 to 9!$"
    error2_message db "Invalid Move! Space already occupied!$"   
    win_message db "Woohoo! PlayerX won!$"
    tie_message db "No one won! Game Tied!$"      
    last_message db "Thanks for playing!$"  
    
Data ends

Code segment  
    
    start:
    
    assume CS:Code,DS:Data
       
    MOV AX, data
    MOV DS, AX     
    MOV SI,0h
    MOV AX,0h
    MOV BX,0h
    MOV CX,0h
               
    ;---------------Main block----------------  
    
    main_block: 
                     
    CALL print_board    
    
    error_block:   
    
    ;printinting layout & taking input 
    LEA DX,newline 
    CALL print
    CALL print   
    LEA DX,player_message 
    CALL print   
    LEA DX,turn       
    CALL user_input
    
    ;error check: len(input)=1
    MOV BL,turn[1]   
    CMP BL,1
    JNE error
    
    ;error check: input>=1
    MOV BL,turn[2]
    SUB BL,30h           
    CMP BL,1h
    JB error 
    
    ;error check: input<=9
    MOV BL,turn[2]
    SUB BL,30h           
    CMP BL,9h
    JA error
    
    ;error check: space already occupied
    DEC BL
    MOV DI,BX   
    CMP moves[DI],20h
    JNE error2
    
    ;marking 'x' or 'o' on board    
    LEA SI,xo
    MOV BL,player 
    MOV AL,[BX+SI]          
    MOV moves[DI],AL
    
    ;checking if any winner
    JMP check_win       
    no_win:
    
    INC CX
    
    ;checking if game tied
    CMP CX,09h 
    JZ tie
    
    ;changing the turn   
    MOV BL,3h
    SUB BL,player
    MOV player,BL
    ADD BL,30h 
    MOV player_message[14],BL  
       
    CALL clear_screen 
      
    JMP main_block  
    
    ;---------Invalid input errors-----------
    
    error:  
    
        LEA DX,newline
        CALL print
        LEA DX,error_message
        CALL print
        JMP error_block
    
    error2:                 
    
        LEA DX,newline
        CALL print
        LEA DX,error2_message
        CALL print
        JMP error_block              
    
    ;---------Mapping board and GUI----------
    
    print_board PROC NEAR  
        
        MOV BL,moves[0]
        MOV board[3],BL
        MOV BL,moves[1]
        MOV board[7],BL
        MOV BL,moves[2]
        MOV board[11],BL
        MOV BL,moves[3]
        MOV board[33],BL
        MOV BL,moves[4]
        MOV board[37],BL
        MOV BL,moves[5]
        MOV board[41],BL
        MOV BL,moves[6]
        MOV board[63],BL
        MOV BL,moves[7]
        MOV board[67],BL
        MOV BL,moves[8]
        MOV board[71],BL 
        LEA DX,heading
        call print 
        LEA DX,newline
        call print
        call print
        LEA DX,board
        call print
        LEA DX,newline
        call print
        call print
        LEA DX,labels
        call print                   
        RET     
        
    print_board ENDP
                       
    ;------Basic repetitive operations------
    
    user_input PROC NEAR 
        
        MOV AH, 0Ah            
        INT 21h
        RET          
        
    user_input ENDP
    
    clear_screen PROC NEAR 
        
        MOV AH,0Fh
        INT 10h     
        MOV AH,0h
        INT 10h    
        RET       
        
    clear_screen ENDP
    
    print PROC NEAR 
               
        MOV AH,09h
        INT 21h       
        RET      
        
    print ENDP 
    
    ;----------Winning conditions------------    
    
    check_win:    
        
        ;checking row1
        MOV BL,moves[0]
        CMP BL,20h
        JZ check_win2
        CMP BL,moves[1]
        JNZ check_win2
        CMP BL,moves[2]
        JNZ check_win2
        JMP win
    
    check_win2: 
        
        ;checking row2
        MOV BL,moves[3]
        CMP BL,20h
        JZ check_win3
        CMP BL,moves[4]
        JNZ check_win3
        CMP BL,moves[5]
        JNZ check_win3
        JMP win
    
    check_win3: 
        
        ;checking row3
        MOV BL,moves[6]
        CMP BL,20h
        JZ check_win4
        CMP BL,moves[7]
        JNZ check_win4
        CMP BL,moves[8]
        JNZ check_win4
        JMP win
    
    check_win4:  
        
        ;checking col1
        MOV BL,moves[0]
        CMP BL,20h
        JZ check_win5
        CMP BL,moves[3]
        JNZ check_win5
        CMP BL,moves[6]
        JNZ check_win5
        JMP win
    
    check_win5: 
       
        ;checking col2
        MOV BL,moves[1] 
        CMP BL,20h
        JZ check_win6
        CMP BL,moves[4]
        JNZ check_win6
        CMP BL,moves[7]
        JNZ check_win6
        JMP win
    
    check_win6:
        
        ;checking col3
        MOV BL,moves[2]
        CMP BL,20h
        JZ check_win7
        CMP BL,moves[5]
        JNZ check_win7
        CMP BL,moves[8]
        JNZ check_win7
        JMP win
        RET
    
    check_win7: 
        
        ;checking diag1
        MOV BL,moves[0]
        CMP BL,20h
        JZ check_win8
        CMP BL,moves[4]
        JNZ check_win8
        CMP BL,moves[8]
        JNZ check_win8
        JMP win 
        
    check_win8: 
        
        ;checking diag2
        MOV BL,moves[2]
        CMP BL,20h
        JZ no_win
        CMP BL,moves[4]    
        JNZ no_win
        CMP BL,moves[6]
        JNZ no_win
        JMP win
    
    ;----------Game ending conditions-----------
    
    win PROC NEAR     
        
        LEA DX,newline
        CALL print
        CALL clear_screen                  
        CALL print_board    
        LEA DX,newline 
        CALL print
        CALL print
        MOV BL,player
        ADD BL,30h
        MOV win_message[14],BL
        LEA DX,win_message
        CALL print      
        CALL last     
        
    win ENDP
       
    tie PROC NEAR  
        
        LEA DX,newline   
        CALL print
        CALL clear_screen                  
        CALL print_board    
        LEA DX,newline 
        CALL print
        CALL print
        LEA DX,tie_message
        CALL print
        CALL last    
        
    tie ENDP       
    
    last PROC NEAR     
        
        LEA DX,newline 
        CALL print
        CALL print
        LEA DX,last_message
        CALL print   
        
    last ENDP        
            
Code ends
end start