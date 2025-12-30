#lang racket/base

(require racket/contract
         racket/list
         "normalize.rkt")

(provide
 (contract-out
  [make-tag (-> symbol? procedure?)]
  [flatten-attrs (-> list? list?)]))

;; Función auxiliar para aplanar listas de atributos
;; Convierte '((a "1") ((b "2") (c "3"))) -> '((a "1") (b "2") (c "3"))
(define (flatten-attrs lst)
  (cond
    [(null? lst) '()]
    [(and (list? (car lst))
          (not (null? (car lst)))
          (symbol? (caar lst))
          (= (length (car lst)) 2))
     ;; Es un atributo simple '(key val)
     (cons (car lst) (flatten-attrs (cdr lst)))]
    [(and (list? (car lst))
          (not (null? (car lst)))
          (list? (caar lst)))
     ;; Es una lista de atributos '((key val) (key2 val2))
     (append (flatten-attrs (car lst)) (flatten-attrs (cdr lst)))]
    [(and (list? (car lst)) (null? (car lst)))
     ;; Lista vacía (ej: resultado de (disabled #f))
     (flatten-attrs (cdr lst))]
    [else
     ;; No es atributo, mantener como está
     (cons (car lst) (flatten-attrs (cdr lst)))]))

;; Función auxiliar para verificar si es un atributo válido
(define (is-valid-attr? item)
  (and (list? item)
       (= (length item) 2)
       (symbol? (car item))
       (or (string? (cadr item))
           (number? (cadr item)))))

;; Función auxiliar para separar atributos de body
(define (separate-attrs-and-body items)
  (let loop ([rest items] [attrs '()] [body '()])
    (cond
      [(null? rest)
       (values (reverse attrs) (reverse body))]

      ;; Es un atributo válido
      [(is-valid-attr? (car rest))
       (loop (cdr rest) (cons (car rest) attrs) body)]

      ;; Es una lista vacía (atributo deshabilitado)
      [(and (list? (car rest)) (null? (car rest)))
       (loop (cdr rest) attrs body)]

      ;; Es una lista de atributos (necesita aplanamiento)
      [(and (list? (car rest))
            (not (null? (car rest)))
            (or (is-valid-attr? (caar rest))
                (and (list? (caar rest))
                     (not (null? (caar rest))))))
       (let ([flattened (flatten-attrs (list (car rest)))])
         (loop (cdr rest) (append (reverse flattened) attrs) body))]

      ;; Es contenido del body
      [else
       (loop (cdr rest) attrs (cons (car rest) body))])))

;; Constructor genérico de tags HTML
;; Retorna una función que acepta argumentos rest y construye un x-expr
(define (make-tag tag-name)
  (lambda args
    (let-values ([(attrs body) (separate-attrs-and-body args)])
      (cond
        ;; Tag con atributos y body
        [(and (not (null? attrs)) (not (null? body)))
         `(,tag-name ,attrs ,@body)]
        ;; Tag solo con atributos (auto-cierre)
        [(not (null? attrs))
         `(,tag-name ,attrs)]
        ;; Tag solo con body
        [(not (null? body))
         `(,tag-name ,@body)]
        ;; Tag vacío
        [else
         `(,tag-name)]))))

;; Funciones de tags específicos exportados en main.rkt
;; Aquí solo proveemos el constructor genérico
