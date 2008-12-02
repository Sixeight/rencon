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

    page = @agent.get @config[:host] + '/login'
    form = page.forms[1]
    form.username conf(:user)
    form.password conf(:pass)
    @agent.submit form
  end

  def retrieve(project, per_page = 25)
    title = @agent.get("/projects/show/#{project}").title.sub(/\s-.*\z/, '')

    per_page ||= conf(:per_page)
    page = @agent.get "/projects/#{project}/issues/?per_page=#{per_page}&format=csv"
    tickets = CSV.parse(page.body.to_s.toutf8)
    # FIXME: Muiltiline descriptions are rounded off to one lines.
    tickets.reject! {|issue| issue.size != 17 }
    tickets.shift

    # The current mock doesn't accept below :-(
    # tickets = CSV.parse(page.body.to_s.toutf8).
    #   reject {|issue| issue.size != 17 }[1..-1]

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
