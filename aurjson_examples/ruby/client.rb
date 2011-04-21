#!/usr/bin/env ruby

require 'net/http'
require 'optparse'
require 'ostruct'
require 'logger'
require 'json'

LOG = Logger.new(STDERR)
LOG.level = Logger::WARN
LOG.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }

options = OpenStruct.new
options.search = false
options.info = false
query_term = ARGV.pop

ARGV.options do |opts|
    script_name = File.basename($0)
    opts.banner = "Usage: ruby #{script_name} [options] query-term"
    opts.separator ""
    opts.separator "Query Mode options:"

    opts.on("-i", "--info", "Operate in info mode") do |i|
        options.info = i
    end

    opts.on("-s", "--search", "Operate in search mode") do |s|
        options.search = s
    end

    opts.separator ""
    opts.separator "General options:"

    opts.on_tail("-h", "--help", "Show this help message") do
        puts opts
        exit
    end

    if ARGV.empty?
        puts opts
        exit 2
    end
    opts.parse!
end or exit 2

abort('no query type specified. choose search or info.') unless options.search or options.info
abort('both search and info specified. choose one.') if options.search and options.info

type = 'search' if options.search
type = 'info' if options.info

## http request
url = "http://aur.archlinux.org/rpc.php?type=#{type}&arg=#{query_term}"
uri = URI.parse(URI.escape(url))
http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Get.new(uri.request_uri, {'User-Agent' => 'AURJSON-Example/1.0 ruby'})
response = http.request(request)

if response.code != '200'
    puts "Response code was: #{response.code}"
    exit 1
end

## parse result
data = JSON.parse(response.body)
case data['type']
when 'error'
    puts "Error: #{data['results']}"
when 'search'
    data['results'].each do |pkg|
        puts "Package:"
        pkg.sort.each { |key,value| puts "  #{key}: #{value}" }
    end
when 'info'
    puts "Package:"
    data['results'].sort.each { |key,value| puts "  #{key}: #{value}" }
else
    puts 'Error in response data...'
    exit 1
end
