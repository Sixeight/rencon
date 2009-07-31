require File.dirname(__FILE__) + '/../lib/rencon.rb'

module Rencon

  describe Core do

    before do
      class Core
        def initialize(config)
          @config = config
        end
      end
    end

    it 'check method should check the configuration' do
      rencon = Core.new(nil)

      config = {}
      [:host, :user, :pass, :name].each do |key|
        rencon.__send__(:check, config).should be_false
        config.store key, nil
      end
      rencon.__send__(:check, config).should be_true
    end

    it 'conf method should be able to parse a doubled hash and return the correct value' do
      @foo = 'foo'
      @bar = 'bar'
      rencon = Core.new({:one => {
                             :two1 => @foo,
                             :two2 => @bar
                          }})
      rencon.__send__(:conf, :one, :two1).should == @foo
      rencon.__send__(:conf, :one, :two2).should == @bar
      rencon.__send__(:conf, :one, :two3).should == nil
    end

    describe 'specification around the mark method' do
      before do
        @correct_name = 'John Rencon'
        @wrong_name   = 'Tomohiro Nishimura'
        @rencon = Core.new({:name => @correct_name})
      end

      it 'should make lambda returns mark' do
        mark = @rencon.lambda_mark
        mark.should be_kind_of Proc
        mark[@correct_name].should == '+'
        mark[@wrong_name].should == '-'
      end

      it 'can set another mark word' do
        rencon = Core.new({:name => @correct_name,
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
        @page  = mock('page', :null_object => true)
        @agent = mock('agent')
        @agent.stub!(:get => @page, :page => @page)
        class Core
          # login can't success on offline test
          def initialize(config)
            @config = Hash.new
            @agent = config
          end
        end
        @rencon = Core.new @agent

        @states = mock('names')
        @tickets = mock('tickets')
        @page.stub!(:body)
        @title = mock('title')
        @title.stub!(:sub => @title)
      end

      it 'should retrieve tickets and title' do
        @tickets.stub!(:reject => [@states, @tickets] )
        @page.should_receive(:title).and_return(@title)
        CSV.should_receive(:parse).and_return(@tickets)

        @rencon.retrieve('rencon').should == [[@tickets], @title]
      end

      it 'should states methods returns ticket states name' do
        CSV.stub!(:parse => @tickets)
        @states = ['#', 'tracker', 'user']
        @tickets.stub!(:reject => [@names, @tickets] )
        @rencon.retrieve('rencon')
        @rencon.states.should == @names
      end
    end
  end
end

