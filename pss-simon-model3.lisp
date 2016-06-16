;;; PSS _ SImon task


;;; main idea, same as Lovett's NJAMOS
;;; Selective attention is competition among productions.

;;; This version of the model produced

(clear-all)

(define-model pss-simon3

(sgp :er t
     :act nil
     :esc T
     :ans 0.05
     :auto-attend T
     :le 0.67
     :lf 0.3
     :mas 5.0
     :ul T
     :egs 0.1
     :reward-hook bg-reward-hook
     :alpha 0.01
     :imaginal-activation 3.0
     :visual-activation 1.0)

(chunk-type (simon-stimulus (:include visual-object))
	    kind shape color position)

(chunk-type (simon-screen (:include visual-object))
	    kind value)

(chunk-type (simon-stimulus-location (:include visual-location))
	    shape color position)

(chunk-type simon-rule kind has-motor-response shape hand dimension)

(chunk-type compatible-response has-motor-response hand position)

(chunk-type hand-response kind hand) 


(chunk-type wm state value dimension irrelevant checked)

(add-dm (simon-rule isa chunk)
	(simon-stimulus isa chunk)
	(simon-screen isa chunk)
	(stimulus isa chunk)
	(done isa chunk)
	(pause isa chunk)
	(circle isa chunk)
	(square isa chunk)
	(shape isa chunk)
	(not-shape isa chunk)
	(position isa chunk)
	(not-position isa chunk)
	(yes isa chunk)
	(no isa chunk)
	(proceed isa chunk)
	(process isa chunk)
	(hand-response isa chunk)
	(blocked isa chunk)
	(circle-left isa simon-rule
		     kind simon-rule
		     has-motor-response yes
		     hand left
		     shape circle
		     dimension shape)

	(square-right isa simon-rule
		      kind simon-rule
		      has-motor-response yes
		      hand right
		      shape square
		      dimension shape)

	(compatible-response-right isa compatible-response
				   has-motor-response yes
				   hand right
				   position right)

	(compatible-response-left isa compatible-response
				  has-motor-response yes
				  hand left
				  position left)

	(respond-right-hand isa hand-response
			    kind hand-response
			    hand right)

	(respond-left-hand isa hand-response
			   kind hand-response
			   hand left)


	(stimulus1 isa simon-stimulus
		   shape circle
		   position right
		   color black
		   kind simon-stimulus)

	(wm1 isa wm
	     state proceed)
)

(p find-screen
   "Look at the screen (if you were not already looking at it)"
   ?visual>
     buffer empty
     state free
     
   ?visual-location>
     buffer empty
     state free
==>
   +visual-location>
     screen-x lowest
)  

(p prepare-wm
   "If there are no contents in WM, prepare contents"
   ?imaginal>
     buffer empty
     state free

   ?manual>
     preparation free
     processor free
     execution free  
==>
   +imaginal>
     isa wm
     state process
     checked no
)


(p process-shape
   =visual>
     kind simon-stimulus
     shape =SHAPE
     
   =imaginal>
     state process
     dimension nil

   ?retrieval>
     state free
     buffer empty

==>
   =visual>
   =imaginal>
     dimension =SHAPE
)

(p dont-process-shape
   =visual>
     kind simon-stimulus
     position =POS
     
   =imaginal>
     state process
     dimension nil

   ?retrieval>
     state free
     buffer empty

==>
   =visual>
   =imaginal>
     dimension =POS
)

(p process-position
   =visual>
     kind simon-stimulus
     position =POS
     
   =imaginal>
     state process
     dimension nil

   ?retrieval>
     state free
     buffer empty

==>
   =visual>
   =imaginal>
     dimension =POS
)

(p dont-process-position
   =visual>
     kind simon-stimulus
     shape =SHAPE
     
   =imaginal>
     state process
     dimension nil

   ?retrieval>
     state free
     buffer empty

==>
   =visual>     
   =imaginal>
     dimension =SHAPE
)


(p retrieve-intended-response
   "Retrieves the relevant part of the Simon Task rule"
   =visual>
     kind simon-stimulus
     shape =SHAPE
     
   =imaginal>
     state process
   - dimension nil
   
   ?retrieval>
     state free
     buffer empty
==>
   =visual>   ; Keep visual
   =imaginal> ; Keep WM
   
   +retrieval>
     kind simon-rule
     ;shape =SHAPE
     has-motor-response yes
)


;;; Check
;;; Last time to catch yourself making a mistake
(p check-pass
   =visual>
     shape =SHAPE
   
   =retrieval>
     kind  simon-rule
     shape =SHAPE

   =imaginal>
     state process
     checked no
   
   ?imaginal>
     state free
==>
    !eval! (trigger-reward 1)
    
   =visual>
   =retrieval>
   =imaginal>
     checked yes
 )

(p check-detect-problem
   =visual>
     shape =SHAPE
   
   =retrieval>
     kind  simon-rule
   - shape =SHAPE

   =imaginal>
     state process
     checked no
   
   ?imaginal>
     state free
 ==>
   !eval! (trigger-reward -1)
   =visual>
   -retrieval>
   =imaginal>
     checked yes
 )

 
(p respond
   "Puts the rule in WM"
   =visual>
     kind simon-stimulus
     shape =SHAPE 

   =imaginal>
     state process
     checked yes

   =retrieval>
     kind simon-rule
     has-motor-response yes
     hand =HAND
     
   ?manual>
     preparation free
     processor free
     execution free
==>
  -imaginal>
  -retrieval>
  +manual>
     isa punch
     hand =HAND
     finger index
)


)  ;;; End of the model
;(spp check :u 10 :fixed-utility t)

;(spp process-shape :at 0.150)
;(spp process-position :at 0.150)


(defun simon3-reload (&key (visicon t))
  (reload)
  (install-device (make-instance 'simon-task))
  (init (current-device))
  (proc-display)
  (when visicon
    (print-visicon)))
