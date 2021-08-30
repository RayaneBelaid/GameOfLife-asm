#
# automate.s ... on a 10 x 10 grid
# problème de croissance de cellules
# dans un espace limité
#

      .data

N:    .word 10  # nombre de lignes de la grille
M:    .word 10  # nombre de colonnes de la grille

iter: .word 4   # nombre d'iterations

grid:           # grille de cellules
      .byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
      .byte 1, 1, 0, 0, 0, 0, 0, 0, 0, 0
      .byte 0, 0, 0, 1, 0, 0, 0, 0, 0, 0
      .byte 0, 0, 1, 0, 1, 0, 0, 0, 0, 0
      .byte 0, 0, 0, 0, 1, 0, 0, 0, 0, 0
      .byte 0, 0, 0, 0, 1, 1, 1, 0, 0, 0
      .byte 0, 0, 0, 1, 0, 0, 1, 0, 0, 0
      .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
      .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
      .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0

othergrid: .space 100

#
# Si vous avez d'autres déclarations que vous voulez 
# inclure et utiliser dans le programme mettez les 
# en dessous entre les marqueurs indiqués
#
# VOS_DECLARATIONS_COMMENCENT_ICI

############ La designation des registres dans le code principal en se basant sur le code en java #################
#t0 : nombre d'iterations
#t1 : compteur de la boucle principale du programme
#t2 : M
#t3 : l: compteur des lignes, [0,M-1]
#t4 : N
#t5 : m: compteur des colonnes, [0,N-1]
#t6 : aliveNeighbours
#t7 : valeur max des indices des voisins (2)
#t8 : compteur de "i", [-1,1]
#t9 : valeur max des indices des voisins (2)
#s0 : compteur de "j", [-1,1]
#s1 : l + i
#s2 : m + j
#s3 : (l+i)*N
#s4 : (l+i)*N + (m+j)
#s6 : grid[l + i][m + j]
#at : grid[l][m]
#k0 : size
#a0 : pointeur vers le debut de la grille
#a1 : grid[l+i][m+j], pointeur qui permet de se balader dans la grille pour lire ou ecrire des valeurs
#a2 : pointeur vers le debut de la nouvelle grille
#a3 : othergrid[l][m], pointeur qui permet de se balader dans la nouvelle grille pour lire ou ecrire des valeurs
#s0, s1, s2 = free

size: .word 100
msg1: .asciiz  "Le nombre d iterations est: 4"
msg2: .asciiz  "Debut d une nouvelle generation"
msg3: .asciiz  "\n-------------- La grille finale ---------------\n"
NL: .asciiz "\n"
Ldix:   .byte 0x0a  # 2 for mod usage
# VOS_DECLARATIONS_FINISSENT_ICI

      .text
      .globl main


main:

# LE_CODE_COMMENCE_ICI

            #  Main loop body  #
########### the iterations loop #############
   li $v0, 4    # afficher le message "msg1"
   la $a0, msg1
   syscall
   
   li $v0, 4 # passer a une nouvelle ligne
   la $a0, NL 
   syscall

