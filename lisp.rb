#!/usr/bin ruby
# 
# Lisp parser.
# Author: @_ty

Sym = String

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
  if x.is_a? Sym # Variable reference
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

  token = tokens.pop(0)

  if '(' == token
    l = []
    while tokens[0] != ')'
      l << read_from(tokens)
    end
    tokens.pop(0) # pop off ')'
    return l
  elsif ')' == token
    raise SyntaxError, 'unexpected )'
  else
    return atom(token)
  end
end    

# Numbers become numbers; every other token is a symbol.
def atom(token)
  if token.respond_to? :to_i
    token.to_i
  elsif token.respond_to? :to_f
    token.to_f
  else
    token.to_s
  end
end

def repl
  loop do
    print 'lisp.rb> '

    begin
      line = $stdin.gets.chomp
    rescue NoMethodError, Interrupt
      exit
    end
    
    puts line
    puts parse(line)

    # val = eeval(parse(line))
    # if not val.nil?
    #   print 'string'
    # end
  end
end

repl()