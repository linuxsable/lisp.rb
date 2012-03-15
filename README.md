# Lisp.rb

A small lisp interpeter in Ruby… for personal edification and play only.

###Usage

    [~/Software/lisp.rb > master]$ ruby lisp.rb 

    lisp.rb> (define square (lambda (r) (* r r)))
     => #<Proc:0x007f9a53110e78@lisp.rb:146 (lambda)>

    lisp.rb> (square 10)
     => 100

    lisp.rb> (define list-square (lambda (lst) (if (null? lst) lst (cons (square (car lst)) (list-square (cdr lst))))))
     => #<Proc:0x007f9a5381bd30@lisp.rb:146 (lambda)>

    lisp.rb> (list-square (list 1 2 3 4 5 6))
     => [1, 4, 9, 16, 25, 36]

    lisp.rb> (map square (list 1 2 3 4 5 6))
     => [1, 4, 9, 16, 25, 36]

    lisp.rb> (define fact (lambda (n) (if (<= n 1) 1 (* n (fact (- n 1))))))
     => #<Proc:0x007f9a5302adb0@lisp.rb:146 (lambda)>

    lisp.rb> (map fact (list 2 4 6 8))
     => [2, 24, 720, 40320]

    lisp.rb> (env)
    #+
    #-
    #*
    #/
    #>
    #>=
    #<
    #<=
    #=
    true
    false
    null
    #equal?
    #null?
    #car
    #first
    #cdr
    #rest
    #cons
    #last
    #list
    #list?
    #length
    #map
    #reduce
    #square
    #list-square
    #fact

    lisp.rb> quit
    Goodbye, cruel world.
    
### TODO

* Able to interpret files instead of just a REPL
* REPL history

**Made with <3 by @_ty.**