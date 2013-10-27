#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#
# Copyright 2013 Renaud AUBIN
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'readline'
require 'stringio'
require 'rubygems'

begin
  gem 'ruby-terminfo', '~> 0.1.1'
  require 'terminfo'
rescue LoadError => e
#  warn e.message
  warn 'Run `gem install ruby-terminfo` to install TermInfo.'
  exit -1
end

TAG_WIDTH, PID_WIDTH, LEVEL_WIDTH = 20, 8, 3 # set PID_WIDTH to -1 to suppress it
HEADER_SIZE = LEVEL_WIDTH + 1 + TAG_WIDTH + 1 + PID_WIDTH + 1
BLACK, RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN, WHITE = (0..7).to_a

class String
  def format(options={})
    codes = []
    options[:fg]      ? codes << "3#{options[:fg]}" : nil
    options[:bg]      ? codes << "4#{options[:bg]}" : nil
    options[:bold]    ? codes << '1'                : nil
    options[:inverse] ? codes << '7'                : nil

    "\e[#{codes.join ';'}m#{self}\e[0m"
  end

  def inverse(options={})
    options[:inverse] = true; format(options)
  end

  def bold(options={})
    options[:bold] = true; format(options)
  end
end

adb_args = ARGV[1..-1].join ' ' unless ARGV[1..-1].nil?

HEIGHT, WIDTH = TermInfo.screen_size
input = STDIN.tty? ? IO.popen("adb #{adb_args} logcat") : STDIN
session_tags = Hash.new { |h, k| h[k] = (0..7).to_a.sample }
session_tags.merge!({
                      dalvikvm: BLUE,
                      Process: BLUE,
                      ActivityManager: CYAN,
                      ActivityThread: CYAN,
                    })

LEVELS = {
  V: 'V'.center(LEVEL_WIDTH).format({fg: WHITE, bg: BLACK}),
  D: 'D'.center(LEVEL_WIDTH).format({fg: WHITE, bg: BLUE}),
  I: 'I'.center(LEVEL_WIDTH).format({fg: BLACK, bg: GREEN}),
  W: 'W'.center(LEVEL_WIDTH).format({fg: BLACK, bg: YELLOW}),
  E: 'E'.center(LEVEL_WIDTH).format({fg: WHITE, bg: RED}),
  F: 'F'.center(LEVEL_WIDTH).format({fg: RED,   bg: BLACK, bold: true}),
}

begin
  while buf = input.readline.strip!
    if /\A(?<level>[A-Z])\/(?<tag>[^\(]+)\((?<pid>[^\)]+)\): (?<msg>.*)\z/ =~ buf

      level.strip!; tag.strip!; pid.strip!; msg.strip!
      output = StringIO.new

      output << pid.center(PID_WIDTH).inverse unless PID_WIDTH < 0
      output << ' '
      tag_str = ((tag.size > TAG_WIDTH) ? tag[-TAG_WIDTH..-1] : tag.rjust(TAG_WIDTH))
      output << tag_str.format({fg: session_tags[tag.to_sym]})

      output << ' ' + LEVELS[level.to_sym] + ' '

      msg_size  = msg.size
      msg_lsize = msg_size / (WIDTH - HEADER_SIZE)

      output << msg[0..(WIDTH-HEADER_SIZE-1)] + "\n"
      if msg_lsize > 0
        1.upto msg_lsize do |i|
          output << (' '*HEADER_SIZE) + msg[(i*(WIDTH-HEADER_SIZE))..((i+1)*(WIDTH-HEADER_SIZE)-1)] + "\n"
        end
      end

      puts output.string
    end
  end
rescue Interrupt, EOFError
end
