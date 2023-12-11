# frozen_string_literal: true

require 'readline'
require './lib/const'

# Repl クラス
class Repl
  def initialize(obj)
    @emehcs_obj = obj
    return unless File.exist? Const::READLINE_HIST_FILE

    File.open(Const::READLINE_HIST_FILE).readlines.each do |d|
      Readline::HISTORY.push d.chomp
    end
  end

  def prelude
    (puts 'no prelude.'; return) unless File.exist? Const::PRELUDE_FILE

    f = File.open(Const::PRELUDE_FILE, 'r')
    codes = f.read.split('|')
    f.close
    codes.each do |c|
      @emehcs_obj.run(c).to_s.gsub(/ ?:q/, '').to_s.gsub('"', '').to_s.gsub(',', '')
      # puts s
    end
  end

  def repl
    puts Const::EMEHCS_VERSION
    loop do
      input = Readline.readline(prompt = 'emehcs> ', add_hist = true)
      raise Interrupt if input.nil?

      prompt = input.chomp
      break if prompt == 'exit'

      if prompt[0..7] == 'loadFile'
        f = File.open(prompt[9..], 'r')
        codes = f.read.split('|')
        f.close
        codes.each do |c|
          s = @emehcs_obj.run(c).to_s.gsub(/ ?:q/, '').to_s.gsub('"', '').to_s.gsub(',', '')
          puts s
        end
      else
        s = @emehcs_obj.run(prompt).to_s.gsub(/ ?:q/, '').to_s.gsub('"', '').to_s.gsub(',', '')
        puts s
      end
    rescue Interrupt
      puts "\nBye!"
      File.open(Const::READLINE_HIST_FILE, 'w') do |f2|
        Readline::HISTORY.each { f2.puts _1 }
      end
      break
    rescue StandardError
      puts "Error: #{$!}"
    end
  end
end
