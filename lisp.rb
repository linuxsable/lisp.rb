#!/usr/bin ruby
# 
# Lisp parser.
# Port and inspiration of http://norvig.com/lispy.html.
#
# TODO:
#  * Create standard libs to clean up global scope
#  * Floats are broked?
#
# Author: @_ty

class Env < Hash
  @@globals = {
    # MATHS
    '+' => lambda { |*args|
      sum = 0
      args.each { |x| sum += x }
      sum
    },
    '-' => lambda { |x, *args|
      diff = x
      args.each { |y| diff -= y }
      diff
    },
    '*' => lambda { |*args|
      prod = args.slice!(0)
      args.each { |x| prod *= x }
      prod
    },
    '/' => lambda { |x, *args|
      quot = x
      args.each { |y| quot /= y }
      quot
    },
    
    # Comparisons 
    '>' => lambda { |x, y| x > y },
    '>=' => lambda { |x, y| x >= y },
    '<' => lambda { |x, y| x < y },
    '<=' => lambda { |x, y| x <= y },
    '=' => lambda { |x, y| x == y },
    
    # Types
    'true' => true,
    'false' => false,
    'null' => nil,
    
    'equal?' => lambda { |x, y| @@globals['='].call(x, y) },
    'null?' => lambda { |x| x.nil? },
    'car' => lambda { |x| x[0] },
    'first' => lambda{ |x| @@globals['car'].call(x) },
    'cdr' => lambda { |x| x[1..-1] },
    'rest' => lambda{ |x| @@globals['cdr'].call(x) },
    'cons' => lambda { |x, y| x + y },
    'last' => lambda { |x| x[-1] },
    'list' => lambda { |*args| args.to_a },
    'list?' => lambda { |x| x.is_a? Array },
    'length' => lambda { |x| x.length }, 
  }
  
  def initialize(params=[], args=[], outer=nil)
    merged = {}
    params.each_with_index do |v, k|
      if args[k].nil?
        raise Exception, 'Unknown parse error!'
      else
        merged[v] = args[k]
      end
    end
    
    self.merge!(merged)

    @outer = outer
    merge_globals()
  end

  def search(var)
    # Return the current env if the variables exists in it
    if not self[var].nil?
      self
    else
      # Return the outer env if it exists out of it
      if not @outer.nil?
        @outer.search(var)
      else
        self
      end
    end
  end

  private

  def merge_globals
    self.merge!(@@globals)
  end
end

class Lisp
  def initialize
    @env = Env.new
    @quit_message = "Goodbye, cruel world."
    @version = '0.1'
  end
  
  # Evaluate an expression in an environ
  def eval(x, env = @env)
    # This is just a crude way to see what
    # variables are in the env.
    # eg: (env)
    if x[0] == 'env'
      env.each do |k, v|
        if v.is_a? Proc
          print "#" + k + "\n"
        else
          print k + "\n"
        end
      end
      nil
    # eg: true
    elsif x.is_a? String # Variable reference
      env.search(x)[x]
    # eg: 12.23
    elsif x.is_a? Numeric # Constant literal
      x
    # eg: (quote (1 2 3))
    elsif x[0] == 'quote'
      (_, exp) = x
      return exp
    # eg: (if (< 4 2) true false)
    elsif x[0] == 'if'
      (_, test, conseq, alt) = x
      if self.eval(test, env)
        self.eval(conseq, env)
      else
        self.eval(alt, env)
      end
    # eg: (set! pi 3.14)
    elsif x[0] == 'set!'
      (_, var, exp) = x
      env.search(var)[var] = self.eval(exp, env)
    # eg: (set! ppl 10)
    elsif x[0] == 'define'
      (_, var, exp) = x
      env[var] = self.eval(exp, env)
    # eg: (define square (lambda (x) (* 2 x))) (square 2)
    elsif x[0] == 'lambda'
      (_, vars, exp) = x
      lambda { |*args| self.eval(exp, Env.new(vars, args, env)) }
    # eg: (begin (set! x 1) (set! y 2) (+ x y))
    elsif x[0] == 'begin'
      x.shift
      val = nil
      x.each { |exp| val = self.eval(exp, env) }
      return val
    # eg: (= 4 4)
    else
      exps = []
      x.each { |exp| exps.push( self.eval(exp, env) ) }
      procedure = exps.slice!(0)
      procedure.call(*exps)
    end
  end
  
  # Read a Scheme exp from a string
  def parse(s)
    self.read_from(self.tokenize(s))
  end
  
  # Convert a string into a list of tokens
  def tokenize(str)
    str.gsub('(',' ( ').gsub(')',' ) ').split()
  end
  
  # Read an expression from a sequence of tokens
  def read_from(tokens)
    if tokens.length == 0
      raise SyntaxError
    end

    token = tokens.slice!(0)

    if '(' == token
      l = []
      while tokens[0] != ')'
        l << self.read_from(tokens)
      end
      tokens.slice!(0) # pop off ')'
      return l
    elsif ')' == token
      raise SyntaxError, 'unexpected )'
    else
      return self.atom(token)
    end
  end
  
  # Numbers become numbers; every other token is a symbol.
  def atom(token)
    # Try converting to integer
    begin
      Integer(token)
    rescue
      # Try converting to float
      begin
        Float(token)
      rescue
        # Non-float, non-int, it's a string
        token
      end
    end
  end
  
  def start_repl!
    loop do
      print 'lisp.rb> '

      # Handle user input exceptions
      begin
        line = $stdin.gets.chomp
      rescue NoMethodError, Interrupt
        exit
      end

      # Handle parsing exceptions
      begin
        evaled = self.eval(self.parse(line))
        if not evaled.nil?
          p evaled
        end
      rescue Exception => e
        puts e
        print ''
      end
      
      # Quiting the REPL
      if line =~ /^(exit|quit)$/
        abort(@quit_message)
      end
    end
  end
end

Lisp.new.start_repl!