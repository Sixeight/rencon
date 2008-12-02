require 'rubygems'
require 'mechanize'
require 'nkf'
require 'csv'

class Rencon
  # TODO: need check code for config
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
    page = @agent.get "/projects/show/#{project}"
    title = page.title.sub(/\s-.*\z/, '')

    per_page = conf(:per_page) || per_page
    page = @agent.get "/projects/#{project}/issues/?per_page=#{per_page}&format=csv"
    tickets = CSV.parse NKF.nkf('-w', page.body)
    # FIXME: Muiltiline descriptions are rounded off to one line.
    tickets.reject! {|issue| issue.size != 17 }
    tickets.shift

    [tickets, title]
  end

  def lambda_mark
    mine = conf(:mark, :mine) || '+'
    none = conf(:mark, :none) || '-'
    lambda {|name| name =~ /#{conf[:name]}/ ? mine : none }
  end

  def mark(name)
    lambda_mark[name]
  end

  private
  def conf(*keys)
    keys.inject(@config) do |conf, key|
      value = conf[key] or break nil
      value
    end
  end
end
