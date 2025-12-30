#lang racket/base

(require racket/contract
         racket/string
         "normalize.rkt")

(provide
 (contract-out
  [vals (-> (or/c hash? list?) list?)]
  [params (->* ((listof (or/c symbol? string?)))
               (#:mode (or/c 'none 'all 'not #f))
               list?)]))

;; Serializa hash/alist a JSON para hx-vals
(define (vals data)
  (list 'hx-vals (normalize-json data)))

;; Filtra parámetros a enviar
;; allow: lista de símbolos o strings
;; mode: 'none, 'all, 'not (para hx-params="not ...")
(define (params allow #:mode [mode #f])
  (let* ([normalized-allow
          (map (lambda (item)
                 (if (symbol? item)
                     (symbol->string item)
                     item))
               allow)]
         [param-str (string-join normalized-allow ", ")]
         [final-value
          (cond
            [(eq? mode 'not) (string-append "not " param-str)]
            [(eq? mode 'none) "none"]
            [(eq? mode 'all) "all"]
            [else param-str])])
    (list 'hx-params final-value)))
