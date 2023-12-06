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

      print @emehcs_obj.run(prompt)
      print "\n"
      # puts prompt
    rescue Interrupt
      puts "\nBye!"
      break
    rescue StandardError # rescue Exception
      puts "Error: #{$ERROR_INFO}" # puts "Error: #{$!}"
    end
  end
end
