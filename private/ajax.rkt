#lang racket/base

(require racket/contract
         "normalize.rkt")

(provide
 (contract-out
  [get (->* (string?) ((or/c hash? list? #f)) list?)]
  [post (->* (string?) ((or/c hash? list? #f)) list?)]
  [put (->* (string?) ((or/c hash? list? #f)) list?)]
  [patch (->* (string?) ((or/c hash? list? #f)) list?)]
  [delete (->* (string?) ((or/c hash? list? #f)) list?)]
  [req (->* (string?) (#:params (or/c hash? list?) #:encode? boolean?) string?)]))

;; Constructor de URL con parámetros
(define (req path #:params [params '()] #:encode? [encode? #t])
  (normalize-url path params encode?))

;; GET request
(define (get url [params #f])
  (list 'hx-get (normalize-url url params #t)))

;; POST request
(define (post url [params #f])
  (list 'hx-post (normalize-url url params #t)))

;; PUT request
(define (put url [params #f])
  (list 'hx-put (normalize-url url params #t)))

;; PATCH request
(define (patch url [params #f])
  (list 'hx-patch (normalize-url url params #t)))

;; DELETE request
(define (delete url [params #f])
  (list 'hx-delete (normalize-url url params #t)))
