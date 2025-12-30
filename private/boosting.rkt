#lang racket/base

(require racket/contract
         "normalize.rkt")

(provide
 (contract-out
  [boost (->* () (boolean?) list?)]
  [push-url (->* () ((or/c boolean? string?)) list?)]
  [history (->* () (boolean?) list?)]
  [confirm (-> string? list?)]
  [preserve (->* () (boolean?) list?)]))

;; Habilita/deshabilita boost
(define (boost [active? #t])
  (list 'hx-boost (if active? "true" "false")))

;; Controla push de URL al historial
;; url-or-bool: #t (push actual), #f (no push), string (push custom URL)
(define (push-url [url-or-bool #t])
  (cond
    [(boolean? url-or-bool)
     (list 'hx-push-url (if url-or-bool "true" "false"))]
    [(string? url-or-bool)
     (list 'hx-push-url url-or-bool)]
    [else (error 'push-url "Expected boolean or string, got: ~a" url-or-bool)]))

;; Habilita/deshabilita historial
(define (history [enabled? #t])
  (if enabled?
      (list 'hx-history "true")
      (list 'hx-history "false")))

;; Mensaje de confirmación antes de request
(define (confirm text)
  (list 'hx-confirm text))

;; Preserva elemento durante swap
(define (preserve [enabled? #t])
  (if enabled?
      (list 'hx-preserve "true")
      (list 'hx-preserve "false")))
