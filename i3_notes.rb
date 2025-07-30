#!/usr/bin/env ruby

# frozen_string_literal: true

require 'i3ipc'

class Node
  attr_reader :raw

  def initialize(raw)
    @raw = raw
  end

  def iter(&block)
    block.call(self)

    return unless @raw.key?(:nodes) || @raw.key?(:floating_nodes)

    @raw[:nodes].each do |node|
      child = Node.new(node)
      child.iter(&block)
    end

    @raw[:floating_nodes].each do |node|
      child = Node.new(node)
      child.iter(&block)
    end
  end

  def find(path, value)
    iter do |node|
      return node if node.raw.dig(*path) == value
    end
    nil
  end
end

def subscribe(event_name, &block)
  i3 = I3Ipc::Connection.new
  bl = proc do |reply|
    block.call(reply, i3)
  end

  i3.subscribe(event_name, bl)
end

def wait_for_instance(name, &trigger)
  pid = subscribe('window') do |reply, i3|
    if reply.change == 'new' && reply.container.window_properties.instance == name
      i3.close
      Thread.exit
    end
  end

  trigger.call
  pid.join
end

notes_root_path = '/home/ben/data/notes/'
start_note = 'work/kemas/quicknotes.md'
instance_name = 'my_note_collection'

i3 = I3Ipc::Connection.new
node = Node.new(i3.tree.to_h)
           .find(%i[window_properties instance], instance_name)

if node.nil?
  Dir.chdir notes_root_path
  wait_for_instance(instance_name) do
    Process.spawn("kitty --name #{instance_name} nvim #{start_note}")
  end

  i3.command(%([instance="#{instance_name}"] floating enable))
  i3.command(%([instance="#{instance_name}"] resize set 1000 500))
  i3.command(%([instance="#{instance_name}"] move position center))
elsif node.raw[:focused] == false
  i3.command(%([instance="#{instance_name}"] floating enable))
  i3.command(%([instance="#{instance_name}"] resize set 1000 1000))
  i3.command(%([instance="#{instance_name}"] move to workspace current))
  i3.command(%([instance="#{instance_name}"] move position center))
  i3.command(%([instance="#{instance_name}"] focus))
else
  i3.command(%([instance="#{instance_name}"] move scratchpad))
end

i3.close
