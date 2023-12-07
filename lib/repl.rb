# frozen_string_literal: true

require 'readline'

# Repl クラス
class Repl
  def initialize(obj)
    @emehcs_obj = obj
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
      break
    rescue StandardError # rescue Exception
      puts "Error: #{$!}"
    end
  end
end
