#lang racket/base

(require racket/contract
         racket/string)

(provide
 (contract-out
  [id (-> (or/c symbol? string?) list?)]
  [class (->* () () #:rest (listof (or/c symbol? string?)) list?)]
  [name (-> (or/c symbol? string?) list?)]
  [value (-> (or/c symbol? string? number?) list?)]
  [type (-> (or/c symbol? string?) list?)]
  [placeholder (-> string? list?)]
  [href (-> string? list?)]
  [src (-> string? list?)]
  [alt (-> string? list?)]
  [title (-> string? list?)]
  [disabled (->* () (boolean?) list?)]
  [required (->* () (boolean?) list?)]
  [readonly (->* () (boolean?) list?)]
  [checked (->* () (boolean?) list?)]
  [selected (->* () (boolean?) list?)]
  [hidden (->* () (boolean?) list?)]
  [autocomplete (-> (or/c 'on 'off symbol? string?) list?)]
  [method (-> (or/c 'get 'post 'put 'delete 'patch symbol? string?) list?)]
  [action (-> string? list?)]
  [enctype (-> string? list?)]
  [html-target (-> (or/c '_blank '_self '_parent '_top string?) list?)]
  [rel (-> string? list?)]
  [role (-> string? list?)]
  [aria (-> symbol? string? list?)]
  [data (-> symbol? string? list?)]
  [style (-> string? list?)]))

;; Atributo id
(define (id val)
  (list 'id (if (symbol? val) (symbol->string val) val)))

;; Atributo class (acepta múltiples clases)
(define (class . classes)
  (let ([class-str
         (string-join
          (map (lambda (c)
                 (if (symbol? c) (symbol->string c) c))
               classes)
          " ")])
    (list 'class class-str)))

;; Atributo name
(define (name val)
  (list 'name (if (symbol? val) (symbol->string val) val)))

;; Atributo value
(define (value val)
  (list 'value (cond
                 [(symbol? val) (symbol->string val)]
                 [(number? val) (number->string val)]
                 [else val])))

;; Atributo type
(define (type val)
  (list 'type (if (symbol? val) (symbol->string val) val)))

;; Atributo placeholder
(define (placeholder text)
  (list 'placeholder text))

;; Atributo href
(define (href url)
  (list 'href url))

;; Atributo src
(define (src url)
  (list 'src url))

;; Atributo alt
(define (alt text)
  (list 'alt text))

;; Atributo title
(define (title text)
  (list 'title text))

;; Atributo disabled (booleano)
(define (disabled [active? #t])
  (if active?
      (list 'disabled "disabled")
      (list)))

;; Atributo required (booleano)
(define (required [active? #t])
  (if active?
      (list 'required "required")
      (list)))

;; Atributo readonly (booleano)
(define (readonly [active? #t])
  (if active?
      (list 'readonly "readonly")
      (list)))

;; Atributo checked (booleano)
(define (checked [active? #t])
  (if active?
      (list 'checked "checked")
      (list)))

;; Atributo selected (booleano)
(define (selected [active? #t])
  (if active?
      (list 'selected "selected")
      (list)))

;; Atributo hidden (booleano)
(define (hidden [active? #t])
  (if active?
      (list 'hidden "hidden")
      (list)))

;; Atributo autocomplete
(define (autocomplete val)
  (list 'autocomplete (if (symbol? val) (symbol->string val) val)))

;; Atributo method
(define (method val)
  (list 'method (if (symbol? val) (symbol->string val) val)))

;; Atributo action
(define (action url)
  (list 'action url))

;; Atributo enctype
(define (enctype val)
  (list 'enctype val))

;; Atributo target (renombrado a html-target para evitar conflicto con hx-target)
(define (html-target val)
  (list 'target (if (symbol? val) (symbol->string val) val)))

;; Atributo rel
(define (rel val)
  (list 'rel val))

;; Atributo role
(define (role val)
  (list 'role val))

;; Atributos aria-* dinámicos
;; Ejemplo: (aria 'label "Click me") -> '(aria-label "Click me")
(define (aria attr-name val)
  (let ([attr-symbol (string->symbol (string-append "aria-" (symbol->string attr-name)))])
    (list attr-symbol val)))

;; Atributos data-* dinámicos
;; Ejemplo: (data 'user-id "123") -> '(data-user-id "123")
(define (data attr-name val)
  (let ([attr-symbol (string->symbol (string-append "data-" (symbol->string attr-name)))])
    (list attr-symbol val)))

;; Atributo style
(define (style css)
  (list 'style css))
