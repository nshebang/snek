(define canvas (dom-element "#game"))
(define ctx (js-invoke canvas "getContext" "2d"))

(define sfx-on (dom-element "#sfx-on"))
(define sfx-off (dom-element "#sfx-off"))
(define bgm (dom-element "#bgm"))
(define sfx-nom (dom-element "#sfx-nom"))
(define sfx-death (dom-element "#sfx-death"))

(define game-state 'playing)
(define score 0)

(define DARK "#17141c")
(define LIGHT "#a692b0")

(define board-w 60)
(define board-h 36)
(define cell-size 8)
(define real-w 480)
(define real-h 288)

(define player-x 10) ; more like head-x
(define player-y 10) ; more like head-y
(define player-len 2) ; long snek 
(define player-xsp 1)
(define player-ysp 0)
(define player-counter 0)
(define player-move-delay 12) ; snek fast
(define player-tail '(9 10))
(define food-x 0)
(define food-y 0)
(define food-img 0)

(define key-space 32)
(define key-left 37)
(define key-up 38)
(define key-right 39)
(define key-down 40)

(define key-left-p #f)
(define key-up-p #f)
(define key-right-p #f)
(define key-down-p #f)

(define (divisible? x y)
  (if (zero? (modulo x y))
    #t
    #f))

(define (play-sound snd)
  (js-invoke snd "play"))

(define (stop-sound snd)
  (js-invoke snd "pause")
  (js-set! snd "currentTime" 0))

(define (enable-sfx e)
  (js-set! bgm "volume" 1)
  (js-set! sfx-nom "volume" 1)
  (js-set! sfx-death "volume" 1))

(define (disable-sfx e) 
  (js-set! bgm "volume" 0)
  (js-set! sfx-nom "volume" 0)
  (js-set! sfx-death "volume" 0))

(add-handler! sfx-on "click" enable-sfx)
(add-handler! sfx-off "click" disable-sfx)

(define (keydown e)
  (let ((key-code (js-ref e "keyCode")))
  (cond ((= key-code key-left) (set! key-left-p #t))
    ((= key-code key-right) (set! key-right-p #t))
    ((= key-code key-up) (set! key-up-p #t))
    ((= key-code key-down) (set! key-down-p #t))
    (else '()))))

(define (keyup e)
  (let ((key-code (js-ref e "keyCode")))
  (cond ((= key-code key-left) (set! key-left-p #f))
    ((= key-code key-right) (set! key-right-p #f))
    ((= key-code key-up) (set! key-up-p #f))
    ((= key-code key-down) (set! key-down-p #f))
    ((and (= key-code key-space) (eq? game-state 'gameover))
      (reset-game))
    (else '()))))

(add-handler! (js-eval "document.body") "keydown" keydown)
(add-handler! (js-eval "document.body") "keyup" keyup)

(define (key-process)
  (cond (key-left-p 
    (if (not (= player-xsp 1))
      (list 
        (set! player-xsp -1)
        (set! player-ysp 0))
        '()))
    (key-right-p 
    (if (not (= player-xsp -1))
      (list
        (set! player-xsp 1)
        (set! player-ysp 0))
        '()))
    (key-up-p
    (if (not (= player-ysp 1))
      (list
        (set! player-ysp -1)
        (set! player-xsp 0))
        '()))
    (key-down-p
    (if (not (= player-ysp -1))
      (list
        (set! player-ysp 1)
        (set! player-xsp 0)
        '())))
    (else '())))

(define (reset-game)
  (set! player-len 2)
  (set! player-x 10)
  (set! player-y 10)
  (set! player-xsp 1)
  (set! player-ysp 0)
  (set! player-tail '(9 10))
  (set! score 0)
  (set! player-move-delay 12)
  (random-food-position)
  (play-sound bgm)
  (set-content! ($ "#score-el") "0")
  (set-style! ($ "#game-over-el") "display" "none")
  (set! game-state 'playing))

(define (die)
  (stop-sound bgm)
  (play-sound sfx-death)
  (set-style! ($ "#game-over-el") "display" "block")
  (set! game-state 'gameover))

(define (move-player)
  (if (< (/ (length player-tail) 2) (- player-len 1))
      (set! player-tail (append player-tail (list player-x player-y)))
      (set! player-tail (append (cddr player-tail) (list player-x player-y))))
  (set! player-x (+ player-x player-xsp))
  (set! player-y (+ player-y player-ysp)))

(define (random-food-position)
  (set! food-x (random-integer (- board-w 1)))
  (set! food-y (random-integer (- board-h 1)))
  (set! food-img (random-integer 4)))

(define (check-food-collision)
  (if (and (= player-x food-x) (= player-y food-y))
      (list
        (play-sound sfx-nom)
        (random-food-position)
        (set! player-len (+ player-len 1))
        (set! score (+ 100 score))
        (if (> player-move-delay 1)
            (set! player-move-delay (- player-move-delay 1)))
        (set-content! ($ "#score-el") (number->string (+ 100 score))))
      '()))

(define (check-wall-collision)
  (cond ((or (> player-x (- board-w 1)) (< player-x 0)) (die))
    ((or (> player-y (- board-h 1)) (< player-y 0)) (die))
    (else '())))

(define (check-tail-collision t)
  (if (zero? (length t))
      '()
      (if (and (= player-x (car t)) (= player-y (car (cdr t))))
        (die)
        (check-tail-collision (cddr t)))))

(define (draw-image src x y)
  (let ((img (js-eval "document.createElement('img')")))
    (js-invoke img "setAttribute" "src" src)
    (js-invoke ctx "drawImage" img x y)))

(define (draw-tail t)
  (if (zero? (length t))
    '()
    (list 
      (draw-image "./img/tail.png" 
        (* (car t) cell-size) (* (car (cdr t)) cell-size))
      (draw-tail (cddr t)))))

(define (draw-player)
  ; head
  (draw-image "./img/head.png" 
    (* player-x cell-size)
    (* player-y cell-size))
  ; body + tail
  (draw-tail player-tail))

(define (draw-food)
  (draw-image (string-join (list "./img/food" food-img ".png"))
    (* food-x cell-size)
    (* food-y cell-size)))

(define (render)
  (js-invoke ctx "clearRect" 0 0 real-w real-h)
  (js-set! ctx "fillStyle" DARK)
  (js-invoke ctx "fillRect" 0 0 real-w real-h)
  (js-set! ctx "fillStyle" LIGHT) 
  (draw-player)
  (draw-food))
  
(define (game-loop)
  (if (eq? game-state 'playing)
    (list (set! player-counter (+ 1 player-counter))
    (if (divisible? player-counter player-move-delay)
      (list
        (move-player)
        (set! player-counter 0))
        '())
    (check-food-collision)
    (check-wall-collision)
    (check-tail-collision player-tail)
    (key-process)
    (render))
    '())
  (timer game-loop (/ 1 60)))

(define (run) 
  (console-log "Running snek v1.0")
  (play-sound bgm)
  (random-food-position)
  (game-loop))

(run)
