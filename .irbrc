### IRB configuration.
IRB.conf[:PROMPT_MODE]  = :SIMPLE
IRB.conf[:AUTO_INDENT]  = true






#------------------------------------- Load Helper Gems ------------------------

### benchmark-ips
# https://github.com/evanphx/benchmark-ips
begin
  require 'benchmark/ips'
rescue LoadError => err
  puts `gem install benchmark-ips`
  require 'benchmark/ips'
end

### What? method
# The Object.what? method returns the method(s) that will return
# a specific value.
# Example:
#  >> 6.what? 7
#  6.succ == 7
#  6.next == 7
#  => ["succ", "next"]
begin
  require 'what_methods'
rescue LoadError => err
  puts `gem install what_methods`
  require 'what_methods'
end

### ap method
# ap() is an enhanced version of pp()
# Example:
# >> ap (1..4).to_a
# [
#     [0] 1,
#     [1] 2,
#     [2] 3,
#     [3] 4
# ]
# => nil
begin
  require 'ap'
rescue LoadError => err
  puts `gem install awesome_print`
  require 'ap'
end

# some external services, (bitly)
begin
  require 'mush'
rescue LoadError => err
  puts `gem install mush`
  require 'mush'
end

## Notify us of the version and that it is ready.
begin
  gemset = `rvm gemset name`
rescue Errno::ENOENT => err
  gemset = '-'
  warn "Unable to run rvm: #{err} (maybe: https://rvm.io/rvm/install)"
end

gemset = 'default' if gemset.start_with? '/'
puts "Ruby #{RUBY_VERSION} Gemset #{gemset}"





#---------------------------------------------- Ruby Helpers ----------------------
# Log to STDOUT if in Rails
if ENV.include?('RAILS_ENV') && !Object.const_defined?('RAILS_DEFAULT_LOGGER')
  require 'logger'
  RAILS_DEFAULT_LOGGER = Logger.new(STDOUT)
end

# http://ozmm.org/posts/time_in_irb.html
def time
  Benchmark.ips do |x|
    x.time = 5
    x.warmup = 2

    x.report("test") { yield }
  end
end

# Easily print methods local to an object's class
module ObjectLocalMethods
  def local_methods(include_superclasses = true)
    (self.methods - (include_superclasses ? Object.methods : self.class.superclass.instance_methods)).sort
  end

  def ri(method = nil)
    unless method && method =~ /^[A-Z]/ # if class isn't specified
      klass = self.kind_of?(Class) ? name : self.class.name
      method = [klass, method].compact.join('#')
    end
    puts `ri '#{method}'`
  end
end
Object.send(:extend,  ObjectLocalMethods)
Object.send(:include, ObjectLocalMethods)





#-------------------------------------- IRB Helpers ---------------------
#clear the screen
def clear
  system('clear')
end
alias :cl :clear

def by(url)
  bitly = Mush::Services::Bitly.new
  bitly.login = "o_6mi7b7g4oc"
  bitly.apikey = "R_acf61600030046f09ccbc29186b9a710"

  bitly.shorten url
end

# reloads a file into the IRB.
# from http://themomorohoax.com/2009/03/27/irb-tip-load-files-faster
def rl(file_name = nil)
  if file_name.nil?
    if !@recent.nil?
      rl(@recent)
    else
      puts "No recent file to reload"
    end
  else
    file_name += '.rb' unless file_name =~ /\.rb/
    @recent = file_name
    load "#{file_name}"
  end
end

# reload this .irbrc
def ireload
  load __FILE__
end





#------------------------------------------- History ---------------------------
# shows last n entries of history, default 15
def hist count = 15
  history = Readline::HISTORY.to_a[0-count..-1]
  history.each_with_index do |command, i|
    puts "#{"%5d" % (history.length - i)}:   #{command}"
  end
  nil
end

# repeat last command, or the command with correspondent num in hist method call
def rep i = 1
  i += 1 # because in call moment adds new command to history array
  history = Readline::HISTORY.to_a

  command = history[history.length - i]
  while command.start_with? 'rep'
    i += 1
    command = history[history.length - i]
  end

  puts "eval command => #{command}"
  eval command unless command.start_with? 'rep'
end

