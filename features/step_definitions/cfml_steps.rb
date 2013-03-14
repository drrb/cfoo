require 'fileutils'
require 'json'
include FileUtils

Given(/^I have a file "(.*?)" containing$/) do |filename, content|
    file_fqn = "#{project_root}/#{filename}"
    mkdir_p(File.dirname file_fqn)
    File.open(file_fqn, "w") do |file|
        file.puts content
    end
end

When(/^I process "(.*?)"$/) do |filename|
    cfml.process(filename)    
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

def cfml
    @cfml ||= Cfml::Cfml.new(processor, stdout)
end

def processor
    @combiner ||= Cfml::Processor.new(project)
end

def project
    @project ||= Cfml::Project.new(project_root)
end

def project_root
    mkdir_p(@project_root ||= "/tmp/cfml-cucumber-#{$$}").shift
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
