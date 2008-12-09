require File.dirname(__FILE__) + '/../lib/rencon.rb'

describe Rencon do
  before do
    class Rencon
      def initialize(config)
        @config = config
      end
    end
  end

  it 'check method should check configuration' do
    Rencon.class_eval %[ public :check ]
    rencon = Rencon.new(nil)

    config = {}
    [:host, :user, :pass, :name].each do |key|
      rencon.check(config).should be_false
      config.store key, nil
    end
    rencon.check(config).should be_true
  end

  it 'conf method should be able to parse doubled hash and return correct value' do
    Rencon.class_eval %[ public :conf ]
    @foo = 'foo'
    @bar = 'bar'
    rencon = Rencon.new({:one => {
                           :two1 => @foo,
                           :two2 => @bar
                        }})
    rencon.conf(:one, :two1).should == @foo
    rencon.conf(:one, :two2).should == @bar
    rencon.conf(:one, :two3).should == nil
  end

  describe 'specification around the mark method' do

    before do
      @correct_name = 'John Rencon'
      @wrong_name   = 'Tomohiro Nishimura'
      @rencon = Rencon.new({:name => @correct_name})
    end

    it 'should make lambda returns mark' do
      mark = @rencon.lambda_mark
      mark.should be_kind_of Proc
      mark[@correct_name].should == '+'
      mark[@wrong_name].should == '-'
    end

    it 'can set another mark word' do
      rencon = Rencon.new({:name => @correct_name,
                           :mark => {
                             :mine => '*',
                             :none => 'x',
                           }})
      mark = rencon.lambda_mark
      mark[@correct_name].should == '*'
      mark[@wrong_name].should == 'x'
    end

    it 'should mark method makes icon by name' do
      @rencon.mark(@correct_name).should == '+'
      @rencon.mark(@wrong_name).should == '-'
    end
  end

  describe 'when call retrieve method' do

    before do
      @page  = mock('page')
      @agent = mock('agent')
      @agent.stub!(:get => @page, :page => @page)
      class Rencon
        # login can't success on offline test
        def initialize(config)
          @config = Hash.new
          @agent = config
        end
      end
      @rencon = Rencon.new @agent

      @tickets = mock('tickets')
      @tickets.stub!(:reject => @tickets )
      @tickets.stub!(:[] => @tickets)
      @page.stub!(:body)
    end

    it 'should retrieve tickets and title' do
      @title = mock('title')
      @title.stub!(:sub => @title)
      @page.should_receive(:title).and_return(@title)
      CSV.should_receive(:parse).and_return(@tickets)

      @rencon.retrieve('rencon').should == [@tickets, @title]
    end
  end
end
