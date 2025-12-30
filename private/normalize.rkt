#lang racket/base

(require racket/contract
         racket/string
         racket/format
         json)

(provide
 (contract-out
  [normalize-selector (-> (or/c symbol? string?) string?)]
  [normalize-time (-> (or/c exact-nonnegative-integer? string?) string?)]
  [normalize-json (-> (or/c hash? list?) string?)]
  [normalize-url (-> string? (or/c hash? #f) boolean? string?)]
  [normalize-boolean (-> any/c (or/c string? #f))]
  [is-attr-pair? (-> any/c boolean?)]))

;; Normaliza selectores: 'mi-id -> "#mi-id", strings pasan sin cambios
(define (normalize-selector sel)
  (cond
    [(symbol? sel) (string-append "#" (symbol->string sel))]
    [(string? sel) sel]
    [else (error 'normalize-selector "Expected symbol or string, got: ~a" sel)]))

;; Normaliza tiempos: 500 -> "500ms", strings pasan sin cambios
(define (normalize-time time)
  (cond
    [(exact-nonnegative-integer? time) (format "~ams" time)]
    [(string? time) time]
    [else (error 'normalize-time "Expected integer or string, got: ~a" time)]))

;; Normaliza hash o alist a JSON string
(define (normalize-json data)
  (cond
    [(hash? data) (jsexpr->string data)]
    [(list? data) (jsexpr->string (make-immutable-hash data))]
    [else (error 'normalize-json "Expected hash or alist, got: ~a" data)]))

;; Construye URL con query params
;; path: string base
;; params: hash o alist o #f
;; encode?: si codificar parámetros URL
(define (normalize-url path params encode?)
  (if (or (not params) (and (hash? params) (hash-empty? params)) (null? params))
      path
      (let* ([param-list (if (hash? params)
                             (hash->list params)
                             params)]
             [encoded-pairs
              (for/list ([pair param-list])
                (let ([k (if (symbol? (car pair))
                             (symbol->string (car pair))
                             (car pair))]
                      [v (format "~a" (cdr pair))])
                  (if encode?
                      (string-append (uri-encode k) "=" (uri-encode v))
                      (string-append k "=" v))))])
        (string-append path "?" (string-join encoded-pairs "&")))))

;; Normaliza booleanos: #t -> "true", #f -> #f (no se incluye atributo)
(define (normalize-boolean val)
  (cond
    [(eq? val #t) "true"]
    [(eq? val #f) #f]
    [else (error 'normalize-boolean "Expected boolean, got: ~a" val)]))

;; Verifica si un valor es un par atributo (symbol string/number)
(define (is-attr-pair? val)
  (and (list? val)
       (= (length val) 2)
       (symbol? (car val))
       (or (string? (cadr val))
           (number? (cadr val)))))

;; Helper para URI encoding simple
(define (uri-encode str)
  (string-join
   (for/list ([c (in-string str)])
     (cond
       [(or (char-alphabetic? c)
            (char-numeric? c)
            (memq c '(#\- #\_ #\. #\~)))
        (string c)]
       [else
        (format "%~a" (string-upcase (~r (char->integer c) #:base 16 #:min-width 2 #:pad-string "0")))]))
   ""))
