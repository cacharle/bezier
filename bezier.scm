(import (prefix sdl2 "sdl2:"))

; (set! (sdl2:renderer-draw-blend-mode renderer) ...)

(define *points-count* 100)

(define *control-points*
  (map (lambda (p) (apply sdl2:make-point p))
       '((10 200) (200 10) (400 400) (500 410))))

(print *control-points*)

; https://en.wikipedia.org/wiki/Bezier_curve
(define (bezier-point controls t)
  (if (null? (cdr controls))
    (car controls)
    (let ((tail (cdr controls))
          (init (reverse (cdr (reverse controls)))))
        (sdl2:point-add
          (sdl2:point-scale (bezier-point init t) (- 1.0 t))
          (sdl2:point-scale (bezier-point tail t) t)))))

; (print (bezier-point *control-points* 0.5))

(define (bezier-points controls points-count)
  (do ((t 0.0 (+ t (/ 1.0 points-count)))
       (points '()))
      ((>= t 1.0) points)
      (set! points (cons (bezier-point controls t) points))))

; (print (bezier-points *control-points* 3))

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
(define +background-color+ (sdl2:make-color 32 32 32))
(define +lines-color+ (sdl2:make-color 200 200 200))

(define (update!)
  (set! (sdl2:render-draw-color renderer) +background-color+)
  (sdl2:render-clear! renderer)
  (set! (sdl2:render-draw-color renderer) +lines-color+)
  ; (sdl2:render-draw-line! renderer 10 10 100 100)
  (sdl2:render-draw-lines! renderer (bezier-points *control-points* *points-count*))
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

