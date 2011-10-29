#!/usr/bin ruby
# 
# Lisp parser.
# Port and inspiration of http://norvig.com/lispy.html.
#
# Author: @_ty

class Env < Hash
  def initialize(outer=nil)
    @outer = outer
    add_globals()
  end

  def search(var)
    return self if not self[var].nil?
    return nil if @outer.nil?
    return @outer.search(var)
  end

  private

  def add_globals
    globals = {
      '+' => lambda { |x, y| x + y }
    }
    self.merge!(globals)
  end
end

# Evaluate an expression in an environ
def eeval(x)
  env = Env.new
  if x.is_a? String # Variable reference
    env.search(x)[x]
  elsif not x.is_a? Object # Constant literal

  else

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
    raise SyntaxError, 'Bad syntax'
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
      print parse(line)
    rescue Exception
      print ''
    end

    # val = eeval(parse(line))
    # if not val.nil?
    #   print 'string'
    # end
  end
end

repl()