#lang scribble/manual
@require[@for-label[htmx
                    (except-in racket/base sync)]]

@title{HTMX DSL for Racket}
@author{javier}

@defmodule[htmx]

A functional DSL in Racket for generating HTMX attributes and X-expressions through pure composition.

@bold{English} | @hyperlink["htmx-es.html"]{Español}

@section{Introduction}

@racket[htmx] is a library that enables generating idiomatic HTMX code using functional
composition. Each function returns an attribute pair that naturally integrates with HTML tags.

@subsection{Design Principles}

@itemlist[
  @item{@bold{Function-Driven}: Everything is an expression, no complex macros}
  @item{@bold{Symbol-First}: Automatic type normalization (@racket['my-id] → @racket["#my-id"], @racket[500] → @racket["500ms"])}
  @item{@bold{Natural Composition}: Attributes and content compose seamlessly}
]

@section{AJAX Core}

Functions for HTTP requests with automatic URL parameter encoding.

@defproc[(get [url string?] [params (or/c hash? list? #f) #f]) list?]{
  Generates @racket[hx-get] attribute. If @racket[params] provided, appends as query string.

  @racketblock[
    (get "/api/data")
    ; → '(hx-get "/api/data")

    (get "/search" (hash 'q "test"))
    ; → '(hx-get "/search?q=test")
  ]
}

@defproc[(post [url string?] [params (or/c hash? list? #f) #f]) list?]{
  Generates @racket[hx-post] attribute.
}

@defproc[(put [url string?] [params (or/c hash? list? #f) #f]) list?]{
  Generates @racket[hx-put] attribute.
}

@defproc[(patch [url string?] [params (or/c hash? list? #f) #f]) list?]{
  Generates @racket[hx-patch] attribute.
}

@defproc[(delete [url string?] [params (or/c hash? list? #f) #f]) list?]{
  Generates @racket[hx-delete] attribute.
}

@defproc[(req [path string?]
              [#:params params (or/c hash? list?) '()]
              [#:encode? encode? boolean? #t]) string?]{
  Helper for constructing complex URLs with query parameters.

  @racketblock[
    (req "/api/search" #:params (hash 'q "test" 'page 2))
    ; → "/api/search?q=test&page=2"
  ]
}

@section{Triggers & Events}

Control when HTMX requests are triggered.

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
  Generates @racket[hx-trigger] attribute with complex modifiers.

  @racketblock[
    (trigger 'click)
    ; → '(hx-trigger "click")

    (trigger 'keyup #:changed? #t #:delay 500)
    ; → '(hx-trigger "keyup changed delay:500ms")

    (trigger 'keyup #:filter "this.value.length > 3" #:queue 'last)
    ; → '(hx-trigger "keyup[this.value.length > 3] queue:last")
  ]
}

@defproc[(poll [interval (or/c exact-nonnegative-integer? string?)]
               [#:filter js-cond (or/c string? #f) #f]) list?]{
  Alias for automatic polling. Generates @racket[hx-trigger] with @racket['every] event.

  @racketblock[
    (poll 5000)
    ; → '(hx-trigger "every delay:5000ms")
  ]
}

@defproc[(on-load [#:delay d (or/c exact-nonnegative-integer? string? #f) #f]
                  [#:throttle th (or/c exact-nonnegative-integer? string? #f) #f]
                  [#:filter js-cond (or/c string? #f) #f]) list?]{
  Alias for load event trigger.
}

@section{Swapping & Targets}

Control where and how content is swapped.

@defproc[(target [selector (or/c symbol? string?)]) list?]{
  Generates @racket[hx-target] attribute. Symbols are prefixed with @racket["#"].

  @racketblock[
    (target 'results)
    ; → '(hx-target "#results")

    (target ".container")
    ; → '(hx-target ".container")
  ]
}

@defproc[(swap [style symbol?]
               [#:transition? trans? boolean? #f]
               [#:swap-delay swap (or/c exact-nonnegative-integer? string? #f) #f]
               [#:settle-delay settle (or/c exact-nonnegative-integer? string? #f) #f]
               [#:scroll scroll (or/c symbol? string? #f) #f]
               [#:scroll-focus? focus? boolean? #f]
               [#:show show (or/c symbol? string? #f) #f]
               [#:show-focus? show-focus? boolean? #f]) list?]{
  Generates @racket[hx-swap] attribute with modifiers.

  Valid styles: @racket['innerHTML], @racket['outerHTML], @racket['beforebegin],
  @racket['afterbegin], @racket['beforeend], @racket['afterend], @racket['delete], @racket['none].

  @racketblock[
    (swap 'innerHTML)
    ; → '(hx-swap "innerHTML")

    (swap 'innerHTML #:transition? #t #:swap-delay 200)
    ; → '(hx-swap "innerHTML transition:true swap:200ms")
  ]
}

@defproc[(swap-oob [style symbol?] [selector (or/c symbol? string? #f) #f]) list?]{
  Generates @racket[hx-swap-oob] attribute for out-of-band swaps.
}

@section{Parameters & Values}

Control request payload.

@defproc[(vals [data (or/c hash? list?)]) list?]{
  Generates @racket[hx-vals] attribute. Serializes hash or alist to JSON string.

  @racketblock[
    (vals (hash 'user-id 123 'action "update"))
    ; → '(hx-vals "{\"user-id\":123,\"action\":\"update\"}")
  ]
}

@defproc[(params [allow (listof (or/c symbol? string?))]
                 [#:mode mode (or/c 'none 'all 'not #f) #f]) list?]{
  Generates @racket[hx-params] attribute. Filters which parameters to include.

  @racketblock[
    (params '(email password))
    ; → '(hx-params "email, password")

    (params '(csrf) #:mode 'not)
    ; → '(hx-params "not csrf")
  ]
}

@section{Indicators & Synchronization}

Visual feedback and request concurrency control.

@defproc[(indicator [selector (or/c symbol? string?)]) list?]{
  Generates @racket[hx-indicator] attribute.
}

@defproc[(sync [selector (or/c symbol? string?)]
               [strategy (or/c 'drop 'abort 'replace 'queue-first 'queue-last 'queue-all #f) #f]) list?]{
  Generates @racket[hx-sync] attribute for controlling concurrent requests.

  @racketblock[
    (sync 'search-input 'abort)
    ; → '(hx-sync "#search-input:abort")
  ]
}

@section{Boosting & History}

Progressive enhancement and browser history control.

@defproc[(boost [active? boolean? #t]) list?]{
  Generates @racket[hx-boost] attribute.
}

@defproc[(push-url [url-or-bool (or/c boolean? string?) #t]) list?]{
  Generates @racket[hx-push-url] attribute.
}

@defproc[(history [enabled? boolean? #t]) list?]{
  Generates @racket[hx-history] attribute.
}

@defproc[(confirm [text string?]) list?]{
  Generates @racket[hx-confirm] attribute.
}

@defproc[(preserve [enabled? boolean? #t]) list?]{
  Generates @racket[hx-preserve] attribute.
}

@section{Extensions}

HTMX extensions support.

@defproc[(ext [names (or/c symbol? string?)] ...) list?]{
  Generates @racket[hx-ext] attribute.

  @racketblock[
    (ext 'ws 'json-enc)
    ; → '(hx-ext "ws, json-enc")
  ]
}

@defproc[(ws-connect [url string?]) list?]{
  WebSocket connection (requires @racket['ws] extension).
}

@defproc[(sse-connect [url string?]) list?]{
  Server-Sent Events connection.
}

@defproc[(sse-swap [message-name string?]) list?]{
  SSE swap by message name.
}

@defproc[(on [event-name symbol?] [js-code string?]) list?]{
  Generates inline event handler (@racket[hx-on:eventname]).

  @racketblock[
    (on 'click "console.log('clicked')")
    ; → '(hx-on:click "console.log('clicked')")
  ]
}

@section{HTML Attributes}

Standard HTML attribute helpers.

@defproc[(id [val (or/c symbol? string?)]) list?]{
  Generates @racket[id] attribute.
}

@defproc[(class [classes (or/c symbol? string?)] ...) list?]{
  Generates @racket[class] attribute. Accepts multiple classes.

  @racketblock[
    (class "p-4" "bg-gray-100")
    ; → '(class "p-4 bg-gray-100")
  ]
}

@defproc[(name [val (or/c symbol? string?)]) list?]{
  Generates @racket[name] attribute.
}

@defproc[(value [val (or/c symbol? string? number?)]) list?]{
  Generates @racket[value] attribute.
}

@defproc[(type [val (or/c symbol? string?)]) list?]{
  Generates @racket[type] attribute.
}

@defproc[(data [attr-name symbol?] [val string?]) list?]{
  Generates dynamic @racket[data-*] attribute.

  @racketblock[
    (data 'user-id "123")
    ; → '(data-user-id "123")
  ]
}

@defproc[(aria [attr-name symbol?] [val string?]) list?]{
  Generates dynamic @racket[aria-*] attribute.

  @racketblock[
    (aria 'label "Click me")
    ; → '(aria-label "Click me")
  ]
}

@section{HTML Tags}

All HTML tags are available with @racket[hx:] prefix.

Tag functions automatically separate attributes from body content and flatten nested attribute lists.

@subsection{Common Tags}

@defthing[hx:div procedure?]{Block container}
@defthing[hx:span procedure?]{Inline container}
@defthing[hx:p procedure?]{Paragraph}
@defthing[hx:a procedure?]{Anchor/link}
@defthing[hx:button procedure?]{Button}

@subsection{Form Elements}

@defthing[hx:form procedure?]{Form}
@defthing[hx:input procedure?]{Input field}
@defthing[hx:textarea procedure?]{Text area}
@defthing[hx:select procedure?]{Select dropdown}
@defthing[hx:option procedure?]{Select option}
@defthing[hx:label procedure?]{Label}

@subsection{Lists}

@defthing[hx:ul procedure?]{Unordered list}
@defthing[hx:ol procedure?]{Ordered list}
@defthing[hx:li procedure?]{List item}

@subsection{Tables}

@defthing[hx:table procedure?]{Table}
@defthing[hx:tr procedure?]{Table row}
@defthing[hx:td procedure?]{Table cell}
@defthing[hx:th procedure?]{Table header cell}

@subsection{Headings}

@defthing[hx:h1 procedure?]{Heading level 1}
@defthing[hx:h2 procedure?]{Heading level 2}
@defthing[hx:h3 procedure?]{Heading level 3}

@section{Examples}

@subsection{Search with Debounce}

@racketblock[
(hx:div
  (id 'search-box)
  (class "container")

  (hx:input
    (name "q")
    (placeholder "Search...")
    (post "/search")
    (trigger 'keyup #:changed? #t #:delay 500)
    (target 'results)
    (swap 'innerHTML #:transition? #t))

  (hx:div (id 'results)))
]

@subsection{Infinite Scroll}

@racketblock[
(hx:div
  (id 'posts)
  (get "/api/posts" (hash 'offset 10))
  (trigger 'revealed)
  (swap 'afterend)
  "Loading...")
]

@subsection{Form with Confirmation}

@racketblock[
(hx:form
  (hx:button
    (delete "/api/user/123")
    (confirm "Are you sure?")
    (target 'result)
    "Delete User"))
]

@section{Resources}

@itemlist[
  @item{@hyperlink["https://htmx.org/docs/"]{HTMX Documentation}}
  @item{@hyperlink["https://docs.racket-lang.org/xml/index.html"]{Racket X-expressions}}
  @item{@hyperlink["https://github.com/javiervivanco/racket-htmx"]{GitHub Repository}}
]
