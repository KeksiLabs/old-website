#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'

# This matches the frotmatter block
YAML_FRONT_MATTER_REGEXP = /\A---(.|\n)*?---/m

def replacePostModifiedTime(filename)
    file = File.open(filename, "a+")

    content = file.read

    yml = YAML.load(content)

    mtime = file.mtime

    # Stop if file is not modified
    return if yml['modifiedDate'] === mtime

    puts "Setting modifiedDate to #{File.basename(filename)}"

    yml['modifiedDate'] = mtime

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

# Search for modified posts
Dir.glob("#{__dir__}/../_posts/**/*.md") do |file|
    replacePostModifiedTime(file)
end

