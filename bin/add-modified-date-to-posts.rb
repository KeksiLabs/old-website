#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

# This matches the frotmatter block
YAML_FRONT_MATTER_REGEXP = /\A---(.|\n)*?---/m

def replacePostModifiedTime(filename)
    file = File.open(filename, "a+")

    content = file.read

    # Stop when there's parsing errors
    begin
        yml = YAML.load(content)
    rescue Psych::SyntaxError
        return
    end

    mtime = file.mtime

    # Stop if file is not modified
    return if yml['last_modified_at'] === mtime

    puts "Setting modifiedDate to #{File.basename(filename)}"

    yml['last_modified_at'] = mtime

    frontmatter = "---\n"

    yml.each { |header,value|
        frontmatter+=("#{header}: #{value}\n")
    }
    frontmatter += '---'

    # Replace frontmatter from the file

    replaced_content = content.sub(YAML_FRONT_MATTER_REGEXP,frontmatter)

    # Write new file
    file.truncate(0)
    file.puts(replaced_content)
    file.close

    # Keep original modifieddate
    FileUtils.touch filename, :mtime => mtime
end

puts "Running modifiedDate hook..."
# Search for modified posts
Dir.glob("#{__dir__}/../{*,*/*}.md") do |file|
    puts file
    next if File.basename(file.downcase) == "readme.md"
    replacePostModifiedTime(file)
end

