(import srfi-1)
(import (prefix sdl2 "sdl2:"))

(define *points-count* 100)

(define *control-points*
  (map (lambda (p) (apply sdl2:make-point p))
       '((10 500) (300 10) (590 500))))

; https://en.wikipedia.org/wiki/Bezier_curve
(define (bezier-point controls t)
  (if (null? (cdr controls))
    (car controls)
    (let ((tail (cdr controls))
          (init (reverse (cdr (reverse controls)))))
        (sdl2:point-add
          (sdl2:point-scale (bezier-point init t) (- 1.0 t))
          (sdl2:point-scale (bezier-point tail t) t)))))

; PERF: need memoization otherwise we're recomputing the same combinations multiple times (like fibonacci)
(define (bezier-points controls points-count)
  (do ((t 0.0 (+ t (/ 1.0 points-count)))
       (points '()))
      ((>= t 1.0) points)
      (set! points (cons (bezier-point controls t) points))))

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

(define +hit-rect-size+ 10)
(define +hit-rect-size-half+ (/ +hit-rect-size+ 2))

(define *selected-control-point-index* -1)

(define (control-hit-rect point)
  (let ((x (sdl2:point-x point))
        (y (sdl2:point-y point)))
    (sdl2:make-rect
      (- x +hit-rect-size-half+)
      (- y +hit-rect-size-half+)
      +hit-rect-size+
      +hit-rect-size+)))

(define (draw-control-points! control-points)
  (if (null? control-points)
    '()
    (let* ((p (car control-points))
           (rest (cdr control-points))
           (rect (control-hit-rect p)))
      (sdl2:render-fill-rect! renderer rect)
      (draw-control-points! rest))))

(define (update!)
  (set! (sdl2:render-draw-color renderer) +background-color+)
  (sdl2:render-clear! renderer)
  (set! (sdl2:render-draw-color renderer) +lines-color+)
  (sdl2:render-draw-lines! renderer (bezier-points *control-points* *points-count*))
  (draw-control-points! *control-points*)
  (sdl2:render-present! renderer))

(do () (#f '())
  (begin
      (let ((event (sdl2:wait-event!)))
        (case (sdl2:event-type event)
          ((quit) (exit))
          ((mouse-button-down)
            (let* ((x (sdl2:mouse-button-event-x event))
                   (y (sdl2:mouse-button-event-y event))
                   (mouse-point (sdl2:make-point x y))
                   (index (list-index (lambda (p)
                                        (sdl2:point-in-rect? mouse-point (control-hit-rect p)))
                                      *control-points*)))
                (when index (set! *selected-control-point-index* index))))
          ((mouse-button-up)
             (set! *selected-control-point-index* -1))
          ((mouse-motion)
            (when (not (null? (sdl2:mouse-motion-event-state event)))
              (let ((x (sdl2:mouse-motion-event-x event))
                    (y (sdl2:mouse-motion-event-y event)))
                (when (not (= -1 *selected-control-point-index*))
                  (set! (list-ref *control-points* *selected-control-point-index*)
                        (sdl2:make-point x y))))))
          ((key-down)
           (case (sdl2:keyboard-event-sym event)
             ((escape q) (exit))
             ((up)
                (set! *control-points* (cons (sdl2:make-point 20 20) *control-points*)))
             ((down)
                (when (not (null? (cdr *control-points*)))
                  (set! *control-points* (cdr *control-points*))))))))
      (update!)))