############## Début de la boucle principale (1/5) ######################
lw $t0, iter  # initialiser t0 a la valeur stockee dans "iter"
li $t1, 0   # t1 compteur d'iterations (generations)
start_for1:
   # Print msg2
   li $v0, 4  # afficher le message "msg2"
   la $a0, msg2
   syscall

   li $v0, 4 # passer a une nouvelel ligne
   la $a0, NL 
   syscall

   # Reinitialiser a0 pour ne pas perdre l adresse de "grid"
   la $a0, grid # recuperer l adresse de la grille dans un registre. a0 est initialisee a l adresse de la grille
   la $a2, othergrid # recuperer l adresse de la nouvelle grille dans un registre. a2 est initialisee a l adresse de la nouvelle grille

   ############## Début de la deuxieme boucle du programme (2/5) ######################
   lw $t2, M # initialiser t2 a la valeur stockee dans "M"
   li $t3, 0 # t3: compteur de la boucle de "l", de 0 a M-1
   start_for2:
      ############## Début de la troisieme boucle du programme (3/5) ######################
      lw $t4, N # initialiser t4 a la valeur stockee dans "N"
      li $t5, 0 # t5: compteur de la boucle de "m", de 0 a N-1
      start_for3:

         li $t6, 0 # initialiser le nombre de voisins a 0
         ############## Début de la quatrieme boucle du programme (4/5) ######################
         li $t7, 2 # initialiser t7 a 2
         li $t8, -1 # t8: compteur de la boucle de "i", de -1 a 1
         start_for4:
            ############## Début de la cinquieme boucle du programme (5/5) ######################
            li $t9, 2 # initialiser t9 a 2
            li $s0, -1 # s0: compteur de la boucle de "j", de -1 a 1
            start_for5:
               add $s1, $t3, $t8 # s1 = l + i
               add $s2, $t5, $s0 # s2 = m + j
               
               bltz $s1, end_for5 # l + i >= 0. Si l+i<0 ==> fin
               beq $s1, $t2 end_for5 # l + i < M. Si l+i == M ==> fin
               bltz $s2, end_for5 # m + j >= 0. Si m+j<0 ==> fin
               beq $s2, $t4, end_for5 # m + j < N. Si m+j == N ==> fin
               # on est bien dans l'un des voisins de la case courante, donc on met a jour le nombre de voisins
               # convertir l adresse dans la grille (i,j) en une adresse en memoire (p)
               # formule: p = i*nb_colonnes + j
               mul $s3, $s1, $t4 # s3 = (l+i)*N
               add $s4, $s3, $s2 # s4 = (l+i)*N + (m+j)
               add $a1, $a0, $s4 # preparer l adresse d ou on va lire, grid[l + i][m + j]
               lb $s6, 0($a1) # s6 = grid[l + i][m + j]
               add $t6, $t6, $s6 # aliveNeighbours += grid[l + i][m + j]

               # aliveNeighbours -= grid[l][m]
               mul $s3, $t3, $t4 # s3 = l*N
               add $s4, $s3, $t5 # s4 = l*N + m
               add $a1, $a0, $s4 # preparer l adresse d ou on va lire (grille[l][m])
               add $a3, $a2, $s4 # preparer l adresse ou on va ecrire (othergrid[l][m])
               lb $s6, 0($a1) # s6 = grid[l][m]
               sub $t6, $t6, $s6 # aliveNeighbours -= grid[l][m]

               # etudier les differentes valeurs du nombre de voisins
               blt $t6, 2, cellule_meurt # aliveNeighbours < 2 ==> la cellule meurt
               bgt $t6, 3, cellule_meurt # aliveNeighbours > 3 ==> la cellule meurt
               beq $t6, 3, cellule_nait # aliveNeighbours == 3 ==> la cellule nait
               # sinon: la cellue est stable
               cellue_stable:
                  lb $at, 0($a1) # at = grid[l][m]
                  sb $at, 0($a3) # future[l][m] = at (future[l][m] = grid[l][m])
                  j end_for5
               cellule_meurt:
                  sb $zero, 0($a3) # future[l][m] = 0
                  j end_for5
               cellule_nait:
                  li $s7, 1 # s6 = 1
                  sb $s7, 0($a3) # future[l][m] = 1
                  j end_for5

            end_for5:
            addi $s0, $s0, 1 # incrementer le compteur s0 par 1 pour aller a un nouveau voisin
            beq $s0, $t9, end_for4 # si $s0 == 2, on est arrive au dernier voisin en bas a droite. Aller a une nouvelle case
            j start_for5 # aller a la prochaine iteration (nouveau voisin)
            ################ Fin de la cinquieme boucle du programme (5/5) ######################
         end_for4:
         addi $t8, $t8, 1 # incrementer le compteur t8 par 1 pour aller a un nouveau voisin
         beq $t8, $t7, end_for3 # si $t8 == 2, on est arrive au dernier voisin en bas. Aller a une nouvelle case
         j start_for4 # aller a la prochaine iteration (nouvelle voisin)
         ################ Fin de la quatrieme boucle du programme (4/5) ######################
      end_for3:
      addi $t5, $t5, 1 # incrementer le compteur t5 par 1 pour aller a la prochaine colonne
      beq $t5, $t4, end_for2 # si $t5 == N, on est arrive a la derniere colonne. Aller a la prochaine ligne
      j start_for3 # aller a la prochaine iteration (colonne)
      ################ Fin de la troisieme boucle du programme (3/5) ######################
   end_for2:
   addi $t3, $t3, 1 # incrementer le compteur t3 par 1 pour aller a la prochaine ligne
   beq $t3, $t2, end_for1 # si $t3 == M, on a fini le parcours de la grille. Aller a la prochaine iteration
   j start_for2 # aller a la prochaine iteration (ligne)
   ############### Fin de la deuxieme boucle du programme (2/5) #######################

end_for1:
addi $t1, $t1, 1 # incrementer le compteur t1 par 1, i.e aller a la prochaine iteration (generation)
beq $t1, $t0, afficher_grille_finale  # (si t1 == 4) on a fini le programme. On doit s'arreter
############# copier la nouvelle grille dans l originale pour commencer une nouvelle iteration ############
la $a1, grid # recuperer l adresse de la grille dans un registre. a0 est initialisee a l adresse de la grille
la $a3, othergrid  # recuperer l adresse de la nouvelle grille dans un registre. a2 est initialisee a l adresse de la nouvelle grille
lw $s5, size # charger la valeur de "size" dans "s5"
add $s3, $a3, $s5 # definir la derniere adresse de la grille ou on va ecrire
copy_loop:
    lb $at, 0($a1) # at = grid[a1]
    sb $at, 0($a3) # othergrid[a3] = at

    addi $a1, $a1, 1
    addi $a3, $a3, 1

    blt $a3, $s3, copy_loop # if load pointer < src_array + 30*4
###########################################################################################################
j start_for1 # jump back to the principal loop
############## Fin de la boucle principale (1/5) ##########################

################################## Affichage de la grille finale ##############################################
afficher_grille_finale:

li $v0, 4    # afficher le message "msg3"
   la $a0, msg3
   syscall

   lw $k0, size
   la $t1, othergrid # get array address
   li $t2, 0 # set loop counter
   lb $t3, Ldix        # t3 = 10

   nouvelle_ligne:
         li $v0, 4 # passer a une nouvelel ligne
         la $a0, NL 
         syscall
         j continuer

   boucle_affichage:
      lb $t0, 0($t1)

      li $v0, 1
      move $a0, $t0
      syscall

      addi $t1, $t1, 1
      addi $t2, $t2, 1

      # si on arrive a la fin de la ligne, on passe au debut de la ligne suivante
      move $t4, $t2 # t4 = t2
      div $t4, $t3  # t4 mod 10
      mfhi $t6      # le resultat de "mod" se trouve dans un registre temporaire
      beq $t6, 0, nouvelle_ligne # if mod == 0, passer a la nouvelle ligne

      continuer:
         bne $t2, $k0, boucle_affichage

###############################################################################################################

# LE_CODE_FINI_ICI
end_program:   
   li $v0, 10       # exit code service 
   syscall          # for syscall

