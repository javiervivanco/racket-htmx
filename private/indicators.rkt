#lang racket/base

(require racket/contract
         racket/string
         "normalize.rkt")

(provide
 (contract-out
  [indicator (-> (or/c symbol? string?) list?)]
  [sync (->* ((or/c symbol? string?))
             ((or/c 'drop 'abort 'replace 'queue-first 'queue-last 'queue-all #f))
             list?)]))

;; Define el indicador de carga
(define (indicator selector)
  (list 'hx-indicator (normalize-selector selector)))

;; Define la estrategia de sincronización
;; selector: elemento a sincronizar
;; strategy: 'drop, 'abort, 'replace, 'queue-first, 'queue-last, 'queue-all
(define (sync selector [strategy #f])
  (let ([sel-str (normalize-selector selector)])
    (if strategy
        (list 'hx-sync (string-append sel-str ":" (symbol->string strategy)))
        (list 'hx-sync sel-str))))
