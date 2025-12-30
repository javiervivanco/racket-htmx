#lang racket/base

(require racket/contract
         racket/string
         racket/format)

(provide
 (contract-out
  [ws-connect (-> string? list?)]
  [sse-connect (-> string? list?)]
  [sse-swap (-> string? list?)]
  [on (-> symbol? string? list?)]
  [ext (->* () () #:rest (listof (or/c symbol? string?)) list?)]))

;; WebSocket connection
;; Nota: Requiere extensión ws (hx-ext="ws")
(define (ws-connect url)
  (list 'ws-connect url))

;; Server Sent Events connection
;; Nota: Requiere extensión sse
(define (sse-connect url)
  (list 'sse-connect url))

;; SSE swap por nombre de mensaje
(define (sse-swap message-name)
  (list 'sse-swap message-name))

;; Eventos inline (hx-on:eventname)
;; event-name: símbolo del evento ('click, 'load, etc.)
;; js-code: string con código JavaScript
(define (on event-name js-code)
  (let ([attr-name (string->symbol (format "hx-on:~a" (symbol->string event-name)))])
    (list attr-name js-code)))

;; Carga extensiones HTMX
;; names: lista variable de nombres (símbolos o strings)
(define (ext . names)
  (let ([normalized-names
         (map (lambda (name)
                (if (symbol? name)
                    (symbol->string name)
                    name))
              names)])
    (list 'hx-ext (string-join normalized-names ", "))))
