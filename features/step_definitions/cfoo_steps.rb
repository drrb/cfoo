require 'fileutils'
require 'json'
include FileUtils

Given /^I have a project$/ do
end

Given /^I have a module named "(.*?)"$/ do |module_name|
    create_dir "modules/#{module_name}"
end

Given /^I have a file "(.*?)" containing$/ do |filename, content|
    write_file(filename, content)
end

When(/^I process "(.*?)"$/) do |filename|
    cfoo.process(filename)    
end

When /^I build the project$/ do
    cfoo.build_project
end

Then(/^the output should match JSON$/) do |expected_json|
    begin
        expected = JSON.parse(expected_json)
    rescue StandardError => e
        puts "Couldn't parse expected ouput as JSON"
        raise e
    end
    begin
        actual = JSON.parse(stdout.messages.join "")
    rescue StandardError => e
        puts "Couldn't parse actual ouput as JSON"
        raise e
    end
    actual.should == expected
end

def write_file(filename, content)
    file_fqn = resolve_file(filename)
    mkdir_p(File.dirname file_fqn)
    File.open(file_fqn, "w") do |file|
        file.puts content
    end
end

def create_dir(directory)
    mkdir_p(resolve_file(directory))
end

def resolve_file(filename)
    "#{project_root}/#{filename}"
end

def cfoo
    @cfoo ||= Cfoo::Cfoo.new(processor, renderer, stdout)
end

def processor
    @processor ||= Cfoo::Processor.new(parser, project)
end

def parser
    @parser ||= Cfoo::Parser.new(file_system)
end

def renderer
    @renderer ||= Cfoo::Renderer.new
end

def project
    @project ||= Cfoo::Project.new(file_system)
end

def file_system
    @file_system ||= Cfoo::FileSystem.new(project_root)
end

def project_root
    @project_root ||= "/tmp/cfoo-cucumber-#{$$}"
    mkdir_p(@project_root)
    @project_root
end

def stdout
    @output ||= Output.new
end

After do                                                                             
    rm_rf project_root if File.directory? project_root
end

class Output
    def messages
        @messages ||= []
    end

    def puts(message)
        messages << message
    end
end
