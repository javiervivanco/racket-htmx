#lang scribble/manual
@require[@for-label[htmx
                    (except-in racket/base sync)]]

@title{htmx}
@author{javier}

@defmodule[htmx]

DSL funcional en Racket para generar atributos HTMX y X-expressions mediante composición pura.

@section{Introducción}

@racket[htmx] es una librería que permite generar código HTMX idiomático usando composición
funcional. Cada función retorna un par atributo que se integra naturalmente con los tags HTML.

@section{AJAX Core}

@defproc[(get [url string?] [params (or/c hash? list? #f) #f]) list?]{
  Genera atributo @racket[hx-get].
}

@defproc[(post [url string?] [params (or/c hash? list? #f) #f]) list?]{
  Genera atributo @racket[hx-post].
}

@defproc[(put [url string?] [params (or/c hash? list? #f) #f]) list?]{
  Genera atributo @racket[hx-put].
}

@defproc[(patch [url string?] [params (or/c hash? list? #f) #f]) list?]{
  Genera atributo @racket[hx-patch].
}

@defproc[(delete [url string?] [params (or/c hash? list? #f) #f]) list?]{
  Genera atributo @racket[hx-delete].
}

@section{Triggers}

@defproc[(trigger [event-name symbol?]
                  [#:changed? changed? boolean? #f]
                  [#:once? once? boolean? #f]
                  [#:delay delay-ms (or/c exact-nonnegative-integer? string? #f) #f]
                  [#:throttle throttle-ms (or/c exact-nonnegative-integer? string? #f) #f]
                  [#:from selector (or/c symbol? string? #f) #f]
                  [#:target target (or/c symbol? string? #f) #f]
                  [#:consume? consume? boolean? #f]
                  [#:queue queue (or/c 'first 'last 'all 'none #f) #f]
                  [#:filter js-cond (or/c string? #f) #f]) list?]{
  Genera atributo @racket[hx-trigger] con modifiers complejos.
}

@defproc[(poll [interval (or/c exact-nonnegative-integer? string?)]
               [#:filter js-cond (or/c string? #f) #f]) list?]{
  Alias para polling automático.
}

@section{Swapping}

@defproc[(target [selector (or/c symbol? string?)]) list?]{
  Genera atributo @racket[hx-target].
}

@defproc[(swap [style symbol?]
               [#:transition? trans? boolean? #f]
               [#:swap-delay swap (or/c exact-nonnegative-integer? string? #f) #f]
               [#:settle-delay settle (or/c exact-nonnegative-integer? string? #f) #f]
               [#:scroll scroll (or/c symbol? string? #f) #f]
               [#:scroll-focus? focus? boolean? #f]
               [#:show show (or/c symbol? string? #f) #f]
               [#:show-focus? show-focus? boolean? #f]) list?]{
  Genera atributo @racket[hx-swap] con modifiers.
}

@section{HTML Tags}

Todos los tags HTML están disponibles con el prefijo @racket[hx:].

Ejemplos: @racket[hx:div], @racket[hx:span], @racket[hx:button], @racket[hx:form], etc.
