### IRB configuration.
IRB.conf[:PROMPT_MODE] = :SIMPLE
IRB.conf[:AUTO_INDENT] = true

begin
  require 'ap'
  AwesomePrint.irb!
rescue LoadError => err
  warn "Unable to load Awesome Print (ap): #{err} (maybe: gem install awesome_print)"
end

begin
  require 'active_support/all'
rescue LoadError => err
  warn "Unable to load activesupport/all"
end

## Notify us of the version and that it is ready.
begin
  gemset = `rvm gemset name`
rescue Errno::ENOENT => err
  gemset = '-'
  warn "Unable to run rvm: #{err} (maybe: https://rvm.io/rvm/install)"
end

#---------------------------------------------- Ruby Helpers ----------------------
# Log to STDOUT if in Rails
if ENV.include?('RAILS_ENV') && !Object.const_defined?('RAILS_DEFAULT_LOGGER')
  require 'logger'
  RAILS_DEFAULT_LOGGER = Logger.new(STDOUT)
end

# http://ozmm.org/posts/time_in_irb.html
def time(times = 1)
  require 'benchmark'
  ret = nil
  Benchmark.bm { |x| x.report { times.times { ret = yield } } }
  ret
end

def with_time
  time_now = Time.now
  block_result = yield
  ap "---------------> Time for operation: #{Time.now - time_now}"
  block_result
end


#-------------------------------------- IRB Helpers ---------------------
#clear the screen
def clear
  system('clear')
end
alias :cl :clear


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
def ireload!
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

