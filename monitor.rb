#!/usr/bin/env ruby

# frozen_string_literal: true

# read about smem:
# https://www.golinuxcloud.com/check-memory-usage-per-process-linux/

class ProcessSummary
  attr_reader :values

  def initialize(values)
    @values = values
  end

  def +(other)
    new_values = values.each_with_object({}) do |k, v, values|
      values[k] = add_unless_nil(v, other.values[k])
    end

    self.class.new(new_values)
  end

  def add_unless_nil(value1, value2)
    return nil if value1.nil? || value2.nil?

    value1.to_i + value2.to_i
  end
end

class ProcessInfo
  attr_reader :pid, :ppid, :values, :header, :childs

  def initialize(pid, ppid, header, values)
    @pid = pid.to_i
    @ppid = ppid.to_i
    @header = header
    @values = values
    @childs = []
    @summary = nil
  end

  def summary
    @summary ||= childs.reduce(ProcessSummary.new(@rss)) do |summary, child|
      summary + child.summary
    end
  end

  def print(depth = -1, pad = 0)
    Kernel.print "#{' ' * pad}#{command}".ljust(30, ' ')
    Kernel.print "#{@pid.to_s.rjust(9, ' ')} "
    Kernel.print "#{(summary.rss / 1000.0).round(1)}M".rjust(9, ' ')
    Kernel.print "#{(@rss / 1000.0).round(1)}M ".rjust(9, ' ')
    puts

    return unless depth != 0

    @childs
      .sort { |c1, c2| c2.summary.rss <=> c1.summary.rss }
      .each { |child| child.print(depth - 1, pad + 2) }
  end
end

ps = `ps -eo pid,ppid,rss,comm`
     .split("\n")
     .map { |line| line.split(' ', 4) }

header = ps.shift

ps = ps.map { |cols| ProcessInfo.new(*cols) }

childs = ps.each_with_object({}) do |pinfo, ps_map|
  (ps_map[pinfo.ppid] ||= []).push(pinfo)
end

ps.each { |pinfo| pinfo.childs = childs[pinfo.pid] || [] }

root = ps.find { |pinfo| pinfo.pid == 1 }
root.print(1)
