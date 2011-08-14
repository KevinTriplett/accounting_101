# original watchr file:
# watch( 'test/.*_test\.rb' )  {|md| system("ruby #{md[0]}") }
# watch( 'app/models/(.*)\.rb' )  {|md| system("ruby test/unit/#{md[1]}_test.rb") }
# watch( 'lib/(.*)\.rb' )      {|md| system("ruby test/unit/#{md[1]}_test.rb") }
# new watchr file, from https://gist.github.com/raw/276317/45b7ca8a20f0585acc46bc75fade09a260155a61/tests.watchr

ENV["WATCHR"] = "1"
system 'clear'

def growl_test(message)
  growlnotify = `which growlnotify`.chomp
  title = "Watchr Test Results"
  image = message.include?('0 failures, 0 errors') ? "~/.watchr_images/passed.png" : "~/.watchr_images/failed.png"
  options = "-w -n Watchr --image '#{File.expand_path(image)}' -m '#{message}' '#{title}'"
  system %(#{growlnotify} #{options} &)
end

def growl_spec(message)
  growlnotify = `which growlnotify`.chomp
  title = "Watchr Test Results"
  image = message.include?(' 0 failures') ? "~/.watchr_images/passed.png" : "~/.watchr_images/failed.png"
  options = "-w -n Watchr --image '#{File.expand_path(image)}' -m '#{message}' '#{title}'"
  system %(#{growlnotify} #{options} &)
end

def run(cmd)
  puts(cmd)
  `#{cmd}`
end

def run_test_file(file)
  system('clear')
  result = run(%Q(ruby -I"lib:test" -rubygems #{file}))
  growl_test result.split("\n")[-2] rescue nil
  puts result
end

def run_spec_file(file)
  system('clear')
  # system "bundle exec rspec #{file}"
  # result = run(%Q(ruby -I"lib:rspec" -rubygems #{file}))
  result = run(%Q(bundle exec rspec #{file}))
  growl_spec result.split("\n")[-1] rescue nil
  puts result
end

def run_all_tests
  system('clear')
  result = run "rake test"
  growl result.split("\n").last rescue nil
  puts result
end

def run_all_features
  system('clear')
  run "cucumber"
end

def related_test_files(path)
  Dir['test/**/*.rb'].select { |file| file =~ /#{File.basename(path).split(".").first}_test.rb/ }
end

def related_spec_files(path)
  Dir['spec/**/*.rb'].select { |file| file =~ /#{File.basename(path).split(".").first}_spec.rb/ }
end

def run_suite
  run_all_tests
  run_all_features
end

watch('test/test_helper\.rb') { run_all_tests }
watch('spec/.*/.*_spec\.rb') { |m| run_spec_file(m[0]) }
# watch('test/.*/.*_test\.rb') { |m| run_test_file(m[0]) }
watch('app/.*/.*\.rb') { |m| related_spec_files(m[0]).map {|tf| run_spec_file(tf) } }
# watch('app/.*/.*\.rb') { |m| related_test_files(m[0]).map {|tf| run_test_file(tf) } }
watch('features/.*/.*\.feature') { run_all_features }

# Ctrl-\
Signal.trap 'QUIT' do
  puts " --- Running all tests ---\n\n"
  run_all_tests
end

@interrupted = false

# Ctrl-C
Signal.trap 'INT' do
  if @interrupted then
    @wants_to_quit = true
    abort("\n")
  else
    puts "Interrupt a second time to quit"
    @interrupted = true
    Kernel.sleep 1.5
    # raise Interrupt, nil # let the run loop catch it
    run_suite
  end
end