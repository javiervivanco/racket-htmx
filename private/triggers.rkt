#lang racket/base

(require racket/contract
         racket/string
         racket/format
         "normalize.rkt")

(provide
 (contract-out
  [trigger (->* (symbol?)
                (#:changed? boolean?
                 #:once? boolean?
                 #:delay (or/c exact-nonnegative-integer? string? #f)
                 #:throttle (or/c exact-nonnegative-integer? string? #f)
                 #:from (or/c symbol? string? #f)
                 #:target (or/c symbol? string? #f)
                 #:consume? boolean?
                 #:queue (or/c 'first 'last 'all 'none #f)
                 #:filter (or/c string? #f))
                list?)]
  [poll (->* ((or/c exact-nonnegative-integer? string?))
             (#:filter (or/c string? #f))
             list?)]
  [on-load (->* ()
                (#:delay (or/c exact-nonnegative-integer? string? #f)
                 #:throttle (or/c exact-nonnegative-integer? string? #f)
                 #:filter (or/c string? #f))
                list?)]))

;; Construye el atributo hx-trigger con modifiers complejos
(define (trigger event-name
                 #:changed? [changed? #f]
                 #:once? [once? #f]
                 #:delay [delay-ms #f]
                 #:throttle [throttle-ms #f]
                 #:from [selector #f]
                 #:target [target #f]
                 #:consume? [consume? #f]
                 #:queue [queue #f]
                 #:filter [js-cond #f])
  (let* ([event-str (symbol->string event-name)]
         [parts (list event-str)]
         ;; Filter viene inmediatamente después del evento
         [parts (if js-cond
                    (list (string-append event-str "[" js-cond "]"))
                    parts)]
         ;; Modifiers simples (flags)
         [parts (if changed? (append parts (list "changed")) parts)]
         [parts (if once? (append parts (list "once")) parts)]
         [parts (if consume? (append parts (list "consume")) parts)]
         ;; Modifiers con valores
         [parts (if delay-ms
                    (append parts (list (string-append "delay:" (normalize-time delay-ms))))
                    parts)]
         [parts (if throttle-ms
                    (append parts (list (string-append "throttle:" (normalize-time throttle-ms))))
                    parts)]
         [parts (if selector
                    (append parts (list (string-append "from:" (normalize-selector selector))))
                    parts)]
         [parts (if target
                    (append parts (list (string-append "target:" (normalize-selector target))))
                    parts)]
         [parts (if queue
                    (append parts (list (string-append "queue:" (symbol->string queue))))
                    parts)])
    (list 'hx-trigger (string-join parts " "))))

;; Helper para Polling (alias sintáctico)
(define (poll interval #:filter [js-cond #f])
  (trigger 'every #:delay interval #:filter js-cond))

;; Helper para Load (alias sintáctico)
(define (on-load #:delay [d #f] #:throttle [th #f] #:filter [js-cond #f])
  (trigger 'load #:delay d #:throttle th #:filter js-cond))
