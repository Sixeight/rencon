require 'rubygems'
require 'mechanize'
require 'kconv'
require 'csv'

class Rencon
  # TODO: config needs checks
  def initialize(config)
    @config = config

    @agent = WWW::Mechanize.new
    @agent.user_agent_alias = 'Mac Safari'

    page = @agent.get 'http://' + @config[:host] + '/login'
    form = page.forms[1]
    form.username conf(:user)
    form.password conf(:pass)
    @agent.submit form
  end

  def retrieve(project, per_page = 25)
    title = @agent.get("http://#{conf(:host)}/projects/show/#{project}").title.sub(/\s-.*\z/, '')

    per_page = conf(:per_page) || per_page
    page = @agent.get "http://#{conf(:host)}/projects/#{project}/issues/?per_page=#{per_page}&format=csv"
    # FIXME: Muiltiline descriptions are rounded off to one lines.
    #        #reject can not know correct number of issue's status.
    #        now size < 10, but this is a first aid. need fix rapidly.
    tickets = CSV.parse(page.body.to_s.toutf8).
      reject {|issue| issue.size < 10 }[1..-1]

    [tickets, title]
  end

  def lambda_mark
    mine = conf(:mark, :mine) || '+'
    none = conf(:mark, :none) || '-'
    lambda {|name| /#{conf[:name]}/ =~ name ? mine : none }
  end

  def mark(name)
    lambda_mark[name]
  end

  private
  def conf(*keys)
    # same as:
    #   keys.inject(@config, :[]) rescue nil
    keys.inject(@config) do |conf, key|
      conf[key] or break nil
    end
  end
end
