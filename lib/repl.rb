# frozen_string_literal: true

require 'readline'

# Repl クラス
class Repl
  READLINE_HIST_FILE = './data/.readline_history'

  def initialize(obj)
    @emehcs_obj = obj
    return unless File.exist? READLINE_HIST_FILE

    File.open(READLINE_HIST_FILE).readlines.each do |d|
      Readline::HISTORY.push d.chomp
    end
  end

  def repl
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
          print @emehcs_obj.run(c)
          print "\n"
        end
      else
        print @emehcs_obj.run(prompt)
        print "\n"
        # puts prompt
      end
    rescue Interrupt
      puts "\nBye!"
      File.open(READLINE_HIST_FILE, 'w') do |f2|
        Readline::HISTORY.each { |s| f2.puts s }
      end
      break
    rescue StandardError # rescue Exception
      puts "Error: #{$!}"
    end
  end
end
