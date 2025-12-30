#lang racket/base

(require racket/contract
         racket/string
         racket/format
         "normalize.rkt")

(provide
 (contract-out
  [target (-> (or/c symbol? string?) list?)]
  [swap (->* (symbol?)
             (#:transition? boolean?
              #:swap-delay (or/c exact-nonnegative-integer? string? #f)
              #:settle-delay (or/c exact-nonnegative-integer? string? #f)
              #:scroll (or/c symbol? string? #f)
              #:scroll-focus? boolean?
              #:show (or/c symbol? string? #f)
              #:show-focus? boolean?)
             list?)]
  [swap-oob (->* (symbol?) ((or/c symbol? string? #f)) list?)]))

;; Define el target del swap
(define (target selector)
  (list 'hx-target (normalize-selector selector)))

;; Control de swap con modifiers complejos
;; style: 'innerHTML, 'outerHTML, 'beforebegin, 'afterbegin, 'beforeend, 'afterend, 'delete, 'none
(define (swap style
              #:transition? [trans? #f]
              #:swap-delay [swap #f]
              #:settle-delay [settle #f]
              #:scroll [scroll #f]
              #:scroll-focus? [focus? #f]
              #:show [show #f]
              #:show-focus? [show-focus? #f])
  (let* ([style-str (symbol->string style)]
         [parts (list style-str)]
         ;; Transition
         [parts (if trans?
                    (append parts (list "transition:true"))
                    parts)]
         ;; Swap delay
         [parts (if swap
                    (append parts (list (string-append "swap:" (normalize-time swap))))
                    parts)]
         ;; Settle delay
         [parts (if settle
                    (append parts (list (string-append "settle:" (normalize-time settle))))
                    parts)]
         ;; Scroll
         [parts (if scroll
                    (let ([scroll-val (if (symbol? scroll)
                                          (symbol->string scroll)
                                          (normalize-selector scroll))])
                      (append parts (list (string-append "scroll:" scroll-val))))
                    parts)]
         ;; Scroll focus
         [parts (if focus?
                    (append parts (list "focus-scroll:true"))
                    parts)]
         ;; Show
         [parts (if show
                    (let ([show-val (if (symbol? show)
                                        (symbol->string show)
                                        (normalize-selector show))])
                      (append parts (list (string-append "show:" show-val))))
                    parts)]
         ;; Show focus
         [parts (if show-focus?
                    (append parts (list "focus-show:true"))
                    parts)])
    (list 'hx-swap (string-join parts " "))))

;; Out of Band Swaps
;; style: 'true, 'innerHTML, 'outerHTML, etc.
;; selector: opcional, para especificar target del OOB
(define (swap-oob style [selector #f])
  (let ([value (if selector
                   (string-append (symbol->string style) ":" (normalize-selector selector))
                   (if (eq? style 'true)
                       "true"
                       (symbol->string style)))])
    (list 'hx-swap-oob value)))
