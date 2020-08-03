PRO tree_counting_final
   filters = ['*.jpg', '*.tif', '*.png'] 
   file = DIALOG_PICKFILE(/READ, FILTER = filters)   
        M = READ_IMAGE(file)     ; ORIGINAL IMAGE   
        Info = SIZE(M)   
              ROW = Info[1]
              COL = Info[2] 
              X = make_array(5,5) 
              fil = MAKE_ARRAY(ROW,COL)
              FOR I = 0,ROW-5 DO BEGIN      
                  FOR J = 0, COL-5 DO BEGIN     
                       X = [[M[I,J],M[I,J+1],M[I,J+2],M[I,J+3],M[I,J+4]],[M[I+1,J], $
                           M[I+1,J+1], M[I+1,J+2], M[I+1,J+3],M[I+1,J+4]], [M[I+2,J], M[I+2,J+1],$
                           M[I+2,J+2],M[I+2,J+3], M[I+2,J+4]], [M[I+3,J], M[I+3,J+1], M[I+3,J+2],  $
                           M[I+3,J+3], M[I+3,J+4]], [M[I+4,J],  M[I+4,J+1], M[I+4,J+2], M[I+4,J+3], M[I+4,J+4]]]
                     
                       fil[I+2,J+2] = (X[0,0]/25+X[0,1]/25+X[0,2]/25+X[0,3]/25+X[0,4]/25$
                                    +X[1,0]/25+X[1,1]/25+X[1,2]/25+X[1,3]/25+X[1,4]/25$
                                    +X[2,0]/25+X[2,1]/25+X[2,2]/25+X[2,3]/25+X[2,4]/25$
                                    +X[3,0]/25+X[3,1]/25+X[3,2]/25+X[3,3]/25+X[3,4]/25$
                                    +X[4,0]/25+X[4,1]/25+X[4,2]/25+X[4,3]/25+X[4,4]/25)
                                                                                                           
                  ENDFOR   
             ENDFOR  
             write_tiff, 'step_1_filtered_5x5.tif',fil 
             
             
             ;thresholding
             M = fil
             ;write_tiff, 'M.tif',M
             
             O = MAKE_ARRAY(ROW,COL)
              
              ;finding the threshold value 'T'
              intst=0L
              k1=ROW*COL
              
              FOR I = 0,ROW-1 DO BEGIN      
                  FOR J = 0, COL-1 DO BEGIN
                  intst= intst+ (M[I,J])
                  endfor
              endfor
              T = (intst/k1)
              
              var1=0L
              
              FOR I = 0,ROW-1 DO BEGIN      
                  FOR J = 0, COL-1 DO BEGIN
                  var1 = var1 + (M[I,J]-T)^2
                  
                  endfor
              endfor
              var=var1/k1
              
              sd=var^0.5
              
              FOR I = 0,ROW-1 DO BEGIN      
                  FOR J = 0, COL-1 DO BEGIN     
                      
                      
                      if M[I,J] gt (T-0.5*sd) then O[I,J]=200 else O[I,J]=0

                                                                                                          
                  ENDFOR   
             ENDFOR
             write_tiff, 'step_2_thresholded.tif',O
             
             min_arr=make_array(8,1)
             FOR I = 0,ROW-3 DO BEGIN      
                  FOR J = 0, COL-3 DO BEGIN     
                      min_arr = [M[I,J],M[I,J+1],M[I,J+2],M[I+1,J],M[I+1,J+2],M[I+2,J],M[I+2,J+1],M[I+2,J+2]]
                      C = M[I+1,J+1]
                      
                      count=0
                      
                      for p = 0,7 do begin
                          if C le min_arr[p] then count=count+1
                      endfor
                                            
                      if (count eq 8) then O[I+1,J+1]=0                                                                                                          
                  ENDFOR   
             ENDFOR  
             
             write_tiff, 'step_3_thresholding_plus_minima.tif',O
             
             ;valley following
             
             M = fil     ; ORIGINAL IMAGE
                
             N = O     ; binary IMAGE   
              
             vf_count=0
             ;vf_count counts how many times the valley following or searching is done
             
             while (vf_count lt 12) do begin
                                  
              FOR I = 0, ROW-5 DO BEGIN 
                  FOR J = 0, COL-5 DO BEGIN    
                      X = [[M[I,J],M[I+1,J],M[I+2,J],M[I+3,J],M[I+4,J]],[M[I,J+1], $
                           M[I+1,J+1], M[I+2,J+1], M[I+3,J+1],M[I+4,J+1]], [M[I,J+2], M[I+1,J+2],$
                           M[I+2,J+2],M[I+3,J+2], M[I+4,J+2]], [M[I,J+3], M[I+1,J+3], M[I+2,J+3],  $
                           M[I+3,J+3], M[I+4,J+3]], [M[I,J+4],  M[I+1,J+4], M[I+2,J+4], M[I+3,J+4], M[I+4,J+4]]]
                           
                           C = N[I+2,J+2] ;centre pixel of the matrix
                           
                  if C eq 0 then begin
                      if ((X[1,3] lt X[0,3]) and (X[1,3] lt X[2,3])) or ((X[1,3] lt X[1,2]) and (X[1,3] lt X[1,4])) then N[I+1,J+3]=0
                      if ((X[2,3] lt X[1,3]) and (X[2,3] lt X[3,3])) or ((X[2,3] lt X[2,2]) and (X[2,3] lt X[2,4])) then N[I+2,J+3]=0
                      if ((X[3,3] lt X[2,3]) and (X[3,3] lt X[4,3])) or ((X[3,3] lt X[3,2]) and (X[3,3] lt X[3,4])) then N[I+3,J+3]=0
                      if ((X[3,2] lt X[2,2]) and (X[3,2] lt X[4,2])) or ((X[3,2] lt X[3,1]) and (X[3,2] lt X[3,3])) then N[I+3,J+2]=0
                  endif
                      
                      
                    
                                                                                                          
                  ENDFOR   
             ENDFOR
             
             FOR Q = 0,ROW-5 DO BEGIN      
                  FOR P = 0, COL-5 DO BEGIN 
                  
                      I = (ROW-5)-Q
                      J = (COL-5)-P
                          
                      X = [[M[I,J],M[I+1,J],M[I+2,J],M[I+3,J],M[I+4,J]],[M[I,J+1], $
                           M[I+1,J+1], M[I+2,J+1], M[I+3,J+1],M[I+4,J+1]], [M[I,J+2], M[I+1,J+2],$
                           M[I+2,J+2],M[I+3,J+2], M[I+4,J+2]], [M[I,J+3], M[I+1,J+3], M[I+2,J+3],  $
                           M[I+3,J+3], M[I+4,J+3]], [M[I,J+4],  M[I+1,J+4], M[I+2,J+4], M[I+3,J+4], M[I+4,J+4]]]
                           
                           C = N[I+2,J+2] 
                           
                  if C eq 0 then begin
                      if ((X[1,1] lt X[0,1]) and (X[1,1] lt X[2,1])) or ((X[1,1] lt X[1,0]) and (X[1,1] lt X[1,2])) then N[I+1,J+1]=0
                      if ((X[2,1] lt X[1,1]) and (X[2,1] lt X[3,1])) or ((X[2,1] lt X[2,0]) and (X[2,1] lt X[2,2])) then N[I+1,J+1]=0
                      if ((X[3,1] lt X[2,1]) and (X[3,1] lt X[4,1])) or ((X[3,1] lt X[3,0]) and (X[3,1] lt X[3,2])) then N[I+3,J+1]=0
                      if ((X[1,2] lt X[2,2]) and (X[1,2] lt X[0,2])) or ((X[1,2] lt X[1,1]) and (X[1,2] lt X[1,3])) then N[I+1,J+2]=0
                  endif
                      
                      
                    
                                                                                                          
                  ENDFOR   
             ENDFOR
             
             FOR Q = 0,ROW-5 DO BEGIN      
                  FOR P = 0, COL-5 DO BEGIN 
                  
                      I = (ROW-5)-Q
                      J = P
                          
                      X = [[M[I,J],M[I+1,J],M[I+2,J],M[I+3,J],M[I+4,J]],[M[I,J+1], $
                           M[I+1,J+1], M[I+2,J+1], M[I+3,J+1],M[I+4,J+1]], [M[I,J+2], M[I+1,J+2],$
                           M[I+2,J+2],M[I+3,J+2], M[I+4,J+2]], [M[I,J+3], M[I+1,J+3], M[I+2,J+3],  $
                           M[I+3,J+3], M[I+4,J+3]], [M[I,J+4],  M[I+1,J+4], M[I+2,J+4], M[I+3,J+4], M[I+4,J+4]]]
                           
                           C = N[I+2,J+2] 
                           
                  if C eq 0 then begin
                      if ((X[1,3] lt X[0,3]) and (X[1,3] lt X[2,3])) or ((X[1,3] lt X[1,2]) and (X[1,3] lt X[1,4])) then N[I+1,J+3]=0
                      if ((X[2,3] lt X[1,3]) and (X[2,3] lt X[3,3])) or ((X[2,3] lt X[2,2]) and (X[2,3] lt X[2,4])) then N[I+2,J+3]=0
                      if ((X[3,3] lt X[2,3]) and (X[3,3] lt X[4,3])) or ((X[3,3] lt X[3,2]) and (X[3,3] lt X[3,4])) then N[I+3,J+3]=0
                      if ((X[1,2] lt X[2,2]) and (X[1,2] lt X[0,2])) or ((X[1,2] lt X[1,1]) and (X[1,2] lt X[1,3])) then N[I+1,J+2]=0
                  endif
                      
                      
                    
                                                                                                          
                  ENDFOR   
             ENDFOR
             
             FOR Q = 0,ROW-5 DO BEGIN
                  FOR P = 0, COL-5 DO BEGIN 
                  
                      I = Q
                      J = (COL-5)-P
                          
                      X = [[M[I,J],M[I+1,J],M[I+2,J],M[I+3,J],M[I+4,J]],[M[I,J+1], $
                           M[I+1,J+1], M[I+2,J+1], M[I+3,J+1],M[I+4,J+1]], [M[I,J+2], M[I+1,J+2],$
                           M[I+2,J+2],M[I+3,J+2], M[I+4,J+2]], [M[I,J+3], M[I+1,J+3], M[I+2,J+3],  $
                           M[I+3,J+3], M[I+4,J+3]], [M[I,J+4],  M[I+1,J+4], M[I+2,J+4], M[I+3,J+4], M[I+4,J+4]]]
                           
                           C = N[I+2,J+2] 
                           
                  if C eq 0 then begin
                      if ((X[1,1] lt X[0,1]) and (X[1,1] lt X[2,1])) or ((X[1,1] lt X[1,0]) and (X[1,1] lt X[1,2])) then N[I+1,J+1]=0
                      if ((X[2,1] lt X[1,1]) and (X[2,1] lt X[3,1])) or ((X[2,1] lt X[2,0]) and (X[2,1] lt X[2,2])) then N[I+2,J+1]=0
                      if ((X[3,1] lt X[2,1]) and (X[3,1] lt X[4,1])) or ((X[3,1] lt X[3,0]) and (X[3,1] lt X[3,2])) then N[I+3,J+1]=0
                      if ((X[3,2] lt X[2,2]) and (X[3,2] lt X[4,2])) or ((X[3,2] lt X[3,1]) and (X[3,2] lt X[3,3])) then N[I+3,J+2]=0
                  endif
                      
                      
                    
                                                                                                          
                  ENDFOR   
             ENDFOR
             vf_count=vf_count+1
             endwhile
             
             vf_count2=0
             ;vf_count2 counts how many times the valley following or searching is done
             while (vf_count2 lt 4) do begin
                                  
              FOR I = 0, ROW-5 DO BEGIN 
                  FOR J = 0, COL-5 DO BEGIN    
                      X = [[M[I,J],M[I+1,J],M[I+2,J],M[I+3,J],M[I+4,J]],[M[I,J+1], $
                           M[I+1,J+1], M[I+2,J+1], M[I+3,J+1],M[I+4,J+1]], [M[I,J+2], M[I+1,J+2],$
                           M[I+2,J+2],M[I+3,J+2], M[I+4,J+2]], [M[I,J+3], M[I+1,J+3], M[I+2,J+3],  $
                           M[I+3,J+3], M[I+4,J+3]], [M[I,J+4],  M[I+1,J+4], M[I+2,J+4], M[I+3,J+4], M[I+4,J+4]]]
                           
                           C = N[I+2,J+2] ;centre pixel of the matrix
                           
                  if C eq 0 then begin
                      if ((X[1,3] lt X[0,3]) and (X[1,3] lt X[3,3])) and ((X[2,3] lt X[0,3]) and (X[2,3] lt X[3,3])) then begin 
                      N[I+1,J+3]=0
                      N[I+2,J+3]=0
                      endif
                      if ((X[2,3] lt X[1,3]) and (X[2,3] lt X[4,3])) and ((X[3,3] lt X[1,3]) and (X[3,3] lt X[4,3])) then begin 
                      N[I+2,J+3]=0
                      N[I+3,J+3]=0
                      endif
                      if ((X[3,2] lt X[3,1]) and (X[3,2] lt X[3,4])) and ((X[3,3] lt X[3,1]) and (X[3,3] lt X[3,4])) then begin 
                      N[I+3,J+2]=0
                      N[I+3,J+3]=0
                      endif
                  endif
                      
                      
                    
                                                                                                          
                  ENDFOR   
             ENDFOR
             
             FOR Q = 0,ROW-5 DO BEGIN      
                  FOR P = 0, COL-5 DO BEGIN 
                  
                      I = (ROW-5)-Q
                      J = (COL-5)-P
                          
                      X = [[M[I,J],M[I+1,J],M[I+2,J],M[I+3,J],M[I+4,J]],[M[I,J+1], $
                           M[I+1,J+1], M[I+2,J+1], M[I+3,J+1],M[I+4,J+1]], [M[I,J+2], M[I+1,J+2],$
                           M[I+2,J+2],M[I+3,J+2], M[I+4,J+2]], [M[I,J+3], M[I+1,J+3], M[I+2,J+3],  $
                           M[I+3,J+3], M[I+4,J+3]], [M[I,J+4],  M[I+1,J+4], M[I+2,J+4], M[I+3,J+4], M[I+4,J+4]]]
                           
                           C = N[I+2,J+2] 
                           
                  if C eq 0 then begin
                      if ((X[1,1] lt X[0,1]) and (X[1,1] lt X[3,1])) and ((X[2,1] lt X[0,1]) and (X[2,1] lt X[3,1])) then begin 
                      N[I+1,J+1]=0
                      N[I+2,J+1]=0
                      endif
                      if ((X[2,1] lt X[1,1]) and (X[2,1] lt X[4,1])) and ((X[3,1] lt X[1,1]) and (X[3,1] lt X[4,1])) then begin 
                      N[I+2,J+1]=0
                      N[I+3,J+1]=0
                      endif
                      if ((X[1,1] lt X[1,0]) and (X[1,1] lt X[1,3])) and ((X[1,2] lt X[1,0]) and (X[1,2] lt X[1,3])) then begin 
                      N[I+1,J+1]=0
                      N[I+1,J+2]=0
                      endif
                  endif
                      
                      
                    
                                                                                                          
                  ENDFOR   
             ENDFOR
             
             FOR Q = 0,ROW-5 DO BEGIN      
                  FOR P = 0, COL-5 DO BEGIN 
                  
                      I = (ROW-5)-Q
                      J = P
                          
                      X = [[M[I,J],M[I+1,J],M[I+2,J],M[I+3,J],M[I+4,J]],[M[I,J+1], $
                           M[I+1,J+1], M[I+2,J+1], M[I+3,J+1],M[I+4,J+1]], [M[I,J+2], M[I+1,J+2],$
                           M[I+2,J+2],M[I+3,J+2], M[I+4,J+2]], [M[I,J+3], M[I+1,J+3], M[I+2,J+3],  $
                           M[I+3,J+3], M[I+4,J+3]], [M[I,J+4],  M[I+1,J+4], M[I+2,J+4], M[I+3,J+4], M[I+4,J+4]]]
                           
                           C = N[I+2,J+2] 
                           
                  if C eq 0 then begin
                     if ((X[1,3] lt X[0,3]) and (X[1,3] lt X[3,3])) and ((X[2,3] lt X[0,3]) and (X[2,3] lt X[3,3])) then begin 
                      N[I+1,J+3]=0
                      N[I+2,J+3]=0
                      endif
                      if ((X[2,3] lt X[1,3]) and (X[2,3] lt X[4,3])) and ((X[3,3] lt X[1,3]) and (X[3,3] lt X[4,3])) then begin 
                      N[I+2,J+3]=0
                      N[I+3,J+3]=0
                      endif
                      if ((X[1,2] lt X[1,1]) and (X[1,2] lt X[1,4])) and ((X[1,3] lt X[1,1]) and (X[1,3] lt X[1,4])) then begin 
                      N[I+1,J+2]=0
                      N[I+1,J+3]=0
                      endif
                  endif
                      
                      
                    
                                                                                                          
                  ENDFOR   
             ENDFOR
             
             FOR Q = 0,ROW-5 DO BEGIN
                  FOR P = 0, COL-5 DO BEGIN 
                  
                      I = Q
                      J = (COL-5)-P
                          
                      X = [[M[I,J],M[I+1,J],M[I+2,J],M[I+3,J],M[I+4,J]],[M[I,J+1], $
                           M[I+1,J+1], M[I+2,J+1], M[I+3,J+1],M[I+4,J+1]], [M[I,J+2], M[I+1,J+2],$
                           M[I+2,J+2],M[I+3,J+2], M[I+4,J+2]], [M[I,J+3], M[I+1,J+3], M[I+2,J+3],  $
                           M[I+3,J+3], M[I+4,J+3]], [M[I,J+4],  M[I+1,J+4], M[I+2,J+4], M[I+3,J+4], M[I+4,J+4]]]
                           
                           C = N[I+2,J+2] 
                           
                  if C eq 0 then begin
                      if ((X[1,1] lt X[0,1]) and (X[1,1] lt X[3,1])) and ((X[2,1] lt X[0,1]) and (X[2,1] lt X[3,1])) then begin 
                      N[I+1,J+1]=0
                      N[I+2,J+1]=0
                      endif
                      if ((X[2,1] lt X[1,1]) and (X[2,1] lt X[4,1])) and ((X[3,1] lt X[1,1]) and (X[3,1] lt X[4,1])) then begin 
                      N[I+2,J+1]=0
                      N[I+3,J+1]=0
                      endif
                      if ((X[3,1] lt X[3,0]) and (X[3,1] lt X[3,3])) and ((X[3,2] lt X[3,0]) and (X[3,2] lt X[3,3])) then begin 
                      N[I+3,J+1]=0
                      N[I+3,J+2]=0
                      endif
                      
                  endif
                                                                                                             
                  ENDFOR   
             ENDFOR
             
             vf_count2=vf_count2+1
             endwhile             
             write_tiff, 'step_4_valley_following.tif',N
             
                          
             ;outline box
             M = N
             
             FOR I = 0,ROW-1 DO BEGIN      
                  FOR J = 0,2 DO BEGIN
                  M[I,J] = 0
                  endfor
                  FOR J = COL-3,COL-1 DO BEGIN
                  M[I,J] = 0
                  endfor
              endfor   
              FOR J = 0,COL-1 DO BEGIN      
                  FOR I = 0,2 DO BEGIN
                  M[I,J] = 0
                  endfor
                  FOR I = ROW-3,ROW-1 DO BEGIN
                  M[I,J] = 0
                  endfor
              endfor
              write_tiff, 'step_5_boxed.tif',M
              
              ;tree counting using 5 levels of rules strats from here
              m1 = M
              ;a copy of original image is kept in m1
               
              X = make_array(1,9) 
              M_copy = intarr(ROW,COL)+200
              ;array to be used to fill the tree areas that are already counted
              vf=make_array(1,8)
              all_tree=intarr(ROW,COL)+200
              
                            
              again=0
              
              while again lt 3 do begin
              ;whole rule based program is repeated again
              tree=0            
              ;counts the no of trees
              end_point=intarr(ROW,COL)+200
              
              FOR I = 0, ROW-3 DO BEGIN      
                  FOR J = 0,COL-3 DO BEGIN     
                      X = [M[I,J],M[I,J+1],M[I,J+2],M[I+1,J],M[I+1,J+1],M[I+1,J+2],M[I+2,J],M[I+2,J+1],M[I+2,J+2]]
                      
                      O = intarr(ROW,COL)+200
                      ;saves the current boundary following path
                      count=0
                      ;it counts the no of crown pixels in the current 3X3 cheching matrix
                      for q = 0,8 do begin
                          if (X[q] eq 200) then count=count+1
                      endfor
                      ;if count equal to 9 it means a crown area of 3x3 is found devoid of any valley pixel
                      if (count eq 9) then begin
                          k=I-1
                          ;going left from the center pixel of the 3X3 matrix to find a valley pixel
                          while (M[k,J+1] ne 0) do k = (k-1)
                          c=k
                          r=J+1
                          ;while a valley pixel is found start valley following from here ans store the current pixel position
                          
                          O[c,r]=0
                          ;in the boundary path storing image make this point 0, i.e. starting point
                          
                          PDIR = 0            ;at first present direction is 0
                          
                                              ;directions
                                              ; 7 0 1 
                                              ; 6 X 2
                                              ; 5 4 3 
                                              ;X is the centre pixel
                          PPDIR = 0
                          ;stores the previous direction
                          ;at first it is also set to 0
                          cc=0
                          ;'cc' checks whether crown followinf is completed
                          loop=1
                          ;'loop' counts the no of pixels visited to follow a single crown
                          
                          while (cc ne 1) do begin
                              check=0
                              ;check is for level 5 rules
                              loop=loop+1
                              ;each time increments the loop
                              vf = make_array(1,8)
                              vf = [M[c-1,r-1],M[c,r-1],M[c+1,r-1],M[c-1,r],M[c+1,r],M[c-1,r+1],M[c,r+1],M[c+1,r+1]]
                              ;array for checking the next valley pixel
                              dir_mat=intarr(1,8)+8
                                                        
                              if vf[0] eq 0 then dir_mat[0]=7
                              if vf[1] eq 0 then dir_mat[1]=0
                              if vf[2] eq 0 then dir_mat[2]=1
                              if vf[3] eq 0 then dir_mat[3]=6
                              if vf[4] eq 0 then dir_mat[4]=2
                              if vf[5] eq 0 then dir_mat[5]=5
                              if vf[6] eq 0 then dir_mat[6]=4
                              if vf[7] eq 0 then dir_mat[7]=3
                              ;dir_mat stores the all possible directions available from the present point
                              
                              ;print, dir_mat
                              
                              ;level 1 first
                              ;it allows only 45 degree clockwise movements
                              ;that is next direction will be (present direction + 1)
                              if (where(dir_mat eq ((PDIR+1) mod 8)) ne -1) then begin
                              NDIR=(PDIR+1) mod 8
                              ;level 1 second
                              ;new direction will be same as present direction
                              endif else if (where(dir_mat eq PDIR) ne -1) then begin
                              NDIR=PDIR
                              ;level 2
                              ;level 2 deals with 45 degree counter clock wise movements
                              ;that is new direction will be (present direction - 1)
                              endif else if (where(dir_mat eq ((PDIR+7) mod 8)) ne -1) then begin
                              NDIR=(PDIR+7) mod 8
                              
                               if PDIR eq 0 then begin
                                  if ((M[c+2,r-2] eq 0) or (M[c+2,r-1] eq 0)) then NDIR=(PDIR+1) mod 8
                               endif
                               
                               if PDIR eq 2 then begin
                                  if ((M[c+1,r+2] eq 0) or (M[c+2,r+2] eq 0)) then NDIR=(PDIR+1) mod 8
                               endif
                               
                               if PDIR eq 4 then begin
                                  if ((M[c-2,r+2] eq 0) or (M[c-2,r+1] eq 0)) then NDIR=(PDIR+1) mod 8
                               endif
                               
                               if PDIR eq 6 then begin
                                  if ((M[c-1,r-2] eq 0) or (M[c-2,r-2] eq 0)) then NDIR=(PDIR+1) mod 8
                               endif
                               
                               if PDIR eq 7 then begin
                                  if ((M[c,r-2] eq 0) or (M[c+1,r-2] eq 0)) then NDIR=(PDIR+1) mod 8
                               endif
                               
                               if PDIR eq 1 then begin
                                  if ((M[c+2,r] eq 0) or (M[c+2,r+1] eq 0)) then NDIR=(PDIR+1) mod 8
                               endif
                               
                               if PDIR eq 3 then begin
                                  if ((M[c-1,r+2] eq 0) or (M[c,r+1] eq 0)) then NDIR=(PDIR+1) mod 8
                               endif
                               
                               if PDIR eq 5 then begin
                                  if ((M[c-2,r] eq 0) or (M[c-2,r-1] eq 0)) then NDIR=(PDIR+1) mod 8
                               endif
                               ;while taking the level 2 rules these conditions checks valley pixels in more clockwise direction
                               
                              
                              ;level 3
                              ;for 90 degree counter clock wise turns
                              ;new direction = (present direction - 2)
                              endif else if (where(dir_mat eq ((PDIR+6) mod 8)) ne -1) then begin
                              X1 =[M[c-2,r-2],M[c-1,r-2],M[c,r-2],M[c+1,r-2],M[c+2,r-2],$
                                   M[c-2,r-1],M[c-1,r-1], M[c,r-1], M[c+1,r-1],M[c+2,r-1],$
                                   M[c-2,r],M[c-1,r],M[c,r],M[c+1,r], M[c+2,r],$
                                   M[c-2,r+1],M[c-1,r+1], M[c,r+1],M[c+1,r+1], M[c+2,r+1],$
                                   M[c-2,r+2],M[c-1,r+2], M[c,r+2], M[c+1,r+2], M[c+2,r+2]]
                               
                               NDIR=(PDIR+6) mod 8
                               
                               if PDIR EQ 0 then begin
                                  if X1[14] eq 0 then NDIR=(PDIR+2) mod 8 else $
                                  if ((X1[9] eq 0) or (X1[4] eq 0) or (X1[3] eq 0)) then NDIR=(PDIR+1) mod 8 else $
                                  if X1[2] eq 0 then NDIR=PDIR else $
                                  if ((M[c-1,r-3] eq 0) or (M[c,r-3] eq 0) or (M[c+1,r-3] eq 0)) then NDIR=PDIR else $
                                  if ((M[c-1,r-4] eq 0) or (M[c,r-4] eq 0) or (M[c+1,r-4] eq 0)) then NDIR=PDIR else $
                                  if ((M[c+3,r] eq 0) or (M[c+3,r-1] eq 0) or (M[c+3,r-2] eq 0)) then NDIR=(PDIR+1) mod 8
                               endif
                               
                               if PDIR EQ 2 then begin
                                  if X1[22] eq 0 then NDIR=(PDIR+2) mod 8 else $
                                  if ((X1[19] eq 0) or (X1[24] eq 0) or (X1[23] eq 0)) then NDIR=(PDIR+1) mod 8 else $
                                  if X1[14] eq 0 then NDIR=PDIR else $
                                  if ((M[c+3,r-1] eq 0) or (M[c+3,r] eq 0) or (M[c+3,r+1] eq 0)) then NDIR=PDIR else $
                                  if ((M[c,r+3] eq 0) or (M[c+1,r+3] eq 0) or (M[c+2,r+1] eq 0)) then NDIR=(PDIR+1) mod 8 else $
                                  if ((M[c,r+4] eq 0) or (M[c+1,r+4] eq 0) or (M[c+2,r+4] eq 0)) then NDIR=(PDIR+1) mod 8
                               endif
                               
                               if PDIR EQ 4 then begin
                                  if X1[10] eq 0 then NDIR=(PDIR+2) mod 8 else $
                                  if ((X1[15] eq 0) or (X1[20] eq 0) or (X1[21] eq 0)) then NDIR=(PDIR+1) mod 8 else $
                                  if X1[22] eq 0 then NDIR=PDIR else $
                                  if ((M[c-1,r+3] eq 0) or (M[c,r+3] eq 0) or (M[c+1,r+3] eq 0)) then NDIR=PDIR else $
                                  if ((M[c-3,r] eq 0) or (M[c-3,r+1] eq 0) or (M[c-3,r+2] eq 0)) then NDIR=(PDIR+1) mod 8 else $
                                  if ((M[c-4,r] eq 0) or (M[c-4,r+1] eq 0) or (M[c-4,r+2] eq 0)) then NDIR=(PDIR+1)
                               endif
                               
                               if PDIR EQ 6 then begin
                                  if X1[2] eq 0 then NDIR=(PDIR+2) mod 8 else $
                                  if ((X1[0] eq 0) or (X1[1] eq 0) or (X1[5] eq 0)) then NDIR=(PDIR+1) mod 8 else $
                                  if X1[10] eq 0 then NDIR=PDIR else $
                                  if ((M[c-3,r-1] eq 0) or (M[c-3,r] eq 0) or (M[c-3,r+1] eq 0)) then NDIR=PDIR else $
                                  if ((M[c-2,r-3] eq 0) or (M[c-1,r-3] eq 0) or (M[c,r-3] eq 0)) then NDIR=(PDIR+1) mod 8 else $
                                  if ((M[c-2,r-4] eq 0) or (M[c-1,r-4] eq 0) or (M[c,r-4] eq 0)) then NDIR=(PDIR+1) mod 8
                               endif
                               
                               if PDIR EQ 1 then begin
                                  if ((X1[9] eq 0) or (X1[14] eq 0) or (X1[19] eq 0)) then NDIR=(PDIR+1) mod 8 else $
                                  if ((M[c+3,r-1] eq 0) or (M[c+3,r] eq 0) or (M[c+3,r+1] eq 0)) then NDIR=(PDIR+1) mod 8
                               endif
                               if PDIR EQ 3 then begin
                                  if ((X1[21] eq 0) or (X1[22] eq 0) or (X1[23] eq 0)) then NDIR=(PDIR+1) mod 8 else $
                                  if ((M[c-1,r+3] eq 0) or (M[c,r+3] eq 0) or (M[c+1,r+3] eq 0)) then NDIR=(PDIR+1) mod 8
                               endif
                               if PDIR EQ 5 then begin
                                  if ((X1[5] eq 0) or (X1[10] eq 0) or (X1[15] eq 0)) then NDIR=(PDIR+1) mod 8 else $
                                  if ((M[c-3,r-1] eq 0) or (M[c-3,r] eq 0) or (M[c-3,r+1] eq 0)) then NDIR=(PDIR+1) mod 8
                               endif
                               if PDIR EQ 7 then begin
                                  if ((X1[1] eq 0) or (X1[2] eq 0) or (X1[3] eq 0)) then NDIR=(PDIR+1) mod 8 else $
                                  if ((M[c-1,r-3] eq 0) or (M[c,r-3] eq 0) or (M[c+1,r-3] eq 0)) then NDIR=(PDIR+1) mod 8
                               endif
                          
                              ;level 4
                              ;for 135 degree counter clock wise turns
                              ;new direction = (present direction - 3)     
                              endif else if (where(dir_mat eq ((PDIR+5) mod 8)) ne -1) then begin     
                              NDIR=(PDIR+5) mod 8
                              ;this sets the new direction as 135 degree counter clock wise
                              ;then the following rules finds valley pixels in one or two pixel gap in clockwise direction
                              ;if such pixels are found the the direction is changed accordingly
                              
                               if PDIR eq 0 then begin
                                  if ((M[c-1,r-2] eq 0) or (M[c,r-2] eq 0) or (M[c+1,r-2] eq 0) or (M[c-1,r-3] eq 0) or (M[c,r-3] eq 0) or (M[c+1,r-3] eq 0)) then NDIR=PDIR else $
                                  if ((M[c+2,r-2] eq 0) or (M[c+2,r-1] eq 0) or (M[c+2,r] eq 0) or (M[c+3,r-2] eq 0) or (M[c+3,r-1] eq 0) or (M[c+3,r] eq 0)) then NDIR=(PDIR+1) else $
                                  if ((M[c-1,r-4] eq 0) or (M[c,r-4] eq 0) or (M[c+1,r-4] eq 0)) then NDIR=PDIR 
                                  
                               endif
                               
                               if PDIR eq 2 then begin
                                  if ((M[c+2,r-1] eq 0) or (M[c+2,r] eq 0) or (M[c+2,r+1] eq 0) or (M[c+3,r-1] eq 0) or (M[c+3,r] eq 0) or (M[c+3,r+1] eq 0)) then NDIR=PDIR else $
                                  if ((M[c,r+3] eq 0) or (M[c+1,r+3] eq 0) or (M[c+2,r+1] eq 0)) then NDIR=(PDIR+1) mod 8 else $
                                  if ((M[c,r+4] eq 0) or (M[c+1,r+4] eq 0) or (M[c+2,r+4] eq 0)) then NDIR=(PDIR+1) mod 8
                               endif
                               
                               if PDIR eq 4 then begin
                                  if ((M[c-1,r+2] eq 0) or (M[c,r+2] eq 0) or (M[c+1,r+2] eq 0) or (M[c-1,r+3] eq 0) or (M[c,r+3] eq 0) or (M[c+1,r+3] eq 0)) then NDIR=PDIR
                                  if ((M[c-3,r] eq 0) or (M[c-3,r+1] eq 0) or (M[c-3,r+2] eq 0)) then NDIR=(PDIR+1) mod 8 else $
                                  if ((M[c-4,r] eq 0) or (M[c-4,r+1] eq 0) or (M[c-4,r+2] eq 0)) then NDIR=(PDIR+1)
                               endif
                               
                               if PDIR eq 6 then begin
                                  if ((M[c-2,r-1] eq 0) or (M[c-2,r] eq 0) or (M[c-2,r+1] eq 0) or (M[c-3,r-1] eq 0) or (M[c-3,r] eq 0) or (M[c-3,r+1] eq 0)) then NDIR=PDIR else $
                                  if ((M[c-2,r-2] eq 0) or (M[c-1,r-2] eq 0) or (M[c,r-2] eq 0) or (M[c-2,r-3] eq 0) or (M[c-1,r-3] eq 0) or (M[c,r-3] eq 0)) then NDIR = (PDIR+1) mod 8
                               endif
                               
                               if PDIR eq 7 then begin
                                  if ((M[c-1,r-2] eq 0) or (M[c,r-2] eq 0) or (M[c+1,r-2] eq 0) or (M[c-1,r-3] eq 0) or (M[c,r-3] eq 0) or (M[c+1,r-3] eq 0)) then NDIR=(PDIR+1) mod 8 else $
                                  if ((M[c+2,r-2] eq 0) or (M[c+2,r-1] eq 0)) then NDIR=(PDIR+2) mod 8
                               endif
                               
                               if PDIR eq 1 then begin
                                  if ((M[c+2,r-2] eq 0) or (M[c+2,r] eq 0) or (M[c+2,r+1] eq 0) or (M[c+3,r-1] eq 0) or (M[c+3,r] eq 0) or (M[c+3,r+1] eq 0)) then NDIR=(PDIR+1) mod 8 else $
                                  if ((M[c+2,r+2] eq 0) or (M[c+1,r+2] eq 0)) then NDIR=(PDIR+2) mod 8
                               endif
                               
                               if PDIR eq 3 then begin
                                  if ((M[c-1,r+2] eq 0) or (M[c,r+2] eq 0) or (M[c+1,r+2] eq 0) or (M[c-1,r+3] eq 0) or (M[c,r+3] eq 0) or (M[c+1,r+3] eq 0)) then NDIR=(PDIR+1) mod 8 else $
                                  if ((M[c-2,r+2] eq 0) or (M[c-2,r+1] eq 0)) then NDIR=(PDIR+2) mod 8 else $
                                  if ((M[c+2,r+1] eq 0) or (M[c+2,r+2] eq 0)) then NDIR=PDIR else $
                                  if ((M[c+3,r+1] eq 0) or (M[c+3,r+2] eq 0)) then NDIR=PDIR
                               endif
                               
                               if PDIR eq 5 then begin
                                  if ((M[c-2,r-1] eq 0) or (M[c-2,r] eq 0) or (M[c-2,r+1] eq 0) or (M[c-3,r-1] eq 0) or (M[c-3,r] eq 0) or (M[c-3,r+1] eq 0)) then NDIR=(PDIR+1) mod 8 else $
                                  if ((M[c-2,r-2] eq 0) or (M[c-1,r-2] eq 0)) then NDIR=(PDIR+2) mod 8
                               endif
                               
                               ;level 5
                               ;it deals with direction reversals
                               ;i.e. new direction = (present direction - 4)
                               endif else if (where(dir_mat eq ((PDIR+4) mod 8)) ne -1) then begin     
                               NDIR=(PDIR+4) mod 8
                               ;this sets the new direction as 180 degree from present
                               ;then the following rules finds valley pixels in one or two or three pixel gap in present direction
                               ;if such pixels are found the the direction is changed accordingly
                               
                          
                               if PDIR eq 0 then begin
                                  if ((M[c-1,r-2] eq 0) or (M[c,r-2] eq 0) or (M[c+1,r-2] eq 0) or (M[c-1,r-3] eq 0) or (M[c,r-3] eq 0) or (M[c+1,r-3] eq 0)) then NDIR=PDIR
                               endif
                               
                               if PDIR eq 2 then begin
                                  if ((M[c+2,r-1] eq 0) or (M[c+2,r] eq 0) or (M[c+2,r+1] eq 0) or (M[c+3,r-1] eq 0) or (M[c+3,r] eq 0) or (M[c+3,r+1] eq 0)) then NDIR=PDIR
                               endif
                               
                               if PDIR eq 4 then begin
                                  if ((M[c-1,r+2] eq 0) or (M[c,r+2] eq 0) or (M[c+1,r+2] eq 0) or (M[c-1,r+3] eq 0) or (M[c,r+3] eq 0) or (M[c+1,r+3] eq 0)) then NDIR=PDIR
                               endif
                               
                               if PDIR eq 6 then begin
                                  if ((M[c-2,r-1] eq 0) or (M[c-2,r] eq 0) or (M[c-2,r+1] eq 0) or (M[c-3,r-1] eq 0) or (M[c-3,r] eq 0) or (M[c-3,r+1] eq 0) or (M[c-4,r-1] eq 0) or (M[c-4,r] eq 0) or (M[c-4,r+1] eq 0)) then NDIR=PDIR  else $
                                  if ((M[c-1,r+2] eq 0) or (M[c-2,r+2] eq 0)) then NDIR= (PDIR+7) mod 8
                               endif
                               
                               if PDIR eq 7 then begin
                                  if ((M[c-1,r-2] eq 0) or (M[c,r-2] eq 0) or (M[c+1,r-2] eq 0) or (M[c-1,r-3] eq 0) or (M[c,r-3] eq 0) or (M[c+1,r-3] eq 0)) then NDIR=(PDIR+1) mod 8
                               endif
                               
                               if PDIR eq 1 then begin
                                  if ((M[c+2,r-1] eq 0) or (M[c+2,r] eq 0) or (M[c+2,r+1] eq 0) or (M[c+3,r-1] eq 0) or (M[c+3,r] eq 0) or (M[c+3,r+1] eq 0)) then NDIR=(PDIR+1) mod 8
                               endif
                               
                               if PDIR eq 3 then begin
                                  if ((M[c-1,r+2] eq 0) or (M[c,r+2] eq 0) or (M[c+1,r+2] eq 0) or (M[c-1,r+3] eq 0) or (M[c,r+3] eq 0) or (M[c+1,r+3] eq 0)) then NDIR=(PDIR+1) mod 8
                               endif
                               
                               if PDIR eq 5 then begin
                                  if ((M[c-2,r-1] eq 0) or (M[c-2,r] eq 0) or (M[c-2,r+1] eq 0) or (M[c-3,r-1] eq 0) or (M[c-3,r] eq 0) or (M[c-3,r+1] eq 0)) then NDIR=(PDIR+1) mod 8 else $
                                  if ((M[c,r+2] eq 0) or (M[c-1,r+2] eq 0) or (M[c-1,r+3] eq 0) or (M[c,r+3] eq 0)) then NDIR=(PDIR+7) mod 8
                               endif
                               
                               ;if no valley pixels are found in one, two or three pixel gap then the whole inlet is erased
                               if (NDIR eq ((PDIR+4) mod 8)) then begin
                               M[c,r]=200
                               O[c,r]=loop
                               m1[c,r]=200
                               check=1
                               ;another check variable is set to indicate the termination section that it is a case of direction reversal
                               NDIR= PPDIR
                               endif
                               
                             endif
                             
                             
                          
                            ;NDIR position determination
                            if check eq 0 then begin
                                if NDIR eq 0 then begin
                                c=c
                                r=r-1
                                endif 
                                if NDIR eq 1 then begin
                                c=c+1
                                r=r-1
                                endif
                                if NDIR eq 2 then begin
                                c=c+1
                                r=r
                                endif
                                if NDIR eq 3 then begin
                                c=c+1
                                r=r+1
                                endif
                                if NDIR eq 4 then begin
                                c=c
                                r=r+1
                                endif
                                if NDIR eq 5 then begin
                                c=c-1
                                r=r+1
                                endif
                                if NDIR eq 6 then begin
                                c=c-1
                                r=r
                                endif   
                                if NDIR eq 7 then begin
                                c=c-1
                                r=r-1
                                endif
                            endif else begin
                            ;no use of this section 
                                if PDIR eq 4 then begin
                                c=c
                                r=r-1
                                endif 
                                if PDIR eq 5 then begin
                                c=c+1
                                r=r-1
                                endif
                                if PDIR eq 6 then begin
                                c=c+1
                                r=r
                                endif
                                if PDIR eq 7 then begin
                                c=c+1
                                r=r+1
                                endif
                                if PDIR eq 0 then begin
                                c=c
                                r=r+1
                                endif
                                if PDIR eq 1 then begin
                                c=c-1
                                r=r+1
                                endif
                                if PDIR eq 2 then begin
                                c=c-1
                                r=r
                                endif   
                                if PDIR eq 3 then begin
                                c=c-1
                                r=r-1
                                endif
                            endelse
                            
                            ;termination assessment section
                            if O[c,r] ne 200 then begin
                              if check eq 0 then begin    
                              ;in case of direction reversal
                                 if (loop - O[c,r]) gt 15 then begin
                                 ;to avoid short area to be counted as a tree
                                 
                                 if end_point[c,r] ne 0 then begin
                                 ;another array which stores the end points of each tree crown boundary line
                                 ;if it is zero then the tree count is ignored
                                 
                                  lc=O[c,r]                            
                                  ;loop value where crown ends
                                  tree_fill= intarr(ROW,COL)+0
                                  tree=tree+1                
                                  ;tree count entered
                                  cc=1
                                  
                                  ;this whole section below (upto the marked point) below fills the tree area with valley pixels that is already counted 
                                  for t1=0,ROW-1 do begin
                                      t2=0
                                      while (((O[t1,t2] eq 200) or (O[t1,t2] lt lc)) and (t2 lt COL-1)) do begin
                                      tree_fill[t1,t2]=200
                                      t2=t2+1
                                      endwhile
                                      t2=COL-1
                                      while (((O[t1,t2] eq 200) or (O[t1,t2] lt lc)) and (t2 gt 0)) do begin
                                      tree_fill[t1,t2]=200
                                      t2=t2-1
                                      endwhile
                                  endfor
                                  
                                  for t2=0,COL-1 do begin
                                      t1=0
                                      while (((O[t1,t2] eq 200) or (O[t1,t2] lt lc)) and (t1 lt ROW-1)) do begin
                                      tree_fill[t1,t2]=200
                                      t1=t1+1
                                      endwhile
                                      t1=ROW-1
                                      while (((O[t1,t2] eq 200) or (O[t1,t2] lt lc)) and (t1 gt 0)) do begin
                                      tree_fill[t1,t2]=200
                                      t1=t1-1
                                      endwhile
                                  endfor
                                  
                                  for q=0,ROW-1 do begin
                                      for w=0,COL-1 do begin
                                        if tree_fill[q,w] eq 0 then begin
                                        M[q,w]=0
                                        ;filling the counted tree area
                                        all_tree[q,w]=0
                                        endif
                                      endfor
                                  endfor
                                  ;upto this point
                                  
                                  print, 'break'
                                  ;print, ' '
                                  end_point[c,r]=0
                                  ;marking the current end point on end_point array
                                  break
                                  endif
                              endif else begin
                              PPDIR=PDIR
                              PDIR=NDIR
                              M[c,r]=0
                              O[c,r]=loop
                              m1[c,r]=0
                              endelse
                              
                              endif else begin
                              PPDIR=PDIR
                              PDIR=NDIR
                              M[c,r]=0
                              O[c,r]=loop
                              m1[c,r]=0
                              endelse 
                                 
                            endif else begin
                            PPDIR=PDIR
                            PDIR=NDIR
                            M[c,r]=0
                            O[c,r]=loop
                            m1[c,r]=0
                            endelse
                            
                            if loop gt 280 then begin
                                break
                                ;to avoid the program from following large crown i.e. more than 280 steps
                            endif
                             
                      endwhile
                      
                      endif  
                                  
                      ENDFOR
                      
              ENDFOR 
              
              
              again=again+1
              M=m1
              ;the delineated image is capied to M
              endwhile
                           
              write_tiff, 'step_6_result.tif',m1
              ;write_tiff, 'tree_fill_full.tif',tree_fill
              ;write_tiff, 'all_tree_test.tif',all_tree
              print, 'no of trees = ',tree
END