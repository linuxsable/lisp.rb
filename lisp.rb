#!/usr/bin ruby
global_env = {}
Sym = String

module Lisp
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
  def eval(x, env=global_env)
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
  def self.tokenize(s)
    s.gsub('(',' ( ').gsub(')',' ) ').split()
  end
  
  # Read an expression from a sequence of tokens
  def read_from(tokens)
    
  end
  
end

p Lisp::tokenize('(set! x*2 (* x 2))')