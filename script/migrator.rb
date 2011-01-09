#!/usr/bin/env ruby

  # Simple migration navigator for terminal.
  #
  # Install
  # 1) Throw this code into script/migrator
  # 2) chmod +x script/migrator
  #
  # Use
  # script/migrator       => show 10 latest migrations, choose one
  # script/migrator 15    => show 15 latest migrations
  # script/migrator -5    => show 5 oldest migrations
  # script/migrator foo   => grep all migrations using regexp /foo/
  #
  # After each command you can:
  # — type the # of migration to migrate to it
  # — type exit/quit/abort/stop (or press ctrl+c) to exit

  require 'time'

  migrations_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'db', 'migrate'))
  globbed_migrations = File.join(migrations_dir, "*.rb")

  migrations = []

  Dir.glob(globbed_migrations).each do |entry|
    stamp, title = File.basename(entry).split('_', 2)
    title.chomp!('.rb')
    title.gsub!(/_/, ' ')
    title.capitalize!
    migrations << [stamp, title]
  end

  command = ARGV.join(' ')

  run_migration = lambda do |stamp|
    system("rake db:migrate VERSION=#{stamp}")
  end

  print_results = lambda do |results|
    unless results.empty?
      puts "\n"
      results.each_with_index do |result, i|
        created = Time.parse(result[0]).strftime("%b %d, %y")
        puts "#{i + 1}. #{result[1]}. (#{created})"
      end
      puts "\n"
    end
  end

  validate_choice = lambda do |results, choice|
    unless (1..results.size).include?(choice.to_i)
      puts "Exiting."
      exit(0)
    end
  end

  find = lambda do
    results = migrations.select{|el| el[1] =~ Regexp.new(command)}

    puts "Found #{results.size} migration(s):"
    print_results.call(results)

    unless results.empty?
      print "Enter # to migrate to: "
      choice = STDIN.gets.to_i
      validate_choice.call(results, choice)
      puts "Migrating to \"#{results[choice-1][1]}\""
      run_migration.call(results[choice-1][0])
    end
  end

  first = lambda do |number|
    results = migrations.first(number)

    puts "Showing oldest #{number} migrations:"
    print_results.call(results)

    unless results.empty?
      print "Enter # to migrate to: "
      choice = STDIN.gets.to_i
      validate_choice.call(results, choice)
      puts "Migrating to \"#{results[choice-1][1]}\""
      run_migration.call(results[choice-1][0])
    end
  end

  last = lambda do |number|
    results = migrations.last(number)

    puts "Showing latest #{number} migrations:"
    print_results.call(results)

    unless results.empty?
      print "Enter # to migrate to: "
      choice = STDIN.gets.to_i
      validate_choice.call(results, choice)
      puts "Migrating to \"#{results[choice-1][1]}\""
      run_migration.call(results[choice-1][0])
    end
  end

  case command
  when /^\s*$/: last.call(10)
  when /^(\d+)$/: last.call($1.to_i)
  when /^-(\d+)$/: first.call($1.to_i)
  else find.call
  end
