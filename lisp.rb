#!/usr/bin ruby
# 
# Lisp parser.
# Port and inspiration of http://norvig.com/lispy.html.
#
# Author: @_ty

class Env < Hash
  @@globals = {
    '+' => lambda { |x, y| x + y },
    'null?' => lambda { |x| x.nil? },
    'PI' => Math::PI
  }
  
  def initialize(outer=nil)
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

global_env = Env.new

# Evaluate an expression in an environ
def eeval(x, e = global_env)
  if x.is_a? String # Variable reference
    env.search(x)[x]
  elsif x.is_a? Numeric # Constant literal
    x
  elsif x[0] == 'quote'
    (_, exp) = x
  elsif x[0] == 'if'
    (_, test, conseq, alt) = x
    if eeval(test, env)
      eeval(conseq, env)
    else
      eeval(alt, env)
    end
  elsif x[0] == 'set!'
    (_, var, exp) = x
    env.search(var)[var] = eeval(exp, env)
  else
    puts 'Error!'
  end
end

# Read a Scheme exp from a string
def parse(s)
  read_from(tokenize(s))
end

# Convert a string into a list of tokens
def tokenize(str)
  str.gsub('(',' ( ').gsub(')',' ) ').split()
end

# Read an expression from a sequence of tokens
def read_from(tokens)
  if tokens.length == 0
    raise SyntaxError, 'Bad syntax.'
  end
  
  token = tokens.slice!(0)

  if '(' == token
    l = []
    while tokens[0] != ')'
      l << read_from(tokens)
    end
    tokens.slice!(0) # pop off ')'
    return l
  elsif ')' == token
    raise SyntaxError, 'unexpected )'
  else
    return atom(token)
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

def repl
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
      evaled = eeval(parse(line))
      if not evaled.nil?
        p evaled
      end
    rescue Exception => e
      puts e
      print ''
    end
  end
end

repl()