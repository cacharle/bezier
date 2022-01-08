(import (prefix sdl2 "sdl2:"))

(sdl2:set-main-ready!)

(sdl2:init! '(video))
(on-exit sdl2:quit!)

(define window
  (sdl2:create-window!
    "Bezier"
    'centered 'centered
    600 600))
(on-exit (lambda () (sdl2:destroy-window! window)))

(define renderer (sdl2:create-renderer! window))
(on-exit (lambda () (sdl2:destroy-renderer! renderer)))

; (set! (sdl2:renderer-draw-blend-mode renderer) ...)

(define *points-count* 10)

(define *control-points*
  (map (lambda (p) (apply sdl2:make-point p))
       '((10 200) (200 10) (200 200))))

(print *control-points*)

; (define (bezier-points)
;   )


(define +background-color+ (sdl2:make-color 32 32 32))
(define +lines-color+ (sdl2:make-color 200 200 200))

(define (update!)
  (set! (sdl2:render-draw-color renderer) +background-color+)
  (sdl2:render-clear! renderer)
  (set! (sdl2:render-draw-color renderer) +lines-color+)
  (sdl2:render-draw-line! renderer 10 10 100 100)
  (sdl2:render-present! renderer))

(do () (#f '())
  (begin
      (let ((event (sdl2:wait-event!)))
        (case (sdl2:event-type event)
          ((quit) (exit))
          ; ((mouse-button-down)
          ;    (sdl2:mouse-button-event-x event)
          ;    (sdl2:mouse-button-event-y event)
          ; ((mouse-button-up)
          ;    ...
          ; ((mouse-motion)
          ;   (sdl2:mouse-motion-event-state event)
          ;    ...
          ((key-down)
           (case (sdl2:keyboard-event-sym event)
             ((escape q) (exit))))))
      (update!)
      (sdl2:delay! 10)))

